import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _autoScan = true;
  bool _showNotifications = true;
  int _scanBatchSize = 50;
  bool _analyzeExistingPhotos = true; // Scan old gallery photos on first run

  bool get autoScan => _autoScan;
  bool get showNotifications => _showNotifications;
  int get scanBatchSize => _scanBatchSize;
  bool get analyzeExistingPhotos => _analyzeExistingPhotos;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoScan = prefs.getBool('auto_scan') ?? true;
    _showNotifications = prefs.getBool('show_notifications') ?? true;
    _scanBatchSize = prefs.getInt('scan_batch_size') ?? 50;
    _analyzeExistingPhotos =
        prefs.getBool(AppConstants.prefAnalyzeExisting) ?? true;
    notifyListeners();
  }

  Future<void> setAutoScan(bool value) async {
    _autoScan = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_scan', value);
    notifyListeners();
  }

  Future<void> setShowNotifications(bool value) async {
    _showNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_notifications', value);
    notifyListeners();
  }

  Future<void> setScanBatchSize(int value) async {
    _scanBatchSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scan_batch_size', value);
    notifyListeners();
  }

  Future<void> setAnalyzeExistingPhotos(bool value) async {
    _analyzeExistingPhotos = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefAnalyzeExisting, value);
    notifyListeners();
  }
}
