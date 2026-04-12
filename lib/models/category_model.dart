import 'package:flutter/material.dart';
import '../config/theme.dart';

enum ScreenshotCategory {
  otp,
  payment,
  shopping,
  study,
  travel,
  meme,
  other;

  String get displayName {
    switch (this) {
      case ScreenshotCategory.otp:
        return 'OTP';
      case ScreenshotCategory.payment:
        return 'Payment';
      case ScreenshotCategory.shopping:
        return 'Shopping';
      case ScreenshotCategory.study:
        return 'Study';
      case ScreenshotCategory.travel:
        return 'Travel';
      case ScreenshotCategory.meme:
        return 'Meme';
      case ScreenshotCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case ScreenshotCategory.otp:
        return AppTheme.otpColor;
      case ScreenshotCategory.payment:
        return AppTheme.paymentColor;
      case ScreenshotCategory.shopping:
        return AppTheme.shoppingColor;
      case ScreenshotCategory.study:
        return AppTheme.studyColor;
      case ScreenshotCategory.travel:
        return AppTheme.travelColor;
      case ScreenshotCategory.meme:
        return AppTheme.memeColor;
      case ScreenshotCategory.other:
        return AppTheme.otherColor;
    }
  }

  IconData get icon {
    switch (this) {
      case ScreenshotCategory.otp:
        return Icons.lock_outline;
      case ScreenshotCategory.payment:
        return Icons.payment;
      case ScreenshotCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ScreenshotCategory.study:
        return Icons.school_outlined;
      case ScreenshotCategory.travel:
        return Icons.flight_outlined;
      case ScreenshotCategory.meme:
        return Icons.emoji_emotions_outlined;
      case ScreenshotCategory.other:
        return Icons.image_outlined;
    }
  }

  /// Parse from either enum name ("otp") or displayName ("OTP", "Payment")
  static ScreenshotCategory fromString(String? value) {
    if (value == null || value.trim().isEmpty) return ScreenshotCategory.other;
    final v = value.trim().toLowerCase();
    return ScreenshotCategory.values.firstWhere(
      // Match against both: enum name (e.g. "otp") AND displayName (e.g. "OTP")
      (e) => e.name.toLowerCase() == v || e.displayName.toLowerCase() == v,
      orElse: () => ScreenshotCategory.other,
    );
  }
}
