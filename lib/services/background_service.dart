import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'scanner_service.dart';
import 'ocr_service.dart';
import 'classifier_service.dart';
import '../config/constants.dart';

/// Top-level function required by WorkManager.
/// IMPORTANT: Must call DartPluginRegistrant.ensureInitialized() so that
/// Flutter plugins (sqflite, photo_manager, etc.) work in the background isolate.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Required: initialize Flutter plugin bindings in the background isolate
      // ignore: invalid_use_of_internal_member
      // DartPluginRegistrant is available via flutter/foundation in newer SDK
      // This is the correct way for workmanager >= 0.5.x
      try {
        // Attempt to register plugins (required for Android background isolate)
        final binding = WidgetsFlutterBinding.ensureInitialized();
        binding.toString(); // suppress unused warning
      } catch (_) {}

      switch (task) {
        case 'screenshot_scan_task':
          await BackgroundService.processScreenshotsInBackground();
          break;
      }
      return true;
    } catch (e) {
      debugPrint('[BG] Task failed: $e');
      return false;
    }
  });
}

class BackgroundService {
  static final ScannerService _scanner = ScannerService();
  static final OcrService _ocr = OcrService();
  static final ClassifierService _classifier = ClassifierService();
  static final DatabaseService _db = DatabaseService();

  /// Main background processing pipeline:
  /// 1. Scan for new screenshots (respects analyzeExisting setting)
  /// 2. Register them in DB
  /// 3. Run OCR on unscanned screenshots
  /// 4. Classify and update
  static Future<void> processScreenshotsInBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final analyzeExisting =
        prefs.getBool(AppConstants.prefAnalyzeExisting) ?? true;

    // Step 1: Find new screenshots
    final newScreenshots = await _scanner.scanForScreenshots(
      limit: 50,
      analyzeExisting: analyzeExisting,
    );

    // Step 2: Register in database
    if (newScreenshots.isNotEmpty) {
      await _scanner.registerNewScreenshots(newScreenshots);
    }

    // Step 3: Process unscanned screenshots (batch of 20)
    final unscanned = await _db.getUnscannedScreenshots(limit: 20);

    for (final screenshot in unscanned) {
      try {
        // Run OCR
        final extractedText = await _ocr.extractText(screenshot.imagePath);

        // Classify
        final category = _classifier.classify(extractedText);

        // Generate file hash for duplicate detection
        final fileHash = await _generateFileHash(screenshot.imagePath);

        // Update database
        await _db.markAsScanned(
          screenshot.id!,
          extractedText: extractedText,
          category: category,
          fileHash: fileHash,
        );
      } catch (e) {
        // Mark as scanned even if it fails so it doesn't block the queue forever
        await _db.markAsScanned(
          screenshot.id!,
          extractedText: '',
          category: 'Other',
          fileHash: '',
        );
        continue;
      }
    }
  }

  /// Process screenshots in foreground (with progress callback).
  ///
  /// [batchSize]         – how many screenshots to scan per call.
  /// [analyzeExisting]   – whether to include old gallery photos.
  /// [onProgress]        – callback (processed, total).
  /// [onFoundNew]        – callback called with count of newly registered screenshots.
  static Future<void> processScreenshotsBatch({
    int batchSize = 50,
    bool analyzeExisting = true,
    Function(int processed, int total)? onProgress,
    Function(int foundCount)? onFoundNew,
  }) async {
    // Step 1: Scan for new screenshots
    final newScreenshots = await _scanner.scanForScreenshots(
      limit: batchSize,
      analyzeExisting: analyzeExisting,
    );

    if (newScreenshots.isNotEmpty) {
      await _scanner.registerNewScreenshots(newScreenshots);
      onFoundNew?.call(newScreenshots.length);
    } else {
      onFoundNew?.call(0);
    }

    // Step 2: Get unscanned (could include previously registered ones too)
    final unscanned = await _db.getUnscannedScreenshots(limit: batchSize);
    final total = unscanned.length;

    if (total == 0) {
      onProgress?.call(0, 0);
      return;
    }

    for (int i = 0; i < unscanned.length; i++) {
      final screenshot = unscanned[i];
      try {
        final extractedText = await _ocr.extractText(screenshot.imagePath);
        final category = _classifier.classify(extractedText);
        final fileHash = await _generateFileHash(screenshot.imagePath);

        await _db.markAsScanned(
          screenshot.id!,
          extractedText: extractedText,
          category: category,
          fileHash: fileHash,
        );

        onProgress?.call(i + 1, total);
      } catch (e) {
        final err = e.toString().toLowerCase();
        // Stop and alert the user if AI model is still downloading
        if (err.contains('waiting') ||
            err.contains('download') ||
            err.contains('internal')) {
          throw Exception(
              'AI Model is still loading. Please wait a moment and try again.');
        }

        // Mark as scanned for genuinely corrupt images so it doesn't block the queue
        await _db.markAsScanned(
          screenshot.id!,
          extractedText: '',
          category: 'Other',
          fileHash: '',
        );
        onProgress?.call(i + 1, total);
        continue;
      }
    }
  }

  /// Generate MD5 hash of first 8KB of file for duplicate detection
  static Future<String> _generateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return '';

      final bytes = await file.openRead(0, 8192).fold<List<int>>(
        [],
        (previous, element) => previous..addAll(element),
      );

      return md5.convert(bytes).toString();
    } catch (e) {
      return '';
    }
  }
}
