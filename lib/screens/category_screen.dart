import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../config/theme.dart';
import '../config/routes.dart';
import '../models/category_model.dart';
import '../models/screenshot_model.dart';
import '../providers/screenshot_provider.dart';
import '../widgets/screenshot_card.dart';

class CategoryScreen extends StatefulWidget {
  final ScreenshotCategory category;
  
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<ScreenshotModel> _screenshots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreenshots();
  }

  Future<void> _loadScreenshots() async {
    setState(() => _isLoading = true);
    final provider = context.read<ScreenshotProvider>();
    final items = await provider.getByCategory(widget.category.displayName);
    if (!mounted) return;
    
    setState(() {
      _screenshots = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.category.icon, color: widget.category.color, size: 24),
            const SizedBox(width: 12),
            Text(widget.category.displayName),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading 
            ? _buildShimmerGrid()
            : _screenshots.isEmpty
                ? _buildEmptyState()
                : _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      color: widget.category.color,
      backgroundColor: AppTheme.surfaceColor,
      onRefresh: _loadScreenshots,
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _screenshots.length,
        itemBuilder: (context, index) {
          final screenshot = _screenshots[index];
          final height = 180.0 + (index % 3) * 40;
          return SizedBox(
            height: height,
            child: ScreenshotCard(
              screenshot: screenshot,
              showCategory: false,
              onTap: () => AppRoutes.goToDetail(context, screenshot),
            ),
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
          Icon(
            widget.category.icon,
            size: 80,
            color: widget.category.color.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${widget.category.displayName} screenshots',
            style: AppTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan more screenshots to see them here',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: 8,
      itemBuilder: (context, index) {
        final height = 180.0 + (index % 3) * 40;
        return Shimmer.fromColors(
          baseColor: AppTheme.surfaceColor,
          highlightColor: AppTheme.cardHoverColor,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
        );
      },
    );
  }
}
