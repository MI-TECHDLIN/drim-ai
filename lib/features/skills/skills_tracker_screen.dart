import 'package:drim_ai/models/celebration_data.dart';
import 'package:drim_ai/widgets/drim_states.dart';
import 'package:drim_ai/widgets/skeletons/skills_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/career_match.dart';
import '../../models/skill_progress.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class SkillsTrackerScreen extends ConsumerStatefulWidget {
  final String matchId;
  final CareerMatch? initialMatch;

  const SkillsTrackerScreen({
    super.key,
    required this.matchId,
    this.initialMatch,
  });

  @override
  ConsumerState<SkillsTrackerScreen> createState() =>
      _SkillsTrackerScreenState();
}

class _SkillsTrackerScreenState extends ConsumerState<SkillsTrackerScreen> {
  List<SkillProgress>? _skills;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      if (widget.matchId.startsWith('fallback-')) {
        final skills =
            widget.initialMatch?.requiredSkills
                .map((s) => SkillProgress.local(s.name))
                .toList() ??
            [];
        if (mounted) {
          setState(() {
            _skills = skills;
            _isLoading = false;
          });
        }
      } else {
        final skills = await ref
            .read(skillProgressRepositoryProvider)
            .getSkills(widget.matchId);
        if (mounted) {
          setState(() {
            _skills = skills;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cycleStatus(SkillProgress skill) async {
    final next = skill.nextStatus;
    final isDone = next == 'done';

    setState(() => skill.status = next);
    ref.invalidate(dashboardProvider);

    if (!skill.id.startsWith('local_')) {
      try {
        await ref
            .read(skillProgressRepositoryProvider)
            .updateStatus(skill.id, next);
      } catch (_) {
        if (mounted) setState(() => skill.status = skill.nextStatus);
        return;
      }
    }

    if (isDone) {
      // Log activity
      await ref
          .read(activityRepositoryProvider)
          .logActivity(activityType: 'skill_done', intensity: 2);

      // Check badges
      final doneCount = (_skills ?? []).where((s) => s.status == 'done').length;
      final streak = await ref
          .read(activityRepositoryProvider)
          .getCurrentStreak();

      final newBadge = await ref
          .read(badgeRepositoryProvider)
          .checkAndAwardBadges(skillsDoneCount: doneCount, streakDays: streak);

      ref.invalidate(activityMapProvider);
      ref.invalidate(streakDataProvider);
      ref.invalidate(userBadgesProvider);

      if (!mounted) return;

      // Check if streak milestone hit
      final isStreakMilestone = streak == 7 || streak == 14 || streak == 30;

      if (isStreakMilestone) {
        final bestStreak = await ref
            .read(activityRepositoryProvider)
            .getBestStreak();
        final thisMonth = await ref
            .read(activityRepositoryProvider)
            .getThisMonthCount();

        if (!mounted) return;

        context.push(
          '/celebration/streak',
          extra: StreakCelebrationData(
            currentStreak: streak,
            bestStreak: bestStreak,
            thisMonth: thisMonth,
            newBadgeId: newBadge,
          ),
        );
      } else {
        context.push(
          '/celebration/skill',
          extra: SkillCelebrationData(
            skillName: skill.skillName,
            category: widget.initialMatch?.title ?? 'Career Skill',
            xpEarned: 50,
            newBadgeId: newBadge,
          ),
        );
      }
    }
  }

  int get _doneCount => (_skills ?? []).where((s) => s.status == 'done').length;

  double get _progress {
    final total = _skills?.length ?? 0;
    if (total == 0) return 0;
    return _doneCount / total;
  }

  @override
  Widget build(BuildContext context) {
    final skills = _skills ?? [];

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: _isLoading
            ? const SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: SkillsSkeleton(),
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.lg),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SquareIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => GoRouter.of(context).canPop()
                                  ? context.pop()
                                  : context.go('/home'),
                            ),
                            _SquareIconButton(
                              icon: Icons.more_horiz_rounded,
                              onTap: () => GoRouter.of(context).canPop()
                                  ? context.pop()
                                  : context.go('/home'),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          'SKILLS',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.anchor,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'COURSE PROGRESS',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '${(_progress * 100).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.anchor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          height: 14,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            boxShadow: const [AppShadows.hardSm],
                          ),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: _progress),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            builder: (_, val, _) => LinearProgressIndicator(
                              value: val,
                              backgroundColor: AppColors.surface,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.sage,
                              ),
                              minHeight: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            boxShadow: const [AppShadows.hard],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COURSES TO LEARN',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Pick up the next course and keep your learning momentum going.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        if (_hasError)
                          DrimErrorState(
                            title: 'Couldn\'t load your skills',
                            body: 'Tap retry to try again.',
                            onRetry: _loadSkills,
                          )
                        else if (skills.isEmpty)
                          DrimEmptyState(
                            icon: Icons.school_rounded,
                            title: 'No courses added yet',
                            body:
                                'Save a career path first — '
                                'your course list will appear here.',
                            buttonLabel: 'VIEW YOUR ROADMAP',
                            onAction: () => context.go('/roadmap'),
                          )
                        else
                          ...skills.map(
                            (skill) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _CourseCard(
                                skill: skill,
                                onTap: () => _cycleStatus(skill),
                              ),
                            ),
                          ),

                        const SizedBox(height: AppSpacing.xxl),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Skill row ──────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final SkillProgress skill;
  final VoidCallback onTap;

  const _CourseCard({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = skill.status == 'done';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: const [AppShadows.hardSm],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDone ? AppColors.sage : AppColors.apricot,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(
                isDone
                    ? Icons.check_rounded
                    : Icons.play_circle_outline_rounded,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.skillName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDone ? AppColors.muted : AppColors.ink,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDone ? 'Completed course' : 'Continue this course',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: skill.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;
    IconData? icon;

    switch (status) {
      case 'done':
        bg = AppColors.sage;
        textColor = AppColors.ink;
        label = 'DONE';
        icon = Icons.check_rounded;
        break;
      case 'learning':
        bg = AppColors.apricot;
        textColor = AppColors.ink;
        label = 'LEARNING';
        icon = null;
        break;
      default:
        bg = AppColors.surface;
        textColor = AppColors.muted;
        label = 'NOT STARTED';
        icon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse from career_detail (or extract to widgets/)
class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: const [AppShadows.hardSm],
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}
