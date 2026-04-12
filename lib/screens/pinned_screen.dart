import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../config/theme.dart';
import '../providers/screenshot_provider.dart';
import '../widgets/screenshot_card.dart';

class PinnedScreen extends StatefulWidget {
  const PinnedScreen({super.key});

  @override
  State<PinnedScreen> createState() => _PinnedScreenState();
}

class _PinnedScreenState extends State<PinnedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScreenshotProvider>().loadPinnedScreenshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: AppTheme.warningColor),
            SizedBox(width: 8),
            Text('Important'),
          ],
        ),
      ),
      body: Consumer<ScreenshotProvider>(
        builder: (context, provider, _) {
          if (provider.pinnedScreenshots.isEmpty) {
            return _buildEmptyState();
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: provider.pinnedScreenshots.length,
            itemBuilder: (context, index) {
              final screenshot = provider.pinnedScreenshots[index];
              final height = 180.0 + (index % 3) * 40;
              return SizedBox(
                height: height,
                child: ScreenshotCard(
                  screenshot: screenshot,
                  onTap: () {
                    // TODONav
                  },
                ),
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
          Icon(Icons.star_outline_rounded, size: 80, color: AppTheme.warningColor.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text('No Pinned Screenshots', style: AppTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Tap the ⭐ on any screenshot to see it here', 
               style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}
