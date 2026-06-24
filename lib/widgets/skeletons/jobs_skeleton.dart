import 'package:flutter/material.dart';
import 'package:drim_ai/theme/app_spacing.dart';
import 'skeleton_box.dart';
import 'skeleton_pill.dart';

class JobsSkeleton extends StatelessWidget {
  const JobsSkeleton({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: 8,
                  hasBorder: false,
                ),
                SkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: 8,
                  hasBorder: false,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(width: 240, height: 30, hasBorder: false),
            SizedBox(height: 6),
            SkeletonBox(width: 170, height: 14, hasBorder: false),
            const SizedBox(height: AppSpacing.lg),
            ...List.generate(3, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonBox(
                                    width: 100,
                                    height: 11,
                                    hasBorder: false,
                                  ),
                                  const SizedBox(height: 6),
                                  SkeletonBox(height: 20, hasBorder: false),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            SkeletonBox(
                              width: 40,
                              height: 40,
                              borderRadius: 8,
                              hasBorder: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            SkeletonPill(width: 110, height: 26),
                            const SizedBox(width: AppSpacing.sm),
                            SkeletonPill(width: 80, height: 26),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SkeletonBox(height: 1, hasBorder: false),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonBox(
                              width: 90,
                              height: 12,
                              hasBorder: false,
                            ),
                            SkeletonBox(
                              width: 100,
                              height: 36,
                              borderRadius: 8,
                              hasBorder: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
