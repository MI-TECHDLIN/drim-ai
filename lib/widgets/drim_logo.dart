import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Reusable DRIM AI logo.
/// [scale] controls size: 1.0 for nav/auth, 2.0 for splash card.
class DrimLogo extends StatelessWidget {
  final double scale;

  const DrimLogo({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'DRIM',
          style: GoogleFonts.poppins(
            fontSize: 20.0 * scale,
            fontWeight: FontWeight.w800,
            color: AppColors.anchor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(width: 5.0 * scale),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 6.0 * scale,
            vertical: 3.0 * scale,
          ),
          decoration: BoxDecoration(
            color: AppColors.apricot,
            borderRadius: BorderRadius.circular(4.0 * scale),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            'AI',
            style: GoogleFonts.poppins(
              fontSize: 13.0 * scale,
              fontWeight: FontWeight.w800,
              color: AppColors.surface,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
