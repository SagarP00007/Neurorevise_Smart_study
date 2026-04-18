import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D6);
  static const Color secondary = Color(0xFF00D4AA);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB347);

  // ── Dark Surface Colors ───────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1C1B2E);
  static const Color cardDark = Color(0xFF252438);
  static const Color borderDark = Color(0xFF2E2D45);

  // ── Light Surface Colors ──────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF5F5FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFEEEEFF);
  static const Color borderLight = Color(0xFFDDDDF5);

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF5F5FF);
  static const Color textSecondaryDark = Color(0xFF9E9EC8);
  static const Color textPrimaryLight = Color(0xFF0F0E17);
  static const Color textSecondaryLight = Color(0xFF5A5A8A);

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(bool isDark) {
    final color = isDark ? textPrimaryDark : textPrimaryLight;
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w700, color: color),
      displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w700, color: color),
      displaySmall: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w600, color: color),
      headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: color),
      headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: color),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: color),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: color),
      bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? textSecondaryDark : textSecondaryLight),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        error: accent,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimaryDark,
      ),
      scaffoldBackgroundColor: bgDark,
      textTheme: _buildTextTheme(true),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle:
            GoogleFonts.inter(color: textSecondaryDark, fontSize: 14),
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: accent,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimaryLight,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: _buildTextTheme(false),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle:
            GoogleFonts.inter(color: textSecondaryLight, fontSize: 14),
      ),
    );
  }
}
