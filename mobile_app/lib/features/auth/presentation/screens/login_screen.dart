import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/profiles');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Authentication failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _handleGoogleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Passing google-mock credentials to service
    final success = await auth.login('google-demo@vanix.com', 'google-oauth-password');
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/profiles');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Google authentication failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Brand Header
                Text(
                  'VANIX',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        foreground: Paint()
                          ..shader = AppTheme.premiumGradient.createShader(
                            const Rect.fromLTWH(0.0, 0.0, 300.0, 50.0),
                          ),
                      ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0.0),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your entertainment universe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.silverAccent.withValues(alpha: 0.6),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 48),

                // Glassmorphism Form Card
                Form(
                  key: _formKey,
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.softWhite,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppTheme.softWhite),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.silverAccent),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppTheme.softWhite),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.silverAccent),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppTheme.silverAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Login button
                        PremiumButton(
                          text: 'Sign In',
                          isLoading: auth.isLoading,
                          onTap: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms).scaleXY(begin: 0.95, end: 1.0),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.softWhite.withValues(alpha: 0.08))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR CONNECT WITH',
                        style: TextStyle(
                          color: AppTheme.silverAccent.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.softWhite.withValues(alpha: 0.08))),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                const SizedBox(height: 24),

                // Google sign in button
                GestureDetector(
                  onTap: _handleGoogleLogin,
                  child: GlassCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    opacity: 0.04,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          'https://api.dicebear.com/7.x/identicon/png?seed=GoogleLogo', // Mock graphic for Google icon
                          width: 20,
                          height: 20,
                          errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: AppTheme.softWhite),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: AppTheme.softWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                const SizedBox(height: 48),

                // Register router pointer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New to VANIX? ",
                      style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.5)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Sign up now',
                        style: TextStyle(
                          color: AppTheme.royalPurple,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
