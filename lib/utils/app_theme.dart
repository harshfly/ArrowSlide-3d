import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

/// AppTheme — Material 3 theme configuration for ArrowSlide 3D.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GameConfig.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: GameConfig.primary,
        secondary: GameConfig.secondary,
        tertiary: GameConfig.accent,
        surface: GameConfig.surface,
        error: GameConfig.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: GameConfig.textColor,
      ),

      // Card & Dialog Theme
      dialogTheme: const DialogThemeData(backgroundColor: GameConfig.surface),

      // Bottom Sheet Theme — 24px top rounded corners
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GameConfig.surface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GameConfig.radiusLg),
          ),
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.nunitoSansTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.nunitoSans(
          color: GameConfig.textColor,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.nunitoSans(
          color: GameConfig.textColor,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
        headlineLarge: GoogleFonts.nunitoSans(
          color: GameConfig.textColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        headlineMedium: GoogleFonts.nunitoSans(
          color: GameConfig.textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.nunitoSans(
          color: GameConfig.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.nunitoSans(
          color: GameConfig.textColor,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          color: GameConfig.textMuted,
          fontSize: 12,
        ),
      ),

      // Button Themes — 20px rounded corners (pill shape)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameConfig.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: GameConfig.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GameConfig.textColor,
          side: const BorderSide(color: GameConfig.surfaceLight, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
