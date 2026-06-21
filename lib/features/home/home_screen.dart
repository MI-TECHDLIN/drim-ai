import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/drim_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DrimLogo(scale: 1.4),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Phase 1 complete ✓',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Onboarding coming in Phase 2',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.muted.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
