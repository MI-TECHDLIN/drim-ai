import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../drim_skeleton.dart';

class JobsSkeleton extends StatelessWidget {
  const JobsSkeleton({super.key});

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

            // "REAL OPPORTUNITIES"
            const SkeletonBox(width: 240, height: 30, hasBorder: false),
            const SizedBox(height: 6),
            const SkeletonBox(width: 170, height: 14, hasBorder: false),

            const SizedBox(height: AppSpacing.lg),

            // 3 job card skeletons
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                // Company name
                                SkeletonBox(
                                  width: 100,
                                  height: 11,
                                  hasBorder: false,
                                ),
                                SizedBox(height: 6),
                                // Job title
                                SkeletonBox(height: 20, hasBorder: false),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Icon square
                          const SkeletonBox(
                            width: 40,
                            height: 40,
                            borderRadius: 8,
                            hasBorder: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Location + salary chips
                      Row(
                        children: const [
                          SkeletonPill(width: 110, height: 26),
                          SizedBox(width: AppSpacing.sm),
                          SkeletonPill(width: 80, height: 26),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Divider approx
                      const SkeletonBox(height: 1, hasBorder: false),

                      const SizedBox(height: AppSpacing.sm),

                      // "POSTED Xh ago" + VIEW JOB button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SkeletonBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
