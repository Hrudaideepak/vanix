import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile_model.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isKidsSelected = false;

  @override
  void dispose() {
    _pinController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleProfileSelect(
      ProfileModel profile, ProfileProvider provider) async {
    if (profile.pin != null) {
      // Prompt for PIN
      _showPinDialog(profile, provider);
    } else {
      final success = await provider.selectProfile(profile);
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _showPinDialog(ProfileModel profile, ProfileProvider provider) {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardGrey,
          title: Text('Enter PIN for ${profile.name}',
              style: const TextStyle(color: AppTheme.softWhite)),
          content: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            style: const TextStyle(
                color: AppTheme.softWhite, fontSize: 24, letterSpacing: 8),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: '',
              hintText: '••••',
              hintStyle: TextStyle(color: Colors.white24),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.silverAccent)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalPurple),
              child: const Text('Unlock'),
              onPressed: () async {
                final dialogContext = context;
                final success = await provider.selectProfile(profile,
                    pinInput: _pinController.text);
                if (mounted && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success && mounted) {
                    Navigator.pushReplacementNamed(this.context, '/home');
                  } else if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                          content: Text('Incorrect Profile PIN'),
                          backgroundColor: AppTheme.errorRed),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateProfileDialog(ProfileProvider provider) {
    _nameController.clear();
    _isKidsSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardGrey,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create Profile',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.softWhite)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.softWhite),
                    decoration: const InputDecoration(
                      hintText: 'Profile Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Parental Control (Kids Space)',
                          style: TextStyle(color: AppTheme.silverAccent)),
                      Switch(
                        value: _isKidsSelected,
                        activeThumbColor: AppTheme.royalPurple,
                        onChanged: (val) {
                          setModalState(() {
                            _isKidsSelected = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PremiumButton(
                    text: 'Save Profile',
                    isLoading: provider.isLoading,
                    onTap: () async {
                      if (_nameController.text.trim().isEmpty) return;
                      final dialogContext = context;
                      final success = await provider.createProfile(
                        _nameController.text.trim(),
                        isKids: _isKidsSelected,
                      );
                      if (success && mounted && dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Who's Watching?",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0.0),

              const SizedBox(height: 48),

              // Profiles Grid
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                  ),
                  itemCount: profileProvider.profiles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == profileProvider.profiles.length) {
                      // "Add Profile" card
                      return GestureDetector(
                        onTap: () => _showCreateProfileDialog(profileProvider),
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.softWhite.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.softWhite
                                        .withValues(alpha: 0.08)),
                              ),
                              child: const Icon(Icons.add,
                                  color: AppTheme.royalPurple, size: 40),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Add Profile',
                              style: TextStyle(
                                  color: AppTheme.silverAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }

                    final profile = profileProvider.profiles[index];
                    return GestureDetector(
                      onTap: () =>
                          _handleProfileSelect(profile, profileProvider),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.royalPurple
                                          .withValues(alpha: 0.4),
                                      width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    profile.avatarUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (profile.pin != null)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.lock,
                                        color: AppTheme.royalPurple, size: 12),
                                  ),
                                ),
                              if (profile.isKids)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.electricBlue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('KIDS',
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              color: AppTheme.softWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
