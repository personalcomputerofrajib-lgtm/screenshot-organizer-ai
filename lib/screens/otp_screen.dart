import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/screenshot_provider.dart';
import '../widgets/screenshot_card.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use category search trick
      context.read<ScreenshotProvider>().getByCategory('OTP');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.otpColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_outline, color: AppTheme.otpColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('OTP Finder'),
          ],
        ),
      ),
      body: Consumer<ScreenshotProvider>(
        builder: (context, provider, _) {
          return FutureBuilder(
            future: provider.getByCategory('OTP'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final items = snapshot.data ?? [];
              
              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final screenshot = items[index];
                  // Try to find the actual code in text for prominent display
                  final text = screenshot.extractedText ?? '';
                  final otpMatch = RegExp(r'\b\d{4,8}\b').firstMatch(text);
                  final code = otpMatch?.group(0);
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        // Small image thumbnail
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppTheme.radiusMd),
                              bottomLeft: Radius.circular(AppTheme.radiusMd),
                            ),
                            child: ScreenshotCard(
                              screenshot: screenshot,
                              showCategory: false,
                              onTap: () {},
                            ),
                          ),
                        ),
                        // Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (code != null) ...[
                                  Text(
                                    code,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.otpColor,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_open, size: 80, color: AppTheme.otpColor.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text('No OTPs Found', style: AppTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('AI will organize OTP screenshots here', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}
