import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/theme.dart';
import '../models/screenshot_model.dart';
import '../models/category_model.dart';
import '../providers/screenshot_provider.dart';

class ScreenshotDetailScreen extends StatefulWidget {
  final ScreenshotModel screenshot;

  const ScreenshotDetailScreen({super.key, required this.screenshot});

  @override
  State<ScreenshotDetailScreen> createState() => _ScreenshotDetailScreenState();
}

class _ScreenshotDetailScreenState extends State<ScreenshotDetailScreen> {
  late ScreenshotModel _screenshot;

  @override
  void initState() {
    super.initState();
    _screenshot = widget.screenshot;
  }

  void _copyText() {
    if (_screenshot.extractedText == null) return;
    
    Clipboard.setData(ClipboardData(text: _screenshot.extractedText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareContent() async {
    try {
      final file = XFile(_screenshot.imagePath);
      final text = 'Organized by Photo Analyser AI\n\n${_screenshot.extractedText ?? ""}';
      
      await Share.shareXFiles(
        [file],
        text: text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share image')),
      );
    }
  }

  void _togglePin() async {
    final provider = context.read<ScreenshotProvider>();
    await provider.togglePin(_screenshot);
    setState(() {
      _screenshot = _screenshot.copyWith(isPinned: !_screenshot.isPinned);
    });
  }

  void _deleteScreenshot() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Screenshot?'),
        content: const Text('This will remove the screenshot from the organizer app, but not from your device gallery.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<ScreenshotProvider>().deleteScreenshot(_screenshot.id!);
      Navigator.pop(context);
    }
  }

  void _editCategory() async {
    final currentCat = ScreenshotCategory.fromString(_screenshot.category);
    
    final newCategory = await showModalBottomSheet<ScreenshotCategory>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Change Category', style: AppTheme.headlineSmall),
              ),
              const SizedBox(height: 16),
              ...ScreenshotCategory.values.where((c) => c != ScreenshotCategory.other).map((cat) {
                return ListTile(
                  leading: Icon(cat.icon, color: cat.color),
                  title: Text(cat.displayName),
                  trailing: currentCat == cat ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                  onTap: () => Navigator.pop(context, cat),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (newCategory != null && mounted) {
      await context.read<ScreenshotProvider>().updateCategory(
        _screenshot.id!,
        newCategory.displayName,
      );
      setState(() {
        _screenshot = _screenshot.copyWith(category: newCategory.displayName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = ScreenshotCategory.fromString(_screenshot.category);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _screenshot.isPinned ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _screenshot.isPinned ? AppTheme.warningColor : AppTheme.textSecondary,
              size: 28,
            ),
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareContent,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
            onPressed: _deleteScreenshot,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-Screen Immersive Image Viewer
              GestureDetector(
                onDoubleTap: () {
                  // Future: Toggle zoom or full-screen overlay
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  // Remove the 0.45 height restriction - allow full view
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 6.0, // Increased zoom depth
                    child: Hero(
                      tag: 'screenshot_${_screenshot.id}',
                      child: Image.file(
                        File(_screenshot.imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tag and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _editCategory,
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: cat.color.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 16, color: cat.color),
                                const SizedBox(width: 8),
                                Text(
                                  cat.displayName,
                                  style: TextStyle(
                                    color: cat.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.edit, size: 14, color: cat.color),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(_screenshot.dateTaken ?? _screenshot.dateAdded),
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Extract Text Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.text_format_rounded, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text('Extracted Text', style: AppTheme.headlineSmall),
                          ],
                        ),
                        if (_screenshot.extractedText?.isNotEmpty ?? false)
                          TextButton.icon(
                            onPressed: _copyText,
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Text Content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: SelectableText(
                        _screenshot.extractedText?.trim().isNotEmpty == true
                            ? _screenshot.extractedText!
                            : 'No recognizable text found in this image.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: _screenshot.extractedText?.trim().isNotEmpty == true
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
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

  String _formatDate(DateTime date) {
    // Basic formatting without intl package for brevity
    return '${date.day}/${date.month}/${date.year}';
  }
}