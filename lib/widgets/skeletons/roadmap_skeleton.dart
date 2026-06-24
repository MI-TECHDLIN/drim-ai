import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'skeleton_box.dart';
import 'skeleton_pill.dart';

class RoadmapSkeleton extends StatelessWidget {
  const RoadmapSkeleton({super.key});

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
            const SkeletonBox(width: 160, height: 36, hasBorder: false),
            const SizedBox(height: AppSpacing.xs),
            const SkeletonBox(width: 200, height: 16, hasBorder: false),
            const SizedBox(height: AppSpacing.xl),
            ...[0, 1, 2].map(
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    side: BorderSide(
                      color: AppColors.border.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: SkeletonBox(height: 20, hasBorder: false),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            SkeletonBox(
                              width: 52,
                              height: 30,
                              borderRadius: 6,
                              hasBorder: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const SkeletonBox(height: 14, hasBorder: false),
                        const SizedBox(height: 4),
                        const SkeletonBox(
                          width: 200,
                          height: 14,
                          hasBorder: false,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const SkeletonPill(width: 72, height: 26),
                            const SizedBox(width: AppSpacing.sm),
                            const SkeletonPill(width: 88, height: 26),
                            const Spacer(),
                            SkeletonBox(
                              width: 90,
                              height: 34,
                              borderRadius: 8,
                              hasBorder: false,
                            ),
                          ],
                        ),
                      ],
                    ),
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
