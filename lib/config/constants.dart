class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Screenshot Organizer AI';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.rajib.screenshotai';

  // AdMob IDs (Setup for Production)
  static const String admobAppId = 'ca-app-pub-2426187083173713~6132429236'; 
  static const String bannerAdUnitId = 'ca-app-pub-2426187083173713/3000163158'; 
  static const String interstitialAdUnitId = 'ca-app-pub-2426187083173713/1642374094'; 

  // Free Tier Limits
  static const int freeMaxScans = 10000; // Effectively unlimited for free users
  static const int adsInterstitialInterval = 5; // Show interstitial every N detail views

  // Scanner Paths
  static const List<String> screenshotDirectories = [
    'Pictures/Screenshots',
    'DCIM/Screenshots',
    'Screenshots',
  ];

  // Background Task
  static const String backgroundTaskName = 'screenshot_scan_task';
  static const Duration backgroundTaskInterval = Duration(minutes: 15);

  // Database
  static const String databaseName = 'screenshot_organizer.db';
  static const int databaseVersion = 1;

  // Category Keywords
  static const Map<String, List<String>> categoryKeywords = {
    'OTP': [
      'otp', 'verification code', 'one time password', 'verify',
      'verification', 'one-time', 'authenticate', 'security code',
      'login code', '2fa', 'two factor', 'passcode',
    ],
    'Payment': [
      'upi', 'payment', 'paid', 'transaction', 'credited', 'debited',
      'bank', 'transfer', 'rupees', 'inr', '₹', 'wallet', 'paytm',
      'phonepe', 'gpay', 'google pay', 'razorpay', 'successful',
      'amount', 'balance', 'receipt', 'invoice',
    ],
    'Shopping': [
      'amazon', 'flipkart', 'myntra', 'order', 'delivered', 'shipped',
      'tracking', 'dispatch', 'delivery', 'cart', 'purchase',
      'meesho', 'ajio', 'nykaa', 'order confirmed', 'order id',
      'estimated delivery', 'out for delivery',
    ],
    'Study': [
      'notes', 'chapter', 'exam', 'assignment', 'lecture', 'study',
      'syllabus', 'semester', 'question', 'answer', 'formula',
      'theorem', 'definition', 'class', 'school', 'college',
      'university', 'homework', 'test', 'quiz', 'marks', 'grade',
    ],
    'Travel': [
      'flight', 'ticket', 'booking', 'pnr', 'train', 'bus',
      'irctc', 'boarding pass', 'departure', 'arrival', 'gate',
      'terminal', 'seat', 'confirmation', 'itinerary', 'hotel',
      'makemytrip', 'goibibo', 'redbus', 'uber', 'ola',
    ],
    'Meme': [], // Identified by low text content
  };

  // Shared Prefs Keys
  static const String prefFirstLaunch = 'first_launch';
  static const String prefScanCount = 'scan_count';
  static const String prefIsPremium = 'is_premium';
  static const String prefLastScanTime = 'last_scan_time';
  static const String prefAnalyzeExisting = 'analyze_existing_photos'; // Whether to scan old gallery on first run
  static const String prefDetailViewCount = 'detail_view_count';

  // Share watermark
  static const String shareWatermark = 'Organized by Screenshot AI';
}
