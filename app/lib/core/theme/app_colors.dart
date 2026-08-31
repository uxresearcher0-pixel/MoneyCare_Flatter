import 'package:flutter/material.dart';

/// Design tokens extracted from the Money Management Figma file
/// (node 1095:2 — "UI Mobile (1)" page).
///
/// Every screen in this app is hand-styled directly from these tokens
/// (rather than `Theme.of(context)`), so they're resolved through a
/// mutable [brightness] flag instead of being plain `static const` — that
/// is what makes the Appearance (light/dark/system) setting actually
/// repaint the custom screens, not just native Material chrome like
/// dialogs and switches. [MoneyCareApp] sets [brightness] once per build
/// from the resolved theme mode, before the rest of the tree builds.
class AppColors {
  AppColors._();

  static Brightness brightness = Brightness.light;
  static bool get _isDark => brightness == Brightness.dark;

  // Surfaces & background
  static Color get background => _isDark ? const Color(0xFF101613) : const Color(0xFFF6F8F6);
  static Color get surface => _isDark ? const Color(0xFF1A2420) : const Color(0xFFFFFFFF);
  static Color get surfaceSubtle => _isDark ? const Color(0xFF17211D) : const Color(0xFFF0F8F4);

  // Brand / action
  static Color get actionPrimary => _isDark ? const Color(0xFF34A67F) : const Color(0xFF167257);
  static Color get actionPrimaryDark => _isDark ? const Color(0xFF167257) : const Color(0xFF0F5843);
  static Color get actionSelected => _isDark ? const Color(0xFF1E3A2F) : const Color(0xFFDDF2E8);

  // Text
  static Color get textPrimary => _isDark ? const Color(0xFFEAF2EE) : const Color(0xFF14201B);
  static Color get textSecondary => _isDark ? const Color(0xFF9CAEA6) : const Color(0xFF5F6B66);
  static const Color textInverse = Color(0xFFFFFFFF);
  static Color get textDisabled => _isDark ? const Color(0xFF56655D) : const Color(0xFFA7B3AE);

  // Borders
  static Color get borderDefault => _isDark ? const Color(0xFF2A3730) : const Color(0xFFDCE3DF);
  static Color get borderStrong => _isDark ? const Color(0xFF3C4A42) : const Color(0xFFC4CFC9);

  // Status
  static Color get statusPositive => _isDark ? const Color(0xFF34A67F) : const Color(0xFF167257);
  static Color get statusNegative => _isDark ? const Color(0xFFE5696D) : const Color(0xFFC93737);
  static Color get statusNegativeBg => _isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
  static Color get statusWarning => _isDark ? const Color(0xFFEFB84F) : const Color(0xFFB45309);
  static Color get statusWarningBg => _isDark ? const Color(0xFF3A2E13) : const Color(0xFFFEF6E7);
  static Color get statusInfo => _isDark ? const Color(0xFF5DA9E6) : const Color(0xFF1D6FB8);
  static Color get statusInfoBg => _isDark ? const Color(0xFF16283A) : const Color(0xFFEAF3FB);

  // Category accent palette (used for avatars / category chips / charts)
  static List<Color> get categoryPalette => _isDark
      ? const <Color>[
          Color(0xFF34A67F),
          Color(0xFF4CA88A),
          Color(0xFF6FC0A2),
          Color(0xFF8FD4BB),
          Color(0xFFB6DFCE),
          Color(0xFF2A8567),
        ]
      : const <Color>[
          Color(0xFF167257),
          Color(0xFF2F8F6D),
          Color(0xFF4CA88A),
          Color(0xFF7FC4AC),
          Color(0xFFB6DFCE),
          Color(0xFF0F5843),
        ];

  static Color get shadow => _isDark ? const Color(0x40000000) : const Color(0x0A000000);
}
