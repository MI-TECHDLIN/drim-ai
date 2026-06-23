import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';

class ConfidenceMeter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isPost;

  const ConfidenceMeter({
    super.key,
    required this.value,
    required this.onChanged,
    this.isPost = false,
  });

  String get _label {
    if (isPost) {
      if (value <= 3) return 'STILL FINDING MY WAY';
      if (value <= 5) return 'GETTING CLEARER';
      if (value <= 7) return 'FEELING MORE CONFIDENT!';
      if (value <= 9) return 'MUCH MORE CONFIDENT!';
      return 'FULLY CONFIDENT!';
    }
    if (value <= 2) return 'NOT SURE AT ALL';
    if (value <= 4) return 'NOT VERY SURE YET';
    if (value <= 6) return 'SOMEWHAT SURE';
    if (value <= 8) return 'PRETTY CONFIDENT';
    return 'VERY SURE';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '\$value',
          style: GoogleFonts.poppins(
            fontSize: 96,
            fontWeight: FontWeight.w800,
            color: AppColors.anchor,
            height: 1.0,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          _label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 16,
                right: 16,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 14,
                  activeTrackColor: AppColors.sage,
                  inactiveTrackColor: AppColors.surface,
                  thumbColor: AppColors.anchor,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14,
                    elevation: 0,
                    pressedElevation: 0,
                  ),
                  overlayColor: AppColors.anchor.withOpacity(0.12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          height: 14,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.border, width: 2),
            color: AppColors.surface,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value / 10.0),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOut,
            builder: (context, animVal, _) => LinearProgressIndicator(
              value: animVal,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
              minHeight: 14,
            ),
          ),
        ),
      ],
    );
  }
}
