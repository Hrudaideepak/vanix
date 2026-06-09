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

            // Logo Content (Netflix-style Round Logo Zoom)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.royalPurple.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/icon/app_icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(3.5, 3.5),
                        duration: 2000.ms,
                        curve: Curves.easeInOutQuart,
                      )
                      .shimmer(
                        delay: 800.ms,
                        duration: 1000.ms,
                        color: Colors.white30,
                      )
                      .then()
                      .fadeOut(duration: 300.ms),
                  const SizedBox(height: 24),
                  // Fade in "VANIX" subtitle, then fade it out before transition
                  Text(
                    'VANIX',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6.0,
                          foreground: Paint()
                            ..shader = AppTheme.premiumGradient.createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 45.0),
                            ),
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .shimmer(delay: 1200.ms, duration: 800.ms)
                      .then(delay: 200.ms)
                      .fadeOut(duration: 300.ms),
                ],
              ),
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
