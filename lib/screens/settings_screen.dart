import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/premium_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person, color: AppTheme.primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: AppTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader('Account & Premium'),
          
          // Premium CTA (V1.1 feature placeholder)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Unlimited scans, no ads, auto-detect duplicates.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildSectionHeader('Scanning & Processing'),
          SwitchListTile(
            title: const Text('Background Auto-Scan'),
            subtitle: const Text('Automatically find and process new screenshots in background'),
            value: settings.autoScan,
            onChanged: (val) => context.read<SettingsProvider>().setAutoScan(val),
            activeColor: AppTheme.primaryColor,
            secondary: const Icon(Icons.autorenew),
          ),
          SwitchListTile(
            title: const Text('Analyse Existing Photos'),
            subtitle: const Text(
                'When ON: scans your whole gallery. When OFF: only scans new screenshots taken after install.'),
            value: settings.analyzeExistingPhotos,
            onChanged: (val) =>
                context.read<SettingsProvider>().setAnalyzeExistingPhotos(val),
            activeColor: AppTheme.primaryColor,
            secondary: const Icon(Icons.photo_library_outlined),
          ),
          FutureBuilder<int>(
            future: PremiumService().getRemainingScans(),
            builder: (context, snapshot) {
              final remaining = snapshot.data ?? 0;
              final isPremium = remaining == -1; // -1 means unlimited
              return ListTile(
                leading: const Icon(Icons.stacked_bar_chart),
                title: const Text('Free Scans Remaining'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isPremium ? 'Unlimited' : remaining.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPremium ? AppTheme.warningColor : AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const Divider(height: 32),
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.star_rate_rounded, color: AppTheme.warningColor),
            title: const Text('Rate Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO google play review action
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('Share App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO share intent
            },
          ),
          ListTile(
             leading: const Icon(Icons.privacy_tip_outlined),
             title: const Text('Privacy Policy'),
             trailing: const Icon(Icons.chevron_right),
             onTap: () async {
               final url = Uri.parse('https://policies.google.com/privacy');
               if (await canLaunchUrl(url)) {
                 await launchUrl(url);
               }
             },
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Screenshot AI v1.0.0',
                style: AppTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}