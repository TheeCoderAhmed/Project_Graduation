import 'package:flutter/material.dart';

/// Clinical Clarity — "Guided Confidence" design system
/// Medical Blue / Mint Teal / Warm Amber
class AppColors {
  // ── Primary (Medical Blue) ──────────────────────────────────────────
  static const Color primary          = Color(0xFF074469);
  static const Color primaryContainer = Color(0xFF2A5C82);
  static const Color onPrimary        = Color(0xFFFFFFFF);

  // ── Secondary (Mint Teal) ───────────────────────────────────────────
  static const Color secondary          = Color(0xFF006A68);
  static const Color secondaryContainer = Color(0xFF91F0EC);
  static const Color onSecondary        = Color(0xFFFFFFFF);

  // ── Tertiary (Warm Amber — ratings & achievements) ──────────────────
  static const Color tertiary      = Color(0xFF5A3B00);
  static const Color tertiaryFixed = Color(0xFFFFDDB0);
  static const Color starGold      = Color(0xFFF5A623);

  // ── Surfaces ────────────────────────────────────────────────────────
  static const Color background       = Color(0xFFF9F9FD);
  static const Color surface          = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0F3F8);

  // ── Text ────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF41474E);

  // ── Outline & Divider ───────────────────────────────────────────────
  static const Color outline = Color(0xFF72787F);
  static const Color divider = Color(0xFFE0E3E8);

  // ── Semantic ────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF006A68); // Reuse teal for positive

  // ── Ambient Shadow (used in BoxShadow) ──────────────────────────────
  static Color ambientShadow = const Color(0xFF074469).withValues(alpha: 0.15);
}
