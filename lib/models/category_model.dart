import 'package:flutter/material.dart';
import '../config/theme.dart';

enum ScreenshotCategory {
  otp,
  payment,
  finance,
  crypto,
  shopping,
  study,
  code,
  document,
  receipt,
  social,
  travel,
  meme_photo,
  other;

  String get displayName {
    switch (this) {
      case ScreenshotCategory.otp: return 'OTP';
      case ScreenshotCategory.payment: return 'Payment';
      case ScreenshotCategory.finance: return 'Finance';
      case ScreenshotCategory.crypto: return 'Crypto';
      case ScreenshotCategory.shopping: return 'Shopping';
      case ScreenshotCategory.study: return 'Study';
      case ScreenshotCategory.code: return 'Code';
      case ScreenshotCategory.document: return 'Document';
      case ScreenshotCategory.receipt: return 'Receipt';
      case ScreenshotCategory.social: return 'Social';
      case ScreenshotCategory.travel: return 'Travel';
      case ScreenshotCategory.meme_photo: return 'Photo/Meme';
      case ScreenshotCategory.other: return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case ScreenshotCategory.otp: return AppTheme.otpColor;
      case ScreenshotCategory.payment: return AppTheme.paymentColor;
      case ScreenshotCategory.finance: return AppTheme.financeColor;
      case ScreenshotCategory.crypto: return AppTheme.cryptoColor;
      case ScreenshotCategory.shopping: return AppTheme.shoppingColor;
      case ScreenshotCategory.study: return AppTheme.studyColor;
      case ScreenshotCategory.code: return AppTheme.codeColor;
      case ScreenshotCategory.document: return AppTheme.documentColor;
      case ScreenshotCategory.receipt: return AppTheme.receiptColor;
      case ScreenshotCategory.social: return AppTheme.socialColor;
      case ScreenshotCategory.travel: return AppTheme.travelColor;
      case ScreenshotCategory.meme_photo: return AppTheme.memeColor;
      case ScreenshotCategory.other: return AppTheme.otherColor;
    }
  }

  IconData get icon {
    switch (this) {
      case ScreenshotCategory.otp: return Icons.lock_outline;
      case ScreenshotCategory.payment: return Icons.payment;
      case ScreenshotCategory.finance: return Icons.account_balance_outlined;
      case ScreenshotCategory.crypto: return Icons.currency_bitcoin_outlined;
      case ScreenshotCategory.shopping: return Icons.shopping_bag_outlined;
      case ScreenshotCategory.study: return Icons.school_outlined;
      case ScreenshotCategory.code: return Icons.code_outlined;
      case ScreenshotCategory.document: return Icons.description_outlined;
      case ScreenshotCategory.receipt: return Icons.receipt_long_outlined;
      case ScreenshotCategory.social: return Icons.chat_bubble_outline;
      case ScreenshotCategory.travel: return Icons.flight_outlined;
      case ScreenshotCategory.meme_photo: return Icons.image_outlined;
      case ScreenshotCategory.other: return Icons.auto_awesome_mosaic_outlined;
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
