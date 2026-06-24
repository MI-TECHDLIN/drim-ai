import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import 'skeleton_box.dart';
import 'skeleton_pill.dart';
import 'skeleton_card.dart';

class SkillsSkeleton extends StatelessWidget {
  const SkillsSkeleton({super.key});

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

            // "SKILLS" heading
            const SkeletonBox(width: 140, height: 32, hasBorder: false),

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

            // Courses to learn card
            SkeletonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 120, height: 12, hasBorder: false),
                  const SizedBox(height: AppSpacing.sm),
                  const SkeletonBox(width: 240, height: 12, hasBorder: false),
                  const SizedBox(height: AppSpacing.xs),
                  const SkeletonBox(width: 200, height: 12, hasBorder: false),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 4 course card skeletons
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SkeletonCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const SkeletonBox(
                        width: 42,
                        height: 42,
                        borderRadius: 10,
                        hasBorder: false,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                              width: 120 + (i % 3 * 40).toDouble(),
                              height: 16,
                              hasBorder: false,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SkeletonBox(
                              width: 90 + (i % 2 * 30).toDouble(),
                              height: 12,
                              hasBorder: false,
                            ),
                          ],
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
