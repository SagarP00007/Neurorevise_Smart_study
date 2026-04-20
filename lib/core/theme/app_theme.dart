import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Study Smart — Dark Charcoal + Vivid Orange theme
///
/// Cloned from Kommodo reference (fitness app dark theme):
///   Background:  #1C1C1E  (near-black charcoal)
///   Cards:       #2C2C2E  (dark grey surface)
///   Primary:     #FF6B00  (vivid orange)
///   Secondary:   #E31C1C  (crimson red)
///   Text:        #FFFFFF / #8E8E93
class AppTheme {
  AppTheme._();

  // ── Color Palette ──────────────────────────────────────────────────────────

  /// Vivid orange — primary accent (exact from reference).
  static const Color primary       = Color(0xFFFF6B00);
  static const Color primaryGlow   = Color(0xFFFF8C00);
  static const Color primaryDark   = Color(0xFFCC5500);

  /// Crimson red — secondary accent.
  static const Color secondary     = Color(0xFFE31C1C);
  static const Color secondaryDark = Color(0xFFB01515);

  /// Magenta/pink — sidebar pill accent (exact from reference nav bar).
  static const Color magenta       = Color(0xFFC5446A);

  /// Orange-yellow — timer / highlight numbers.
  static const Color amber         = Color(0xFFFFAA00);

  /// Warning.
  static const Color warning       = Color(0xFFFFAA00);

  /// Error / destructive.
  static const Color error         = Color(0xFFFF2D55);

  // ── Backgrounds & Surfaces ─────────────────────────────────────────────────

  /// Main background — near-black charcoal #1C1C1E.
  static const Color bgDark        = Color(0xFF1C1C1E);

  /// App-bar / bottom nav surface.
  static const Color surfaceDark   = Color(0xFF2C2C2E);

  /// Card surface.
  static const Color cardDark      = Color(0xFF2C2C2E);

  /// Elevated card.
  static const Color cardHighDark  = Color(0xFF3A3A3C);

  /// Divider / border.
  static const Color borderDark    = Color(0xFF3A3A3C);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted     = Color(0xFF48484A);

  // ── Gradients ─────────────────────────────────────────────────────────────

  /// Orange → Red gradient (used on progress rings, buttons, cards).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFE31C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark background gradient.
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF111113)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card gradient.
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2C2C2E), Color(0xFF252527)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Radius tokens ──────────────────────────────────────────────────────────
  static const double radiusS  = 8.0;
  static const double radiusM  = 14.0;
  static const double radiusL  = 20.0;
  static const double radiusXL = 28.0;

  // ── Typography ─────────────────────────────────────────────────────────────
  static TextTheme _textTheme() {
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 34, fontWeight: FontWeight.w800,
        color: textPrimary, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: textPrimary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: textPrimary, height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: textSecondary, height: 1.4,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: textMuted, letterSpacing: 0.4,
      ),
    );
  }

  // ── Theme ──────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final tt = _textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary:              primary,
        onPrimary:            Colors.white,
        primaryContainer:     Color(0xFF4A1E00),
        onPrimaryContainer:   Color(0xFFFFD9B0),
        secondary:            secondary,
        onSecondary:          Colors.white,
        secondaryContainer:   Color(0xFF4A0000),
        onSecondaryContainer: Color(0xFFFFB3B3),
        error:                error,
        onError:              Colors.white,
        surface:              surfaceDark,
        onSurface:            textPrimary,
        onSurfaceVariant:     textSecondary,
        outline:              borderDark,
        outlineVariant:       Color(0xFF48484A),
        shadow:               Colors.black,
        scrim:                Colors.black87,
        inverseSurface:       textPrimary,
        onInverseSurface:     bgDark,
        inversePrimary:       primaryGlow,
        surfaceTint:          primary,
      ),

      scaffoldBackgroundColor: bgDark,
      textTheme: tt,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),

      // ── Navigation Bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primary.withOpacity(0.20),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 11, fontWeight: FontWeight.w700, color: primary,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 11, fontWeight: FontWeight.w400, color: textSecondary,
          );
        }),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Elevated Button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return borderDark;
            if (states.contains(WidgetState.pressed)) return primaryDark;
            return primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shadowColor: WidgetStateProperty.all(primary.withOpacity(0.5)),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.12)),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM))),
          textStyle: WidgetStateProperty.all(
              GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusS)),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM)),
          textStyle: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input / TextField ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 14),
        floatingLabelStyle: GoogleFonts.outfit(color: primary, fontSize: 12),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cardHighDark,
        selectedColor: primary.withOpacity(0.25),
        disabledColor: borderDark,
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: textPrimary),
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: borderDark, thickness: 1, space: 1,
      ),

      // ── Icon ───────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: textSecondary, size: 20),
      primaryIconTheme: const IconThemeData(color: primary, size: 20),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL)),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardHighDark,
        contentTextStyle: GoogleFonts.outfit(color: textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM)),
        actionTextColor: primary,
        elevation: 4,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        elevation: 16,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL)),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14, color: textSecondary, height: 1.5,
        ),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardDark,
        modalBackgroundColor: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Switch ─────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : borderDark),
      ),

      // ── Checkbox ───────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: borderDark, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Progress ───────────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: borderDark,
        circularTrackColor: borderDark,
      ),

      // ── ListTile ───────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Popup Menu ─────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: cardHighDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM)),
        textStyle: GoogleFonts.outfit(fontSize: 14, color: textPrimary),
      ),
    );
  }

  static ThemeData get light => dark;
}
