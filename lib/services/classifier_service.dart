import '../config/constants.dart';

class ClassifierService {
  static final ClassifierService _instance = ClassifierService._internal();
  factory ClassifierService() => _instance;
  ClassifierService._internal();

  /// Classify extracted text into a category.
  /// Returns the best matching category name.
  String classify(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return 'Photo/Meme'; // Zero text = likely a photo
    }

    final lowerText = trimmedText.toLowerCase();
    
    // Check for "Photo/Meme" first if text is extremely short
    if (trimmedText.length < 15) {
      return 'Photo/Meme';
    }

    final scores = <String, int>{};

    // Score each category by counting keyword matches with weights
    for (final entry in AppConstants.categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;

      if (keywords.isEmpty) continue;

      int score = 0;
      for (final keyword in keywords) {
        final kw = keyword.toLowerCase();
        if (lowerText.contains(kw)) {
          // Weighted scoring
          if (category == 'Crypto' && (kw == 'binance' || kw == 'bitcoin' || kw == 'wallet')) {
            score += 10; // High confidence for main crypto terms
          } else if (category == 'OTP' && (kw == 'otp' || kw == 'verification code')) {
            score += 8;
          } else if (kw.length > 6) {
            score += 3; // Longer words = more specific
          } else {
            score += 1;
          }
        }
      }

      if (score > 0) {
        scores[category] = score;
      }
    }

    if (scores.isEmpty) {
      // If fairly long text but no keywords match, it's "Other"
      return trimmedText.length > 100 ? 'Other' : 'Photo/Meme';
    }

    // Collision Resolution: Crypto/Finance vs OTP
    // Often crypto apps have 2FA/OTPs. If we see both, 
    // prioritize the actual app purpose (Crypto/Finance) unless OTP score is massive.
    if (scores.containsKey('Crypto') && scores.containsKey('OTP')) {
      if (scores['Crypto']! >= 5) scores.remove('OTP');
    }
    
    if (scores.containsKey('Finance') && scores.containsKey('OTP')) {
       if (scores['Finance']! >= 5) scores.remove('OTP');
    }

    // Return the category with the highest score
    final bestCategory = scores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return bestCategory;
  }

  /// Get confidence score for a classification (0.0 to 1.0)
  double getConfidence(String text, String category) {
    if (text.trim().isEmpty) return 0.5;

    final keywords = AppConstants.categoryKeywords[category];
    if (keywords == null || keywords.isEmpty) return 0.3;

    final lowerText = text.toLowerCase();
    int matched = 0;
    for (final keyword in keywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        matched++;
      }
    }

    // More keyword matches = higher confidence
    final maxRelevant = keywords.length.clamp(1, 10);
    return (matched / maxRelevant).clamp(0.0, 1.0);
  }

  /// Check if text is likely an OTP screenshot
  bool isOtp(String text) {
    final lowerText = text.toLowerCase();
    final otpKeywords = AppConstants.categoryKeywords['OTP'] ?? [];
    
    // Must have at least one OTP keyword
    bool hasKeyword = otpKeywords.any(
      (keyword) => lowerText.contains(keyword.toLowerCase()),
    );

    // OTPs often contain 4-8 digit numbers
    final otpPattern = RegExp(r'\b\d{4,8}\b');
    bool hasOtpNumber = otpPattern.hasMatch(text);

    return hasKeyword && hasOtpNumber;
  }

  /// Suggest multiple potential categories with scores
  List<CategorySuggestion> suggestCategories(String text) {
    final suggestions = <CategorySuggestion>[];

    for (final entry in AppConstants.categoryKeywords.entries) {
      final confidence = getConfidence(text, entry.key);
      if (confidence > 0) {
        suggestions.add(CategorySuggestion(
          category: entry.key,
          confidence: confidence,
        ));
      }
    }

    // Add Meme if text is very short
    if (text.trim().length < 20) {
      suggestions.add(CategorySuggestion(
        category: 'Meme',
        confidence: 0.6,
      ));
    }

    // Sort by confidence descending
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Always have at least one suggestion
    if (suggestions.isEmpty) {
      suggestions.add(CategorySuggestion(
        category: 'Other',
        confidence: 0.1,
      ));
    }

    return suggestions;
  }
}

class CategorySuggestion {
  final String category;
  final double confidence;

  CategorySuggestion({
    required this.category,
    required this.confidence,
  });

  @override
  String toString() => '$category (${(confidence * 100).toStringAsFixed(0)}%)';
}
