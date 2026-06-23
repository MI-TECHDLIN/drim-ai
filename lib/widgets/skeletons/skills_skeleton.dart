import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../drim_skeleton.dart';

class SkillsSkeleton extends StatelessWidget {
  const SkillsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DrimShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: 8,
                  hasBorder: false,
                ),
                const SkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: 8,
                  hasBorder: false,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // "SKILLS TRACKER" heading
            const SkeletonBox(width: 200, height: 32, hasBorder: false),

            const SizedBox(height: AppSpacing.xl),

            // "COURSE PROGRESS" row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 120, height: 12, hasBorder: false),
                SkeletonBox(width: 36, height: 16, hasBorder: false),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const SkeletonBox(height: 14, borderRadius: 4, hasBorder: false),

            const SizedBox(height: AppSpacing.xl),

            // Heatmap card
            SkeletonCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBox(width: 90, height: 12, hasBorder: false),
                      SkeletonBox(width: 110, height: 12, hasBorder: false),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Grid skeleton (7 rows of 12 cols)
                  ...List.generate(
                    7,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: List.generate(
                          12,
                          (col) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: SkeletonBox(
                                height: 11,
                                borderRadius: 2,
                                hasBorder: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 6 skill row skeletons
            ...List.generate(
              6,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SkeletonCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SkeletonBox(
                          width: 100 + (i % 3 * 40).toDouble(),
                          height: 16,
                          hasBorder: false,
                        ),
                      ),
                      SkeletonPill(
                        width: i % 3 == 0
                            ? 60
                            : i % 3 == 1
                            ? 80
                            : 96,
                        height: 28,
                      ),
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
