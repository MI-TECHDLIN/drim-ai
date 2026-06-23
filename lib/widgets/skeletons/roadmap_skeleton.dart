import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class DrimShimmer extends StatefulWidget {
  final Widget child;

  const DrimShimmer({super.key, required this.child});

  @override
  State<DrimShimmer> createState() => _DrimShimmerState();

  static _DrimShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_DrimShimmerState>();
  }
}

class _DrimShimmerState extends State<DrimShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  LinearGradient get gradient => LinearGradient(
    colors: [AppColors.line, AppColors.sand, AppColors.line],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment(-2.0 + _controller.value * 4, -0.3),
    end: Alignment(-1.0 + _controller.value * 4, 0.3),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double? borderRadius;
  final bool hasBorder;
  final bool hasShadow;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.hasBorder = true,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final shimmer = DrimShimmer.of(context);
    final gradient =
        shimmer?.gradient ??
        const LinearGradient(
          colors: [AppColors.line, AppColors.sand, AppColors.line],
        );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.sm),
        border: hasBorder
            ? Border.all(color: AppColors.border.withOpacity(0.2), width: 1.5)
            : null,
        boxShadow: hasShadow ? const [AppShadows.hardSm] : null,
      ),
    );
  }
}

class SkeletonPill extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonPill({super.key, required this.width, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: AppRadii.pill,
      hasBorder: false,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const SkeletonCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      child: child,
    );
  }
}

class RoadmapSkeleton extends StatelessWidget {
  const RoadmapSkeleton({super.key});

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
            const SkeletonBox(width: 160, height: 36, hasBorder: false),
            const SizedBox(height: AppSpacing.xs),
            const SkeletonBox(width: 200, height: 16, hasBorder: false),
            const SizedBox(height: AppSpacing.xl),
            ...[0, 1, 2].map(
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: SkeletonCard(
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
          ],
        ),
      ),
    );
  }
}
