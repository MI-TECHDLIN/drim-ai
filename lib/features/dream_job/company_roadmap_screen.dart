import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dream_company_goal.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class CompanyRoadmapScreen extends ConsumerStatefulWidget {
  final String goalId;
  final DreamCompanyGoal? initialGoal;

  const CompanyRoadmapScreen({
    super.key,
    required this.goalId,
    this.initialGoal,
  });

  @override
  ConsumerState<CompanyRoadmapScreen> createState() =>
      _CompanyRoadmapScreenState();
}

class _CompanyRoadmapScreenState extends ConsumerState<CompanyRoadmapScreen> {
  DreamCompanyGoal? _goal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goal = widget.initialGoal;
    if (_goal == null) _loadGoal();
  }

  Future<void> _loadGoal() async {
    final goal = await ref.read(dreamCompanyRepositoryProvider).getActiveGoal();
    if (mounted) setState(() => _goal = goal);
  }

  Future<void> _markStepDone() async {
    if (_goal == null || _isLoading) return;
    final activeIndex = _goal!.steps.indexWhere((s) => s.status == 'active');
    if (activeIndex == -1) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(dreamCompanyRepositoryProvider)
          .markStepDone(_goal!.id, activeIndex, _goal!.steps);

      // Log activity
      await ref
          .read(activityRepositoryProvider)
          .logActivity(activityType: 'company_step_done', intensity: 3);

      ref.invalidate(activeDreamGoalProvider);
      await _loadGoal();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _activeStepIndex =>
      _goal?.steps.indexWhere((s) => s.status == 'active') ?? 0;

  @override
  Widget build(BuildContext context) {
    final goal = _goal;

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Header row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ROAD TO ${(goal?.company ?? '').toUpperCase()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.anchor,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    '${goal?.role ?? ''} · Your personalized plan',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Back button
                            GestureDetector(
                              onTap: () {
                                if (GoRouter.of(context).canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.sm,
                                  ),
                                  boxShadow: const [AppShadows.hardSm],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 22,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Progress bar + step counter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'STEP ${_activeStepIndex + 1} OF ${goal?.steps.length ?? 0}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0.0,
                                end: goal?.progress ?? 0,
                              ),
                              duration: const Duration(milliseconds: 500),
                              builder: (_, val, _) => Container(
                                height: 10,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: LinearProgressIndicator(
                                  value: val,
                                  backgroundColor: AppColors.surface,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.anchor,
                                      ),
                                  minHeight: 10,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Step cards
                        if (goal != null)
                          ...goal.steps.map(
                            (step) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _StepCard(step: step),
                            ),
                          ),

                        const SizedBox(height: AppSpacing.md),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // MARK STEP DONE button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: const [AppShadows.hard],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _markStepDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    foregroundColor: AppColors.ink,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: const BorderSide(color: AppColors.border, width: 2),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MARK STEP DONE',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.check_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final CompanyRoadmapStep step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final isDone = step.status == 'done';
    final isActive = step.status == 'active';
    final isLocked = step.status == 'locked';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: isActive ? AppColors.apricot : AppColors.border,
          width: isActive ? 2 : 2,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: isLocked ? [] : const [AppShadows.hard],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '0${step.order}',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDone
                      ? AppColors.sage
                      : isLocked
                      ? AppColors.line
                      : AppColors.muted.withOpacity(0.4),
                  height: 1.0,
                ),
              ),
              const Spacer(),
              if (isDone)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.apricot,
                    border: Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadii.sm - 2),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            step.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isLocked ? AppColors.muted : AppColors.ink,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            isLocked
                ? 'Locked until Step ${step.order - 1} is complete.'
                : step.detail,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.muted,
              fontStyle: isLocked ? FontStyle.italic : FontStyle.normal,
              height: 1.4,
            ),
          ),

          if (isActive) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _InfoChip('${step.taskCount} TASKS'),
                const SizedBox(width: AppSpacing.sm),
                _InfoChip('${step.resourceCount} RESOURCES'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.sm - 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
