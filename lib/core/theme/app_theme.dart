import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global dark futuristic theme for Study Smart.
///
/// Palette matches the AI Study Companion reference design:
///   Background: #090D1A (near-black navy)
///   Accent:     #4A78F5 (electric blue)
class AppTheme {
  AppTheme._();

  // ── Color Palette ────────────────────────────────────────────────────────

  /// Electric blue — primary accent (matches reference design).
  static const Color primary       = Color(0xFF4A78F5);
  static const Color primaryGlow   = Color(0xFF3D6AE0);
  static const Color primaryDark   = Color(0xFF1E3FA8);

  /// Bright cyan — secondary / AI ring highlight.
  static const Color secondary     = Color(0xFF00C6FF);
  static const Color secondaryDark = Color(0xFF0099CC);

  /// Warning amber.
  static const Color warning       = Color(0xFFFFB347);

  /// Error / destructive.
  static const Color error         = Color(0xFFFF4D6D);

  // ── Background & Surface ────────────────────────────────────────────

  /// Deepest background — #090D1A.
  static const Color bgDark        = Color(0xFF090D1A);

  /// App-bar / bottom-nav surface.
  static const Color surfaceDark   = Color(0xFF0F1322);

  /// Card surface.
  static const Color cardDark      = Color(0xFF141929);

  /// Elevated card (modals, overlays).
  static const Color cardHighDark  = Color(0xFF1A2035);

  /// Subtle divider / border.
  static const Color borderDark    = Color(0xFF243048);

  // ── Neon Glow Helpers ─────────────────────────────────────────────────────

  /// Transparent neon-blue for glow shadows / overlays.
  static Color neonBlueGlow(double opacity) =>
      const Color(0xFF00D4FF).withOpacity(opacity);

  static Color neonCyanGlow(double opacity) =>
      const Color(0xFF00FFD1).withOpacity(opacity);

  // ── Gradients ─────────────────────────────────────────────────────────────

  /// Primary neon-blue gradient — used on hero buttons, banners.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0077FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Surface gradient — subtle depth on cards.
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1A2235), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient — secondary / success elements.
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00FFD1), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Deep background gradient for full-screen pages.
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0B0F1A), Color(0xFF0D1526)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8F0FE);
  static const Color textSecondary = Color(0xFF7A8BA8);
  static const Color textMuted     = Color(0xFF3D4F6A);

  // ── Shared Radius Tokens ──────────────────────────────────────────────────
  static const double radiusS  = 8.0;
  static const double radiusM  = 14.0;
  static const double radiusL  = 20.0;
  static const double radiusXL = 28.0;

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme _textTheme() {
    return GoogleFonts.spaceGroteskTextTheme().copyWith(
      // Display — large hero headings
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 34, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Headline — section titles
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Title — card headers, list items
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      // Body — readable content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: textPrimary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: textPrimary, height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: textSecondary, height: 1.4,
      ),
      // Label — buttons, chips, tags
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: textPrimary, letterSpacing: 0.3,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: textSecondary, letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: textMuted, letterSpacing: 0.5,
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final tt = _textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ── Color Scheme ──────────────────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:         primary,
        onPrimary:       bgDark,
        primaryContainer: Color(0xFF003344),
        onPrimaryContainer: primary,
        secondary:       secondary,
        onSecondary:     bgDark,
        secondaryContainer: Color(0xFF003D35),
        onSecondaryContainer: secondary,
        error:           error,
        onError:         Colors.white,
        surface:         surfaceDark,
        onSurface:       textPrimary,
        onSurfaceVariant: textSecondary,
        outline:         borderDark,
        outlineVariant:  Color(0xFF1E2D42),
        shadow:          Colors.black,
        scrim:           Colors.black87,
        inverseSurface:  textPrimary,
        onInverseSurface: bgDark,
        inversePrimary:  primaryDark,
        surfaceTint:     primary,
      ),

      scaffoldBackgroundColor: bgDark,
      textTheme: tt,

      // ── AppBar ────────────────────────────────────────────────────────────
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
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primary.withOpacity(0.15),
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
            return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w400, color: textSecondary,
          );
        }),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
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

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return primaryGlow;
            if (states.contains(WidgetState.disabled)) return borderDark;
            return primary;
          }),
          foregroundColor: WidgetStateProperty.all(bgDark),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.08)),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            return 0;
          }),
          shadowColor: WidgetStateProperty.all(neonBlueGlow(0.4)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700,
                letterSpacing: 0.3),
          ),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusS)),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input / TextField ─────────────────────────────────────────────────
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
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        floatingLabelStyle: GoogleFonts.inter(color: primary, fontSize: 12),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: primary.withOpacity(0.2),
        disabledColor: borderDark,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: textPrimary),
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: textSecondary, size: 20),
      primaryIconTheme: const IconThemeData(color: primary, size: 20),

      // ── Floating Action Button ────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: bgDark,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL)),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardHighDark,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM)),
        actionTextColor: primary,
        elevation: 4,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        elevation: 16,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL)),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14, color: textSecondary, height: 1.5,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardDark,
        modalBackgroundColor: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Switch & Checkbox ─────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? bgDark : textSecondary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primary
                : borderDark),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(bgDark),
        side: const BorderSide(color: borderDark, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: borderDark,
        circularTrackColor: borderDark,
      ),

      // ── ListTile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Popup Menu ────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: cardHighDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM)),
        textStyle: GoogleFonts.inter(fontSize: 14, color: textPrimary),
      ),
    );
  }

  // ── Light Theme (minimal — kept for compatibility) ─────────────────────────
  static ThemeData get light => dark; // Force dark-only for now
}
