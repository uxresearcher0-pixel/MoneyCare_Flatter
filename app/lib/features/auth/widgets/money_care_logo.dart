import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Recreation of the "Money Care Accounting" mark used across the
/// authentication screens: a dark-green disc with three fanned leaf
/// shapes, optionally paired with the wordmark underneath.
class MoneyCareLogo extends StatelessWidget {
  const MoneyCareLogo({super.key, this.size = 140, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final iconSize = showWordmark ? size * 0.62 : size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(painter: _LogoPainter()),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.06),
          Text(
            'money care',
            style: GoogleFontsFallback.bold(
              size: size * 0.16,
              color: AppColors.actionPrimaryDark,
            ),
          ),
          Text(
            'ACCOUNTING',
            style: AppTextStyles.tinySemibold.copyWith(
              color: AppColors.actionPrimary,
              letterSpacing: 1.4,
              fontSize: size * 0.045,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small helper so the wordmark keeps a rounded, heavy weight without
/// pulling in a second font family.
class GoogleFontsFallback {
  static TextStyle bold({required double size, required Color color}) {
    return AppTextStyles.h1.copyWith(fontSize: size, color: color, height: 1);
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = size.width / 2;

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    // Base disc
    canvas.drawRect(rect, Paint()..color = const Color(0xFF10513E));

    // Three fanned "leaf" petals, darkest to lightest, left to right.
    final petalColors = [
      const Color(0xFF167257),
      const Color(0xFF3F9C7C),
      const Color(0xFFAEDDC7),
    ];

    for (var i = 0; i < petalColors.length; i++) {
      final path = Path();
      final baseX = r * (0.15 + i * 0.32);
      path.moveTo(baseX, size.height * 1.05);
      path.quadraticBezierTo(
        r * (0.3 + i * 0.45),
        size.height * 0.15,
        r * (1.55 + i * 0.28),
        -size.height * 0.05,
      );
      path.quadraticBezierTo(
        r * (1.1 + i * 0.2),
        size.height * 0.55,
        baseX,
        size.height * 1.05,
      );
      path.close();
      canvas.drawPath(path, Paint()..color = petalColors[i]);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
