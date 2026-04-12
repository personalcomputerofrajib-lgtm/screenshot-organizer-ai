import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/pinned_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/category_screen.dart';
import '../screens/screenshot_detail_screen.dart';
import '../models/category_model.dart';
import '../models/screenshot_model.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String search = '/search';
  static const String category = '/category';
  static const String screenshotDetail = '/screenshot-detail';
  static const String timeline = '/timeline';
  static const String pinned = '/pinned';
  static const String otp = '/otp';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        onboarding: (context) => const OnboardingScreen(),
        home: (context) => const HomeScreen(),
        search: (context) => const SearchScreen(),
        timeline: (context) => const TimelineScreen(),
        pinned: (context) => const PinnedScreen(),
        otp: (context) => const OtpScreen(),
        settings: (context) => const SettingsScreen(),
      };

  /// Navigate to category screen
  static void goToCategory(BuildContext context, ScreenshotCategory cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(category: cat),
      ),
    );
  }

  /// Navigate to screenshot detail screen
  static void goToDetail(BuildContext context, ScreenshotModel screenshot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScreenshotDetailScreen(screenshot: screenshot),
      ),
    );
  }
}