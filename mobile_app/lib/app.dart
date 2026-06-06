import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/profile/presentation/screens/profile_selection_screen.dart';
import 'features/home/presentation/screens/navigation_holder.dart';
import 'features/movies/presentation/screens/movie_details_screen.dart';
import 'features/player/presentation/screens/player_screen.dart';
import 'features/subscription/presentation/screens/subscription_screen.dart';

class VanixApp extends StatelessWidget {
  const VanixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VANIX',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Vanix is cinematic, dark theme first
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme, // Support light mode settings optionally, but styled elegantly
      initialRoute: '/',
      builder: (context, child) {
        if (!kIsWeb) return child ?? const SizedBox.shrink();

        final size = MediaQuery.of(context).size;
        final isMobileWeb = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;

        // If it's a mobile web browser or a small window, don't show the chassis
        if (isMobileWeb || size.width < 600) {
          return child ?? const SizedBox.shrink();
        }

        // On Desktop Web, show the premium mobile app chassis
        return Scaffold(
          backgroundColor: const Color(0xFF07050E), // Outer space dark canvas background
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0B26), // Deep rich violet
                  Color(0xFF040208), // Near pitch black
                  Color(0xFF05091E), // Deep navy blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // ambient glowing gradients behind the phone chassis
                Positioned(
                  top: -200,
                  left: -200,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -200,
                  right: -200,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    ),
                  ),
                ),
                
                // Centered Device Chassis Container
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 40,
                          spreadRadius: 8,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: -2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 420,
                      height: 860,
                      // Bezel Border Styling
                      decoration: BoxDecoration(
                        color: const Color(0xFF16151A), // Matte obsidian bezel
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: const Color(0xFF2E2C33), // Metallic outer ring highlight
                          width: 12,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            // Main Application View
                            Positioned.fill(
                              top: 36, // leave room for mockup status bar
                              bottom: 12, // leave room for virtual home indicator
                              child: child ?? const SizedBox.shrink(),
                            ),

                            // Mock Phone Status Bar at Top
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 36,
                              child: Container(
                                color: const Color(0xFF050505), // Matches app top bar
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '09:41',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Icon(Icons.wifi, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Icon(Icons.battery_5_bar, color: Colors.white, size: 14),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Mock Dynamic Island (Notch Decoration)
                            Positioned(
                              top: 6,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 90,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1E293B),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0F172A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Virtual Home Indicator Bar at Bottom
                            Positioned(
                              bottom: 4,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 130,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/profiles':
            return MaterialPageRoute(builder: (_) => const ProfileSelectionScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const NavigationHolder());
          case '/movie-details':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(
                contentId: args['id'] as String,
                contentType: args['type'] as String, // 'movie' or 'series'
              ),
            );
          case '/player':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PlayerScreen(
                videoUrl: args['videoUrl'] as String,
                title: args['title'] as String,
                contentId: args['contentId'] as String,
                startOffset: args['startOffset'] as int? ?? 0,
                episodeId: args['episodeId'] as String?,
              ),
            );
          case '/subscription':
            return MaterialPageRoute(builder: (_) => const SubscriptionScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
