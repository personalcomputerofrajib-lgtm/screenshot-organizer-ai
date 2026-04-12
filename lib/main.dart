import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/background_service.dart';
import 'providers/auth_provider.dart';
import 'providers/screenshot_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'config/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Critical orientation lock
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Orientation lock error: $e');
  }

  // 2. Initial Status Bar Setup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 3. Start App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScreenshotProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const ScreenshotOrganizerApp(),
    ),
  );

  // 4. Initialize secondary services post-launch (non-blocking)
  _initSecondaryServices();
}

Future<void> _initSecondaryServices() async {
  try {
    // Read user preference for background auto scan
    final prefs = await SharedPreferences.getInstance();
    final autoScan = prefs.getBool('auto_scan') ?? true;

    if (!autoScan) {
      debugPrint('[WorkManager] Background auto-scan is disabled by user.');
      return;
    }

    await Workmanager().initialize(
      backgroundDispatcher,
      isInDebugMode: false, // Set to true during development to see logs
    );

    // Register periodic background scan (minimum 15 min on Android)
    await Workmanager().registerPeriodicTask(
      'screenshot_scan',
      AppConstants.backgroundTaskName,
      frequency: AppConstants.backgroundTaskInterval,
      existingWorkPolicy: ExistingWorkPolicy.keep, // Don't replace if already queued
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false, // Allow when battery is low too
      ),
    );

    debugPrint('[WorkManager] Periodic scan task registered successfully.');
  } catch (e) {
    debugPrint('[WorkManager] Init error: $e');
  }
}