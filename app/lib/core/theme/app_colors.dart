import 'package:flutter/material.dart';

/// Design tokens extracted from the Money Management Figma file
/// (node 1095:2 — "UI Mobile (1)" page).
class AppColors {
  AppColors._();

  // Surfaces & background
  static const Color background = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF0F8F4);

  // Brand / action
  static const Color actionPrimary = Color(0xFF167257);
  static const Color actionPrimaryDark = Color(0xFF0F5843);
  static const Color actionSelected = Color(0xFFDDF2E8);

  // Text
  static const Color textPrimary = Color(0xFF14201B);
  static const Color textSecondary = Color(0xFF5F6B66);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFA7B3AE);

  // Borders
  static const Color borderDefault = Color(0xFFDCE3DF);
  static const Color borderStrong = Color(0xFFC4CFC9);

  // Status
  static const Color statusPositive = Color(0xFF167257);
  static const Color statusNegative = Color(0xFFC93737);
  static const Color statusNegativeBg = Color(0xFFFEF2F2);
  static const Color statusWarning = Color(0xFFB45309);
  static const Color statusWarningBg = Color(0xFFFEF6E7);
  static const Color statusInfo = Color(0xFF1D6FB8);
  static const Color statusInfoBg = Color(0xFFEAF3FB);

  // Category accent palette (used for avatars / category chips / charts)
  static const List<Color> categoryPalette = <Color>[
    Color(0xFF167257),
    Color(0xFF2F8F6D),
    Color(0xFF4CA88A),
    Color(0xFF7FC4AC),
    Color(0xFFB6DFCE),
    Color(0xFF0F5843),
  ];

  static const Color shadow = Color(0x0A000000);
}
