import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import 'skeleton_box.dart';
import 'skeleton_pill.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── "HEY, AMARA 👋" ──────────────────────────────────────
            SkeletonBox(width: 220, height: 34, hasBorder: false),
            const SizedBox(height: AppSpacing.sm),
            SkeletonBox(width: 160, height: 16, hasBorder: false),

            const SizedBox(height: AppSpacing.xl),

            // ── YOUR PATH card ───────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "YOUR PATH" badge
                    SkeletonPill(width: 90, height: 26),
                    const SizedBox(height: AppSpacing.md),
                    // Career title
                    SkeletonBox(width: 180, height: 28, hasBorder: false),
                    const SizedBox(height: 6),
                    // Sub-track
                    SkeletonBox(width: 130, height: 14, hasBorder: false),
                    const SizedBox(height: AppSpacing.md),
                    // "SKILLS PROGRESS" label
                    SkeletonBox(width: 110, height: 12, hasBorder: false),
                    const SizedBox(height: AppSpacing.sm),
                    // Progress bar
                    SkeletonBox(
                      height: 14,
                      borderRadius: 999,
                      hasBorder: false,
                    ),
                    const SizedBox(height: 6),
                    // "X of Y skills" text
                    SkeletonBox(width: 150, height: 13, hasBorder: false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── NEXT STEP card (apricot — use line color approx) ─────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 80, height: 12, hasBorder: false),
                          const SizedBox(height: 6),
                          SkeletonBox(height: 20, hasBorder: false),
                          const SizedBox(height: 6),
                          SkeletonBox(width: 160, height: 13, hasBorder: false),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SkeletonBox(
                      width: 40,
                      height: 40,
                      borderRadius: 8,
                      hasBorder: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── YOUR CONFIDENCE card ─────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 12, hasBorder: false),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        SkeletonBox(width: 52, height: 44, hasBorder: false),
                        const SizedBox(width: AppSpacing.md),
                        SkeletonBox(width: 28, height: 28, hasBorder: false),
                        const SizedBox(width: AppSpacing.md),
                        SkeletonBox(width: 52, height: 44, hasBorder: false),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SkeletonBox(
                      height: 10,
                      borderRadius: 999,
                      hasBorder: false,
                    ),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 200, height: 13, hasBorder: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
