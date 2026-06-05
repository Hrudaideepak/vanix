import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color deepBlack = Color(0xFF0B0F1A);
  static const Color cardGrey = Color(0xFF151A28);
  static const Color royalPurple = Color(0xFF6C63FF);
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color softWhite = Color(0xFFFFFFFF);
  static const Color silverAccent = Color(0xFFA0A7B8);
  static const Color errorRed = Color(0xFFEF4444);

  // Gradient Colors
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [royalPurple, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF121829), // Slightly lighter Navy Slate top-left
      deepBlack,
      Color(0xFF070B14), // Deeper Obsidian Navy bottom-right
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
        onPrimary: softWhite,
        onSecondary: softWhite,
        onSurface: silverAccent,
      ),
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: softWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
        iconTheme: IconThemeData(color: softWhite),
      ),
      cardTheme: CardThemeData(
        color: cardGrey.withValues(alpha: 0.7),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: softWhite.withValues(alpha: 0.08),
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
          borderSide: BorderSide(color: softWhite.withValues(alpha: 0.08), width: 1),
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
            fontFamily: 'Outfit',
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
      fontFamily: 'Outfit',
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
    double blur = 15.0,
    double opacity = 0.08,
    double borderRadius = 16.0,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? softWhite).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (color ?? softWhite).withValues(alpha: 0.12),
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
