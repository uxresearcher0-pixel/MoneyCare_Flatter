import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles mirroring the Inter type scale used throughout the Figma file.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    double? height,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  // Display / headings
  static TextStyle h1 = _inter(size: 28, weight: FontWeight.w700, height: 1.35);
  static TextStyle h2 = _inter(size: 22, weight: FontWeight.w700, height: 1.3);
  static TextStyle h3 = _inter(size: 18, weight: FontWeight.w700, height: 1.3);

  // Body
  static TextStyle bodyLargeSemibold =
      _inter(size: 16, weight: FontWeight.w600, height: 1.4);
  static TextStyle bodyLarge = _inter(size: 16, weight: FontWeight.w400, height: 1.4);
  static TextStyle bodyMediumSemibold =
      _inter(size: 15, weight: FontWeight.w600, height: 1.4);
  static TextStyle bodyMedium = _inter(size: 15, weight: FontWeight.w400, height: 1.4);
  static TextStyle bodySmallBold = _inter(size: 14, weight: FontWeight.w700, height: 1.3);
  static TextStyle bodySmallSemibold =
      _inter(size: 14, weight: FontWeight.w600, height: 1.3);
  static TextStyle bodySmall = _inter(size: 14, weight: FontWeight.w400, height: 1.4);

  // Labels / captions
  static TextStyle labelBold = _inter(size: 13, weight: FontWeight.w700, height: 1.5);
  static TextStyle labelSemibold =
      _inter(size: 13, weight: FontWeight.w600, height: 1.5);
  static TextStyle labelMedium = _inter(size: 13, weight: FontWeight.w500, height: 1.5);
  static TextStyle label = _inter(size: 13, weight: FontWeight.w400, height: 1.5);

  static TextStyle captionBold = _inter(size: 12, weight: FontWeight.w700, height: 1.4);
  static TextStyle captionSemibold =
      _inter(size: 12, weight: FontWeight.w600, height: 1.4);
  static TextStyle captionMedium =
      _inter(size: 12, weight: FontWeight.w500, height: 1.4);
  static TextStyle caption = _inter(size: 12, weight: FontWeight.w400, height: 1.4);

  static TextStyle tinySemibold =
      _inter(size: 10, weight: FontWeight.w600, height: 1.3);
}
