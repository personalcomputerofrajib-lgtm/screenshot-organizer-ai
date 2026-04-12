import 'package:flutter/material.dart';
import '../models/screenshot_model.dart';
import '../services/database_service.dart';
import '../services/background_service.dart';
import '../services/premium_service.dart';

class ScreenshotProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final PremiumService _premium = PremiumService();

  List<ScreenshotModel> _screenshots = [];
  List<ScreenshotModel> _pinnedScreenshots = [];
  Map<String, int> _categoryCounts = {};
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isScanning = false;
  int _scanProgress = 0;
  int _scanTotal = 0;
  int _newFound = 0; // How many newly discovered screenshots this session
  String? _error;
  String _scanStatus = ''; // Human-readable scan status message

  List<ScreenshotModel> get screenshots => _screenshots;
  List<ScreenshotModel> get pinnedScreenshots => _pinnedScreenshots;
  Map<String, int> get categoryCounts => _categoryCounts;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  int get scanProgress => _scanProgress;
  int get scanTotal => _scanTotal;
  int get newFound => _newFound;
  String? get error => _error;
  String get scanStatus => _scanStatus;

  /// Load all screenshots from database
  Future<void> loadScreenshots({int? limit}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _screenshots = await _db.getAllScreenshots(limit: limit ?? 200);
      _totalCount = await _db.getTotalCount();
      _categoryCounts = await _db.getCategoryCounts();
      _error = null;
    } catch (e) {
      _error = 'Failed to load screenshots: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load pinned screenshots
  Future<void> loadPinnedScreenshots() async {
    try {
      _pinnedScreenshots = await _db.getPinnedScreenshots();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load pinned: $e';
      notifyListeners();
    }
  }

  /// Load screenshots by category
  Future<List<ScreenshotModel>> getByCategory(String category,
      {int? limit}) async {
    try {
      return await _db.getScreenshotsByCategory(category, limit: limit);
    } catch (e) {
      _error = 'Failed to load category: $e';
      notifyListeners();
      return [];
    }
  }

  /// Get screenshots grouped by date
  Future<Map<String, List<ScreenshotModel>>> getGroupedByDate() async {
    final all = await _db.getAllScreenshots();
    final grouped = <String, List<ScreenshotModel>>{};

    for (final screenshot in all) {
      final date = screenshot.dateTaken ?? screenshot.dateAdded;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final lastWeek = today.subtract(const Duration(days: 7));
      final lastMonth = today.subtract(const Duration(days: 30));

      String groupKey;
      if (date.isAfter(today)) {
        groupKey = 'Today';
      } else if (date.isAfter(yesterday)) {
        groupKey = 'Yesterday';
      } else if (date.isAfter(lastWeek)) {
        groupKey = 'Last Week';
      } else if (date.isAfter(lastMonth)) {
        groupKey = 'Last Month';
      } else {
        groupKey = 'Older';
      }

      grouped.putIfAbsent(groupKey, () => []);
      grouped[groupKey]!.add(screenshot);
    }

    return grouped;
  }

  /// Start scanning for new screenshots and processing them.
  /// [analyzeExisting] – pass false to only scan newly taken photos.
  Future<void> startScan({bool analyzeExisting = true}) async {
    final canScan = await _premium.canScan();
    if (!canScan) {
      _error = 'Scan limit reached. Upgrade to Premium for unlimited scans.';
      notifyListeners();
      return;
    }

    _isScanning = true;
    _scanProgress = 0;
    _scanTotal = 0;
    _newFound = 0;
    _scanStatus = 'Looking for screenshots…';
    _error = null;
    notifyListeners();

    try {
      await BackgroundService.processScreenshotsBatch(
        batchSize: 100,
        analyzeExisting: analyzeExisting,
        onFoundNew: (count) {
          _newFound = count;
          if (count > 0) {
            _scanStatus = 'Found $count new screenshot${count == 1 ? '' : 's'}. Analysing…';
          } else {
            _scanStatus = 'Checking queued screenshots…';
          }
          notifyListeners();
        },
        onProgress: (processed, total) {
          _scanProgress = processed;
          _scanTotal = total;
          if (total > 0) {
            _scanStatus = 'Analysing $processed / $total…';
          }
          notifyListeners();
        },
      );

      // Update scan count by number of images actually processed
      final scanned = _scanProgress > 0 ? _scanProgress : _newFound;
      if (scanned > 0) {
        await _premium.incrementScanCount(by: scanned);
      }

      // Reload data to show newly scanned screenshots
      await loadScreenshots();

      _scanStatus = _newFound > 0
          ? 'Done! $_newFound new screenshot${_newFound == 1 ? '' : 's'} added.'
          : 'Scan complete.';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _scanStatus = '';
    }

    _isScanning = false;
    notifyListeners();
  }

  /// Toggle pin status
  Future<void> togglePin(ScreenshotModel screenshot) async {
    final newPinned = !screenshot.isPinned;
    await _db.togglePin(screenshot.id!, newPinned);

    // Update local list
    final index = _screenshots.indexWhere((s) => s.id == screenshot.id);
    if (index != -1) {
      _screenshots[index] = screenshot.copyWith(isPinned: newPinned);
    }

    await loadPinnedScreenshots();
    notifyListeners();
  }

  /// Update screenshot category
  Future<void> updateCategory(int id, String category) async {
    await _db.updateCategory(id, category);

    final index = _screenshots.indexWhere((s) => s.id == id);
    if (index != -1) {
      _screenshots[index] = _screenshots[index].copyWith(category: category);
    }

    _categoryCounts = await _db.getCategoryCounts();
    notifyListeners();
  }

  /// Delete screenshot from database
  Future<void> deleteScreenshot(int id) async {
    await _db.deleteScreenshot(id);
    _screenshots.removeWhere((s) => s.id == id);
    _pinnedScreenshots.removeWhere((s) => s.id == id);
    _totalCount = await _db.getTotalCount();
    _categoryCounts = await _db.getCategoryCounts();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
