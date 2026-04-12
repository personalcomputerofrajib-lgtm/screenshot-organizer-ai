import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../config/theme.dart';
import '../config/routes.dart';
import '../models/category_model.dart';
import '../providers/screenshot_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/screenshot_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScreenshotProvider>().loadScreenshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.surfaceColor,
                onRefresh: () async {
                  await context.read<ScreenshotProvider>().loadScreenshots();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchSection(context),
                      _buildScanProgress(context),
                      _buildStatsRow(context),
                      const SizedBox(height: 24),
                      _buildCategories(context),
                      const SizedBox(height: 8),
                      _buildRecentScreenshots(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer2<ScreenshotProvider, SettingsProvider>(
        builder: (context, provider, settings, _) {
          return FloatingActionButton.extended(
            onPressed: provider.isScanning
                ? null
                : () => provider.startScan(
                      analyzeExisting: settings.analyzeExistingPhotos,
                    ),
            backgroundColor:
                provider.isScanning ? AppTheme.surfaceColor : AppTheme.primaryColor,
            elevation: 8,
            icon: provider.isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : const Icon(Icons.document_scanner_outlined, size: 22),
            label: Text(
              provider.isScanning ? 'Scanning…' : 'Scan Now',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────── App Bar ────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Photo Analyser AI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Hey, ${user?.displayName?.split(' ').first ?? 'there'} 👋',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded,
                color: AppTheme.textSecondary, size: 22),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.timeline),
            tooltip: 'Timeline',
          ),
          IconButton(
            icon: const Icon(Icons.star_border_rounded,
                color: AppTheme.textSecondary, size: 22),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.pinned),
            tooltip: 'Pinned',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppTheme.textSecondary, size: 22),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Search ─────────────────────────────────────────
  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SearchBarWidget(
        readOnly: true,
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      ),
    );
  }

  // ─────────────────────────── Scan progress indicator ────────────────────────
  Widget _buildScanProgress(BuildContext context) {
    return Consumer<ScreenshotProvider>(
      builder: (context, provider, _) {
        // Error banner
        if (!provider.isScanning && provider.error != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(provider.error!,
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.errorColor)),
                  ),
                  GestureDetector(
                    onTap: provider.clearError,
                    child: const Icon(Icons.close,
                        color: AppTheme.errorColor, size: 18),
                  ),
                ],
              ),
            ),
          );
        }

        if (!provider.isScanning) return const SizedBox.shrink();

        final hasTotal = provider.scanTotal > 0;
        final progress = hasTotal ? provider.scanProgress / provider.scanTotal : 0.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1640), Color(0xFF161B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.document_scanner,
                          color: AppTheme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('AI Scanning',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          )),
                    ),
                    if (hasTotal)
                      Text(
                        '${provider.scanProgress}/${provider.scanTotal}',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                ),
                if (provider.scanStatus.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(provider.scanStatus,
                      style: AppTheme.bodySmall
                          .copyWith(color: AppTheme.textSecondary)),
                ],
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: hasTotal
                      ? LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor:
                              AppTheme.borderColor.withValues(alpha: 0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        )
                      : LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor:
                              AppTheme.borderColor.withValues(alpha: 0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────── Stats row ──────────────────────────────────────
  Widget _buildStatsRow(BuildContext context) {
    return Consumer<ScreenshotProvider>(builder: (context, provider, _) {
      if (provider.isLoading || provider.totalCount == 0) {
        return const SizedBox(height: 0);
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            _StatCard(
              label: 'Organised',
              value: provider.totalCount.toString(),
              icon: Icons.check_circle_outline,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Categories',
              value: provider.categoryCounts.length.toString(),
              icon: Icons.category_outlined,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Pinned',
              value: provider.pinnedScreenshots.length.toString(),
              icon: Icons.star_outline_rounded,
              color: AppTheme.warningColor,
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────── Categories ─────────────────────────────────────
  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categories', style: AppTheme.headlineSmall),
        ),
        const SizedBox(height: 14),
        Consumer<ScreenshotProvider>(
          builder: (context, provider, _) {
            final counts = provider.categoryCounts;
            final cats = ScreenshotCategory.values
                .where((cat) => cat != ScreenshotCategory.other)
                .toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: cats.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(
                      category: cat,
                      count: counts[cat.displayName] ?? 0,
                      onTap: () {
                        // OTP has its own dedicated screen
                        if (cat == ScreenshotCategory.otp) {
                          Navigator.pushNamed(context, AppRoutes.otp);
                        } else {
                          // All other categories use CategoryScreen
                          AppRoutes.goToCategory(context, cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────── Recent screenshots ──────────────────────────────
  Widget _buildRecentScreenshots(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent', style: AppTheme.headlineSmall),
                Consumer<ScreenshotProvider>(
                  builder: (context, provider, _) {
                    if (provider.totalCount > 0) {
                      return Text(
                        '${provider.totalCount} total',
                        style:
                            AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Consumer<ScreenshotProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) return _buildShimmerGrid();

              if (provider.screenshots.isEmpty) {
                return _buildEmptyState(context);
              }

              final items = provider.screenshots.length > 30
                  ? provider.screenshots.sublist(0, 30)
                  : provider.screenshots;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final screenshot = items[index];
                    final height = 170.0 + (index % 4) * 30;
                    return SizedBox(
                      height: height,
                      child: ScreenshotCard(
                        screenshot: screenshot,
                        onTap: () =>
                            AppRoutes.goToDetail(context, screenshot),
                        onLongPress: () {
                          // Long press to pin
                          context
                              .read<ScreenshotProvider>()
                              .togglePin(screenshot);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          final height = 170.0 + (index % 4) * 30;
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Consumer<ScreenshotProvider>(
      builder: (context, provider, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(Icons.document_scanner_outlined,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('No screenshots yet',
                  style: AppTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text(
                'Tap "Scan Now" below to find and organise all your screenshots using AI.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: provider.isScanning
                    ? null
                    : () => provider.startScan(analyzeExisting: true),
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Scan Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────── Stat card widget ───────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(label, style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}