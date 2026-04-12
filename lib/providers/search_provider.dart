import 'dart:async';
import 'package:flutter/material.dart';
import '../models/screenshot_model.dart';
import '../services/database_service.dart';

class SearchProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<ScreenshotModel> _results = [];
  String _query = '';
  bool _isSearching = false;
  Timer? _debounce;

  List<ScreenshotModel> get results => _results;
  String get query => _query;
  bool get isSearching => _isSearching;
  bool get hasResults => _results.isNotEmpty;
  bool get hasQuery => _query.trim().isNotEmpty;

  /// Search with debounce (300ms delay for real-time search)
  void search(String query) {
    _query = query;
    notifyListeners();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _results = await _db.searchScreenshots(query.trim());
    } catch (e) {
      _results = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _query = '';
    _results = [];
    _isSearching = false;
    _debounce?.cancel();
    notifyListeners();
  }

  /// Get text snippet around the search match
  String getMatchSnippet(ScreenshotModel screenshot, {int contextLength = 50}) {
    final text = screenshot.extractedText ?? '';
    if (text.isEmpty || _query.isEmpty) return '';

    final lowerText = text.toLowerCase();
    final lowerQuery = _query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) return text.substring(0, text.length.clamp(0, contextLength * 2));

    final start = (matchIndex - contextLength).clamp(0, text.length);
    final end = (matchIndex + _query.length + contextLength).clamp(0, text.length);

    String snippet = text.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';

    return snippet;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
