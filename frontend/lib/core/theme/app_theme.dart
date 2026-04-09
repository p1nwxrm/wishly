import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Centralized theme configuration for the Wishly app
class AppTheme {
  // Base colors for application backgrounds
  static const Color _primaryColor = Color(0xFF6CB4EE);
  static const Color _backgroundColor = Color(0xFFF2F8FD);
  static const Color _surfaceColor = Colors.white;
  static const Color _errorColor = Color(0xFFFF5252);

  // On-colors for text and icons placed on top of base colors
  static const Color _onPrimaryColor = Colors.white;
  static const Color _onErrorColor = Colors.white;

  // Main text colors for light backgrounds
  static const Color _textPrimaryColor = Color(0xFF1E293B);
  static const Color _textSecondaryColor = Color(0xFF64748B);

  // Getter for the complete light theme data
  static ThemeData get lightTheme {
    // Create base text theme using Nunito font
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        onPrimary: _onPrimaryColor,
        surface: _surfaceColor,
        error: _errorColor,
        onError: _onErrorColor,
      ),
      // Apply Nunito font globally with custom text colors
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: _textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: _textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: _textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: _textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: _textPrimaryColor,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: _textSecondaryColor,
        ),
      ),
      // Configure global app bar styling with rounded bottom corners
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _onPrimaryColor,
        ),
      ),
      // Configure global elevated button styling with rounded corners
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Configure global outlined button styling with rounded corners
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Configure global card styling to match the design
      cardTheme: CardThemeData(
        color: _surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      // Configure global input text field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      // Configure global SnackBar styling for errors and notifications
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _errorColor,
        contentTextStyle: TextStyle(
          color: _onErrorColor,
          fontSize: 16,
        ),
        behavior: SnackBarBehavior.floating, // Makes it float above the bottom instead of sticking
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      // By default, loaders will use the primary blue color
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
      ),
    );
  }
}