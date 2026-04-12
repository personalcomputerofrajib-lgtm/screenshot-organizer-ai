import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/constants.dart';
import '../services/premium_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User choice: whether to scan existing gallery photos
  bool _analyzeExisting = true;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      icon: Icons.document_scanner_outlined,
      iconColor: AppTheme.primaryColor,
      title: 'Auto Scan',
      subtitle:
          'Automatically detects and reads all your screenshots using powerful AI-based OCR technology.',
      gradient: [AppTheme.primaryColor, AppTheme.primaryLight],
    ),
    const _OnboardingPage(
      icon: Icons.search_rounded,
      iconColor: AppTheme.secondaryColor,
      title: 'Smart Search',
      subtitle:
          'Search your screenshots by text content. Find that Amazon order, UPI payment, or OTP in seconds.',
      gradient: [AppTheme.secondaryColor, Color(0xFF00B4D8)],
    ),
    const _OnboardingPage(
      icon: Icons.auto_awesome,
      iconColor: AppTheme.accentColor,
      title: 'AI Categories',
      subtitle:
          'Screenshots are automatically sorted into OTP, Payment, Shopping, Study, Travel, and more.',
      gradient: [AppTheme.accentColor, Color(0xFFFF8FA3)],
    ),
    const _OnboardingPage(
      icon: Icons.photo_library_outlined,
      iconColor: Color(0xFF43E97B),
      title: 'Existing Photos',
      subtitle:
          'Should the app analyse your existing gallery screenshots, or only new ones you take from now on?',
      gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)],
      isChoicePage: true, // Special page with toggle
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    // Save the user's "analyze existing" preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefAnalyzeExisting, _analyzeExisting);

    await PremiumService().setFirstLaunchDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button (hidden on choice page)
              Align(
                alignment: Alignment.topRight,
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _pages.length - 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Skip',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon container
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: page.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(
                                  color: page.gradient[0].withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Title
                          Text(
                            page.title,
                            style: AppTheme.headlineLarge.copyWith(fontSize: 30),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            page.subtitle,
                            style: AppTheme.bodyLarge.copyWith(height: 1.6),
                            textAlign: TextAlign.center,
                          ),

                          // Choice toggle — only on the last page
                          if (page.isChoicePage) ...[
                            const SizedBox(height: 32),
                            _buildAnalyzeToggle(),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          _ToggleOption(
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF43E97B),
            title: 'Scan existing screenshots',
            subtitle: 'Analyse all screenshots already in your gallery',
            selected: _analyzeExisting,
            onTap: () => setState(() => _analyzeExisting = true),
          ),
          Divider(
            height: 1,
            color: AppTheme.borderColor.withValues(alpha: 0.5),
          ),
          _ToggleOption(
            icon: Icons.fiber_new_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'Only new screenshots',
            subtitle: 'Start fresh — only organise photos taken from now on',
            selected: !_analyzeExisting,
            onTap: () => setState(() => _analyzeExisting = false),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: selected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppTheme.primaryColor
                      : AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final bool isChoicePage;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.isChoicePage = false,
  });
}