import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for 3 seconds of beautiful animation
    await Future.delayed(const Duration(milliseconds: 2800));
    
    if (!mounted) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/profiles');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient glow effect
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.royalPurple.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withValues(alpha: 0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Logo Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VANIX',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 62,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        foreground: Paint()
                          ..shader = AppTheme.premiumGradient.createShader(
                            const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                          ),
                      ),
                )
                    .animate()
                    .fadeIn(duration: 1000.ms)
                    .scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack, duration: 1000.ms)
                    .shimmer(delay: 1100.ms, duration: 1000.ms, color: Colors.white30),
                
                const SizedBox(height: 14),
                
                Text(
                  'Unlimited Entertainment. One Universe.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.silverAccent.withValues(alpha: 0.7),
                        fontSize: 14,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut, duration: 800.ms),
              ],
            ),

            // Sleek cinematic progress indicator
            Positioned(
              bottom: 80,
              child: SizedBox(
                width: 40,
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.softWhite.withValues(alpha: 0.05),
                  color: AppTheme.royalPurple,
                ),
              ).animate().fadeIn(delay: 1500.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
