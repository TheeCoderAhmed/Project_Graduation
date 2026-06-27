import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Typography helpers ──────────────────────────────────────────────
  static TextStyle _manrope(double size, FontWeight weight, Color color, {double? height, double? letterSpacing}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: letterSpacing);

  static TextStyle _inter(double size, FontWeight weight, Color color, {double? height, double? letterSpacing}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: letterSpacing);

  // ── 8px Spacing Scale ───────────────────────────────────────────────
  static const double spaceXs  = 4;
  static const double spaceSm  = 8;
  static const double spaceMd  = 16;
  static const double spaceLg  = 24;
  static const double spaceXl  = 32;
  static const double spaceXxl = 48;
  static const double containerMargin = 20;

  // ── Shape Radii ─────────────────────────────────────────────────────
  static const double radiusSm   = 8;   // inputs, buttons
  static const double radiusMd   = 12;  // small cards
  static const double radiusLg   = 16;  // cards, containers
  static const double radiusXl   = 24;  // onboarding cards
  static const double radiusFull = 9999; // pills, avatars

  // ── Ambient Shadow ──────────────────────────────────────────────────
  static List<BoxShadow> get ambientShadow => [
    BoxShadow(
      color: AppColors.ambientShadow,
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: AppColors.ambientShadow.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Theme Data ──────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // ── Typography ────────────────────────────────────────────────
      textTheme: TextTheme(
        // Manrope headings
        displayLarge:  _manrope(40, FontWeight.w700, AppColors.textPrimary, height: 1.2),
        displayMedium: _manrope(32, FontWeight.w600, AppColors.textPrimary, height: 1.25),
        displaySmall:  _manrope(24, FontWeight.w600, AppColors.textPrimary, height: 1.3),
        headlineLarge: _manrope(28, FontWeight.w700, AppColors.textPrimary, height: 1.25),
        headlineMedium: _manrope(24, FontWeight.w600, AppColors.textPrimary, height: 1.3),
        headlineSmall:  _manrope(20, FontWeight.w600, AppColors.textPrimary, height: 1.35),
        // Inter titles & body
        titleLarge:  _inter(18, FontWeight.w600, AppColors.textPrimary, height: 1.4),
        titleMedium: _inter(16, FontWeight.w600, AppColors.textPrimary, height: 1.4),
        titleSmall:  _inter(14, FontWeight.w600, AppColors.textPrimary, height: 1.4),
        bodyLarge:   _inter(18, FontWeight.w400, AppColors.textPrimary, height: 1.6),
        bodyMedium:  _inter(16, FontWeight.w400, AppColors.textSecondary, height: 1.6),
        bodySmall:   _inter(14, FontWeight.w400, AppColors.textSecondary, height: 1.5),
        labelLarge:  _inter(14, FontWeight.w600, AppColors.onPrimary, letterSpacing: 0.3),
        labelMedium: _inter(12, FontWeight.w600, AppColors.textSecondary, letterSpacing: 0.8),
        labelSmall:  _inter(11, FontWeight.w500, AppColors.textSecondary, letterSpacing: 0.5),
      ),

      // ── App Bar ───────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: _manrope(18, FontWeight.w600, AppColors.textPrimary),
      ),

      // ── Buttons ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: _inter(16, FontWeight.w600, AppColors.onPrimary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: _inter(16, FontWeight.w600, AppColors.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: _inter(15, FontWeight.w600, AppColors.primary),
        ),
      ),

      // ── Inputs ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: _inter(15, FontWeight.w400, AppColors.outline),
        labelStyle: _inter(12, FontWeight.w600, AppColors.textSecondary, letterSpacing: 0.8),
        floatingLabelStyle: _inter(12, FontWeight.w600, AppColors.primary, letterSpacing: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // ── Cards ─────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chips ─────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusFull)),
        labelStyle: _inter(13, FontWeight.w500, AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Bottom Nav ────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Switch ────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.primary : AppColors.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider),
      ),

      // ── Slider ────────────────────────────────────────────────────
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.divider,
        thumbColor: AppColors.primary,
        overlayColor: Color(0x20074469),
      ),
    );
  }
}
