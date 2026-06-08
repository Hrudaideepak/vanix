import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color deepBlack = Color(0xFF050508);
  static const Color cardGrey = Color(0xFF121118);
  static const Color royalPurple = Color(0xFF8B5CF6); // Vibrant Purple Accent
  static const Color electricBlue = Color(0xFF3B82F6); // Vibrant Blue Accent
  static const Color softWhite = Color(0xFFF8FAFC);
  static const Color silverAccent = Color(0xFFE2E8F0); // on-surface
  static const Color errorRed = Color(0xFFFDA4AF);

  // Gradient Colors
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [royalPurple, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF09070F), // Very deep purple-black
      deepBlack,
      Color(0xFF020205),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Playful dynamic gradient for Kids Mode space
  static const LinearGradient kidsBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0F172A), // Slate base
      Color(0xFF1E1B4B), // Deep Indigo
      Color(0xFF3B0764), // Deep Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepBlack,
      primaryColor: royalPurple,
      colorScheme: const ColorScheme.dark(
        primary: royalPurple,
        secondary: electricBlue,
        surface: cardGrey,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: softWhite,
        onSurface: silverAccent,
      ),
      fontFamily: 'SpaceGrotesk',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: softWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SpaceGrotesk',
        ),
        iconTheme: IconThemeData(color: softWhite),
      ),
      cardTheme: CardThemeData(
        color: cardGrey,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // modern rounded corners
          side: const BorderSide(
            color: Color(0x1A8B5CF6), // Subtle purple border highlight
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softWhite.withValues(alpha: 0.05),
        hintStyle: TextStyle(color: silverAccent.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1A8B5CF6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: royalPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: softWhite,
          shadowColor: royalPurple.withValues(alpha: 0.3),
          elevation: 8,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: softWhite, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: softWhite, fontSize: 28, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: softWhite, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: softWhite, fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: silverAccent, fontSize: 16),
        bodyMedium: TextStyle(color: silverAccent, fontSize: 14),
        labelLarge: TextStyle(color: softWhite, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Fallback light theme, matching our elegance
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      primaryColor: royalPurple,
      colorScheme: const ColorScheme.light(
        primary: royalPurple,
        secondary: electricBlue,
        surface: Colors.white,
        error: errorRed,
      ),
      fontFamily: 'SpaceGrotesk',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: deepBlack, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: deepBlack, fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: deepBlack, fontSize: 16),
        bodyMedium: TextStyle(color: deepBlack, fontSize: 14),
      ),
    );
  }

  // Custom Glassmorphism Box Decoration helper
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double blur = 12.0,
    double opacity = 0.8,
    double borderRadius = 0.0,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? cardGrey).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: const Color(0x1AFF0000), // rgba(255, 0, 0, 0.1)
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ],
    );
  }
}
