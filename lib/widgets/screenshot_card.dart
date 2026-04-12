import 'dart:io';
import 'package:flutter/material.dart';
import '../models/screenshot_model.dart';
import '../models/category_model.dart';
import '../config/theme.dart';

class ScreenshotCard extends StatelessWidget {
  final ScreenshotModel screenshot;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showCategory;

  const ScreenshotCard({
    super.key,
    required this.screenshot,
    required this.onTap,
    this.onLongPress,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final cat = ScreenshotCategory.fromString(screenshot.category);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image (downsampled to prevent OOM memory leak crashes)
            Image.file(
              File(screenshot.imagePath),
              fit: BoxFit.cover,
              cacheWidth: 400, // Downscale image in RAM
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.surfaceColor,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppTheme.textTertiary,
                  size: 32,
                ),
              ),
            ),

            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Pin badge
            if (screenshot.isPinned)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                ),
              ),

            // Category tag
            if (showCategory && screenshot.category != null && cat != ScreenshotCategory.other)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    cat.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
