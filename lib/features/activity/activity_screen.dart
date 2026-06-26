import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/skill_progress.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/drim_bottom_nav.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  Color _heatColor(int intensity) {
    if (intensity <= 0) return AppColors.line.withOpacity(0.5);
    if (intensity == 1) return AppColors.sage.withOpacity(0.25);
    if (intensity == 2) return AppColors.sage.withOpacity(0.55);
    if (intensity == 3) return AppColors.sage;
    return AppColors.anchor.withOpacity(0.85);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityMapProvider);
    final streakAsync = ref.watch(streakDataProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'YOUR ACTIVITY',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            profileAsync.when(
                              data: (profile) => GestureDetector(
                                onTap: () => context.go('/profile'),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.anchor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      profile?.displayName?[0].toUpperCase() ??
                                          '?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              loading: () =>
                                  const SizedBox(width: 40, height: 40),
                              error: (_, _) =>
                                  const SizedBox(width: 40, height: 40),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // MOMENTUM MAP card
                        activityAsync.when(
                          data: (activityMap) => streakAsync.when(
                            data: (streak) => _MomentumCard(
                              activityMap: activityMap,
                              currentStreak: streak['current'] ?? 0,
                              bestStreak: streak['best'] ?? 0,
                              heatColor: _heatColor,
                            ),
                            loading: () => const _LoadingCard(height: 300),
                            error: (_, _) => const _LoadingCard(height: 300),
                          ),
                          loading: () => const _LoadingCard(height: 300),
                          error: (_, _) => const _LoadingCard(height: 300),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Stat cards row
                        streakAsync.when(
                          data: (streak) => Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'WEEKLY SCORE',
                                  value: '${streak['weeklyScore'] ?? 0}',
                                  sub: '▲ vs last week',
                                  subColor: AppColors.sage,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _StatCard(
                                  label: 'AVG INTENSITY',
                                  value: _intensityLabel(
                                    streak['weeklyScore'] ?? 0,
                                  ),
                                  sub: 'STABLE',
                                  subColor: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          loading: () => Row(
                            children: [
                              Expanded(child: _LoadingCard(height: 80)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: _LoadingCard(height: 80)),
                            ],
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        dashboardAsync.when(
                          data: (data) => _CourseProgressSection(
                            skills: data.skills,
                            onTap: (skill) => _handleCourseTap(ref, skill),
                          ),
                          loading: () => const _LoadingCard(height: 220),
                          error: (_, _) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const DrimBottomNav(currentRoute: '/activity'),
        ],
      ),
    );
  }

  Future<void> _handleCourseTap(WidgetRef ref, SkillProgress skill) async {
    final next = skill.nextStatus;
    final isDone = next == 'done';

    if (!skill.id.startsWith('local_')) {
      try {
        await ref
            .read(skillProgressRepositoryProvider)
            .updateStatus(skill.id, next);
      } catch (_) {
        return;
      }
    }

    if (isDone) {
      await ref
          .read(activityRepositoryProvider)
          .logActivity(activityType: 'skill_done', intensity: 2);
    }

    ref.invalidate(dashboardProvider);
    ref.invalidate(activityMapProvider);
    ref.invalidate(streakDataProvider);
  }

  String _intensityLabel(int score) {
    if (score >= 800) return 'HIGH';
    if (score >= 400) return 'MEDIUM';
    return 'LOW';
  }
}

class _CourseProgressSection extends StatelessWidget {
  final List<SkillProgress> skills;
  final ValueChanged<SkillProgress> onTap;

  const _CourseProgressSection({required this.skills, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }

    final doneCount = skills.where((s) => s.status == 'done').length;
    final total = skills.length;
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              '${(progress * 100).round()}%',
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
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [AppShadows.hardSm],
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, val, _) => LinearProgressIndicator(
              value: val,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
              minHeight: 14,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 2),
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
                'Tap a course to update your progress and keep momentum going.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...skills.map(
          (skill) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _CourseCard(skill: skill, onTap: () => onTap(skill)),
          ),
        ),
      ],
    );
  }
}

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

class _MomentumCard extends StatelessWidget {
  final Map<String, int> activityMap;
  final int currentStreak;
  final int bestStreak;
  final Color Function(int) heatColor;

  const _MomentumCard({
    required this.activityMap,
    required this.currentStreak,
    required this.bestStreak,
    required this.heatColor,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isStreakAtRisk =
        activityMap[now.toIso8601String().split('T')[0]] == null;

    // Build 12 weeks × 7 days grid
    final weeks = <List<DateTime>>[];
    DateTime current = now;
    // Align to start of week (Monday)
    while (current.weekday != DateTime.monday) {
      current = current.subtract(const Duration(days: 1));
    }
    // Go back 11 more weeks
    current = current.subtract(const Duration(days: 77));

    for (int w = 0; w < 12; w++) {
      final week = <DateTime>[];
      for (int d = 0; d < 7; d++) {
        week.add(current.add(Duration(days: w * 7 + d)));
      }
      weeks.add(week);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOMENTUM MAP',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'LAST 12 WEEKS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isStreakAtRisk)
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'STREAK AT RISK',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Heatmap grid
          Row(
            children: weeks.map((week) {
              return Expanded(
                child: Column(
                  children: week.map((date) {
                    final key = date.toIso8601String().split('T')[0];
                    final intensity = activityMap[key] ?? 0;
                    final isToday = _isToday(date);

                    return Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.anchor
                              : heatColor(intensity),
                          borderRadius: BorderRadius.circular(2),
                          border: isToday
                              ? Border.all(color: AppColors.border, width: 1)
                              : null,
                        ),
                        child: isToday
                            ? const Center(
                                child: CircleAvatar(
                                  radius: 2,
                                  backgroundColor: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Streak row
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'CURRENT STREAK',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '$currentStreak DAYS',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Streak progress bar
          Container(
            height: 10,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.line,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: LinearProgressIndicator(
              value: bestStreak == 0
                  ? 0
                  : (currentStreak / bestStreak).clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
            ),
          ),

          const SizedBox(height: 4),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'YOUR BEST: $bestStreak DAYS',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color subColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: const [AppShadows.hard],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.anchor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
