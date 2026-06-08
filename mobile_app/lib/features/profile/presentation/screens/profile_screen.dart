import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../providers/profile_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final profile = profileProvider.activeProfile;
    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Title
                const Text(
                  'My Space',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.softWhite),
                ),
                const SizedBox(height: 30),

                // Active Profile Avatar
                if (profile != null) ...[
                  CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(profile.avatarUrl),
                  ).animate().scaleXY(
                      begin: 0.8,
                      end: 1.0,
                      duration: 400.ms,
                      curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.softWhite),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.silverAccent.withValues(alpha: 0.6)),
                  ),
                ],

                const SizedBox(height: 32),

                // Subscription Plan Ribbon
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/subscription'),
                  child: GlassCard(
                    padding: const EdgeInsets.all(18),
                    opacity: 0.1,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.premiumGradient,
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user?.subscriptionPlan.toUpperCase()} MEMBER',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.softWhite),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage subscriptions and billing info.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.silverAccent
                                        .withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppTheme.silverAccent),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Settings List Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.account_circle_outlined,
                        title: 'Switch Profile',
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/profiles'),
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.notifications_none_outlined,
                        title: 'Push Notifications',
                        trailing: Switch(
                          value: true,
                          activeThumbColor: AppTheme.royalPurple,
                          onChanged: (v) {},
                        ),
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.video_settings_outlined,
                        title: 'Playback Quality',
                        subtitle: 'Auto (Best Quality)',
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.language,
                        title: 'Language Preference',
                        subtitle: _getLanguageName(
                            profile?.languagePreference ?? 'en'),
                        onTap: () => _showLanguageDialog(
                            context, profileProvider, profile?.id),
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About VANIX',
                        subtitle: 'v1.0.0 Stable',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // Logout Button
                PremiumButton(
                  text: 'Sign Out Session',
                  height: 50,
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.royalPurple, size: 22),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.softWhite)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.silverAccent))
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        color: AppTheme.softWhite.withValues(alpha: 0.05),
        indent: 56);
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'te':
        return 'Telugu';
      case 'ta':
        return 'Tamil';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(
      BuildContext context, ProfileProvider provider, String? profileId) {
    if (profileId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardGrey,
          title: const Text('Select Language',
              style: TextStyle(color: AppTheme.softWhite)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                  context, provider, profileId, 'en', 'English'),
              _buildLanguageOption(
                  context, provider, profileId, 'te', 'Telugu'),
              _buildLanguageOption(context, provider, profileId, 'ta', 'Tamil'),
              _buildLanguageOption(context, provider, profileId, 'hi', 'Hindi'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, ProfileProvider provider,
      String profileId, String code, String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppTheme.softWhite)),
      trailing: provider.activeProfile?.languagePreference == code
          ? const Icon(Icons.check, color: AppTheme.royalPurple)
          : null,
      onTap: () async {
        await provider.updateProfile(profileId, languagePreference: code);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}
