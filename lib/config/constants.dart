class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Photo Analyser AI';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.rajib.photoanalyserai';

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
      'login code', '2fa', 'two factor', 'passcode', 'credential',
    ],
    'Payment': [
      'upi', 'payment', 'paid', 'transaction', 'credited', 'debited',
      'transfer', 'rupees', 'inr', '₹', 'receipt', 'invoice',
      'successful', 'amount', 'balance', 'checkout', 'billing',
    ],
    'Finance': [
      'bank', 'account', 'statement', 'investment', 'stocks', 'mutual fund',
      'equity', 'portfolio', 'salary', 'credit card', 'debit card', 'limit',
      'interest', 'tax', 'income', 'expense', 'loan', 'mortgage',
      'savings', 'fixed deposit', 'zerodha', 'groww', 'upstox',
    ],
    'Crypto': [
      'crypto', 'binance', 'coinbase', 'wallet', 'bitcoin', 'btc', 'eth',
      'ethereum', 'solana', 'usdt', 'withdraw', 'deposit', 'trade', 'spot',
      'futures', 'kucoin', 'trustwallet', 'metamask', 'blockchain', 'ledger',
      'p2p', 'exchange', 'hashing', 'mining',
    ],
    'Shopping': [
      'amazon', 'flipkart', 'myntra', 'order', 'delivered', 'shipped',
      'tracking', 'dispatch', 'delivery', 'cart', 'purchase',
      'meesho', 'ajio', 'nykaa', 'order confirmed', 'order id',
      'estimated delivery', 'out for delivery', 'wishlist',
    ],
    'Study': [
      'notes', 'chapter', 'exam', 'assignment', 'lecture', 'study',
      'syllabus', 'semester', 'question', 'answer', 'formula',
      'theorem', 'definition', 'class', 'school', 'college',
      'university', 'homework', 'test', 'quiz', 'marks', 'grade',
      'lesson', 'textbook', 'pdf', 'slide',
    ],
    'Code': [
      'import', 'class', 'function', 'void', 'string', 'int', 'return',
      'static', 'final', 'const', 'public', 'private', 'git', 'github',
      'commit', 'push', 'pull', 'terminal', 'bash', 'console', 'log',
      'print', 'if', 'else', 'for', 'while', 'null', 'undefined',
      'syntax', 'error', 'bug', 'patch', 'repo', 'branch',
    ],
    'Document': [
      'aadhar', 'identity', 'passport', 'license', 'driving', 'pan card',
      'voter', 'government', 'certificate', 'legal', 'contract',
      'agreement', 'resume', 'cv', 'application', 'official',
    ],
    'Receipt': [
      'bill', 'receipt', 'tax invoice', 'total', 'subtotal', 'merchant',
      'store', 'grocery', 'restaurant', 'cafe', 'order summary',
    ],
    'Social': [
      'whatsapp', 'instagram', 'facebook', 'twitter', 'x', 'telegram',
      'message', 'chat', 'direct', 'follower', 'following', 'like',
      'comment', 'story', 'reel', 'post', 'dm',
    ],
    'Travel': [
      'flight', 'ticket', 'booking', 'pnr', 'train', 'bus',
      'irctc', 'boarding pass', 'departure', 'arrival', 'gate',
      'terminal', 'seat', 'confirmation', 'itinerary', 'hotel',
      'makemytrip', 'goibibo', 'redbus', 'uber', 'ola', 'check-in',
    ],
    'Photo/Meme': [], // Fallback for images with little text
  };

  // Shared Prefs Keys
  static const String prefFirstLaunch = 'first_launch';
  static const String prefScanCount = 'scan_count';
  static const String prefIsPremium = 'is_premium';
  static const String prefLastScanTime = 'last_scan_time';
  static const String prefAnalyzeExisting = 'analyze_existing_photos'; // Whether to scan old gallery on first run
  static const String prefDetailViewCount = 'detail_view_count';

  // Share watermark
  static const String shareWatermark = 'Organized by Photo Analyser AI';
}
