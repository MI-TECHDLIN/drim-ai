import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'skeleton_box.dart';
import 'skeleton_pill.dart';
import 'skeleton_card.dart';

class CareerDetailSkeleton extends StatelessWidget {
  const CareerDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(
              width: 44,
              height: 44,
              borderRadius: 8,
              hasBorder: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SkeletonBox(width: 240, height: 36, hasBorder: false),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 90, height: 14, hasBorder: false),
                SkeletonBox(width: 110, height: 14, hasBorder: false),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const SkeletonBox(height: 14, borderRadius: 4, hasBorder: false),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                const SkeletonBox(width: 80, height: 13, hasBorder: false),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonBox(height: 1.5, hasBorder: false)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SkeletonCard(
              child: Column(
                children: const [
                  SkeletonBox(height: 14, hasBorder: false),
                  SizedBox(height: 6),
                  SkeletonBox(height: 14, hasBorder: false),
                  SizedBox(height: 6),
                  SkeletonBox(width: 200, height: 14, hasBorder: false),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                const SkeletonBox(width: 130, height: 13, hasBorder: false),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonBox(height: 1.5, hasBorder: false)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: const [
                SkeletonPill(width: 88, height: 36),
                SizedBox(width: AppSpacing.sm),
                SkeletonPill(width: 96, height: 36),
                SizedBox(width: AppSpacing.sm),
                SkeletonPill(width: 80, height: 36),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                const SkeletonBox(width: 110, height: 13, hasBorder: false),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonBox(height: 1.5, hasBorder: false)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...[0, 1, 2].map(
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonCard(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      SkeletonBox(
                        width: 48,
                        height: 68,
                        borderRadius: 0,
                        hasBorder: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonBox(
                              width: 140,
                              height: 13,
                              hasBorder: false,
                            ),
                            SizedBox(height: 6),
                            SkeletonBox(height: 13, hasBorder: false),
                            SizedBox(height: 4),
                            SkeletonBox(
                              width: 180,
                              height: 13,
                              hasBorder: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
