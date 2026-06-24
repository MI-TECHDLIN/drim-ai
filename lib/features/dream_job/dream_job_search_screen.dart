import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dream_company_goal.dart';
import '../../models/user_goal.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/drim_states.dart';

class _DreamJobStartCard extends StatelessWidget {
  const _DreamJobStartCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final location = GoRouterState.of(context).matchedLocation;
        if (location != '/dream-job') {
          context.go('/dream-job');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: const [AppShadows.hard],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.apricot,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 22,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set a Dream Job',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'Get an AI gap analysis for any company.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _DreamJobActiveCard extends StatelessWidget {
  const _DreamJobActiveCard({required this.goal});

  final DreamCompanyGoal goal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final target = '/company-roadmap/${goal.id}';
        if (GoRouterState.of(context).matchedLocation != target) {
          context.go(target, extra: goal);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.anchor,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: const [AppShadows.hard],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.apricot,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'DREAM JOB',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${goal.doneSteps}/${goal.steps.length} STEPS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${goal.role} at ${goal.company}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.goal, required this.skillProgress});

  final UserGoal goal;
  final double skillProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GOAL PROGRESS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${goal.daysLeft} DAYS LEFT',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: skillProgress,
                    strokeWidth: 12,
                    backgroundColor: AppColors.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.sage,
                    ),
                  ),
                ),
                SizedBox(
                  width: 162,
                  height: 162,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.border,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(skillProgress * 100).round()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.anchor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'of goal complete',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _GoalChip(label: 'ON TRACK', color: AppColors.sage),
              const SizedBox(width: AppSpacing.sm),
              _GoalChip(label: '${(skillProgress * 10).round()} SKILLS DONE'),
              const SizedBox(width: AppSpacing.sm),
              _GoalChip(label: '${goal.daysLeft ~/ 7} THIS WEEK'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: goal.timeProgress,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
            minHeight: 8,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 13,
                color: AppColors.sage,
              ),
              const SizedBox(width: 4),
              Text(
                '${(10 / (goal.durationMonths * 4)).ceil()} skills/week to hit your goal',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.label, this.color = AppColors.surface});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.sm - 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SetGoalPrompt extends StatelessWidget {
  const _SetGoalPrompt();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/goal-setup'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, size: 18, color: AppColors.muted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Set a goal deadline to track your progress',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class DreamJobSearchScreen extends ConsumerStatefulWidget {
  const DreamJobSearchScreen({super.key});

  @override
  ConsumerState<DreamJobSearchScreen> createState() =>
      _DreamJobSearchScreenState();
}

class _DreamJobSearchScreenState extends ConsumerState<DreamJobSearchScreen> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  String _experienceLevel = 'newbie';
  bool _isLoading = false;

  static const _levels = [
    ('newbie', 'NEWBIE'),
    ('1-2 years', '1-2 YEARS'),
    ('3+ years', '3+ YEARS'),
  ];

  bool get _canAnalyse =>
      _companyController.text.trim().isNotEmpty &&
      _roleController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _analyse() async {
    if (!_canAnalyse || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(profileRepositoryProvider).getMyProfile();
      final quiz = await ref.read(quizRepositoryProvider).getLatestResponse();

      final userProfile = {
        'interests': quiz?['interests'] ?? [],
        'values': quiz?['values'] ?? [],
        'strengths': quiz?['strengths'] ?? [],
      };

      final goal = await ref
          .read(dreamCompanyRepositoryProvider)
          .analyzeGap(
            company: _companyController.text.trim(),
            role: _roleController.text.trim(),
            experienceLevel: _experienceLevel,
            userProfile: userProfile,
          );

      // Award dream chaser badge
      await ref.read(badgeRepositoryProvider).awardBadge('dream_chaser');
      ref.invalidate(activeDreamGoalProvider);
      ref.invalidate(userBadgesProvider);

      if (mounted) {
        if (goal != null) {
          context.go('/gap-analysis', extra: goal);
        } else {
          showDrimError(context, 'Could not analyse. Please try again.');
        }
      }
    } catch (_) {
      if (mounted)
        showDrimError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    boxShadow: const [AppShadows.hardSm],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.ink,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'YOUR DREAM JOB',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tell us where you want to go.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
              ),

              const SizedBox(height: AppSpacing.xl),

              Consumer(
                builder: (context, ref, _) {
                  final dreamGoalAsync = ref.watch(activeDreamGoalProvider);
                  return dreamGoalAsync.when(
                    data: (goal) => goal != null
                        ? _DreamJobActiveCard(goal: goal)
                        : const _DreamJobStartCard(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              Consumer(
                builder: (context, ref, _) {
                  final goalAsync = ref.watch(activeGoalProvider);
                  return goalAsync.when(
                    data: (goal) => goal != null
                        ? Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: _GoalProgressCard(
                              goal: goal,
                              skillProgress: goal.timeProgress,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: const _SetGoalPrompt(),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),

              // Search card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  boxShadow: const [AppShadows.hardLg],
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company field
                    Text(
                      'COMPANY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _companyController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'e.g. Google, GTBank, McKinsey',
                        suffixIcon: const Icon(
                          Icons.business_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.line,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.line,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.anchor,
                            width: 2,
                          ),
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Role field
                    Text(
                      'ROLE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _roleController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'e.g. Software Engineer, Investment Banker',
                        suffixIcon: const Icon(
                          Icons.work_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.line,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.line,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.anchor,
                            width: 2,
                          ),
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Experience level
              Text(
                'YOUR LEVEL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: _levels.map((level) {
                  final selected = _experienceLevel == level.$1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: level.$1 != '3+ years' ? AppSpacing.sm : 0,
                      ),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _experienceLevel = level.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md - 2,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.anchor
                                : AppColors.surface,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadii.sm + 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              level.$2,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Analyse button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: (_canContinue && !_isLoading)
                      ? const [AppShadows.hard]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: (_canAnalyse && !_isLoading) ? _analyse : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.anchor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.anchor.withOpacity(0.45),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
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
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'ANALYSE MY GAP  →',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canContinue => _canAnalyse;
}
