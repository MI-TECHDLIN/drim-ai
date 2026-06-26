import 'package:drim_ai/models/dream_company_goal.dart';
import 'package:drim_ai/widgets/drim_bottom_nav.dart';
import 'package:drim_ai/widgets/drim_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard_data.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/skeletons/home_skeleton.dart';
import 'package:drim_ai/features/dream_job/dream_job_search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Column(
        children: [
          // Scrollable content
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
                        // ── Greeting ──────────────────────────────────
                        profileAsync.when(
                          data: (profile) {
                            final name = profile?.displayName ?? '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty
                                      ? 'HEY, ${name.toUpperCase()} 👋'
                                      : 'HEY THERE 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.anchor,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Here\'s where you stand today.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(height: 60),
                          error: (_, _) => const SizedBox(height: 60),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Dashboard cards ────────────────────────────
                        // Inside HomeScreen.build(), update dashboardAsync.when:
                        dashboardAsync.when(
                          data: (data) => _DashboardCards(
                            data: data,
                            onRefresh: () => ref.invalidate(dashboardProvider),
                          ),
                          loading: () => const _LoadingCards(),
                          error: (error, _) => DrimErrorState(
                            title: 'Couldn\'t load your dashboard',
                            body:
                                'Something went wrong fetching your progress. '
                                'Tap retry — your data is still safe.',
                            buttonLabel: 'RETRY',
                            onRetry: () => ref.invalidate(dashboardProvider),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Consumer(
                          builder: (context, ref, _) {
                            final dreamGoalAsync = ref.watch(
                              activeDreamGoalProvider,
                            );
                            return dreamGoalAsync.when(
                              data: (goal) => goal != null
                                  ? _DreamJobActiveCard(goal: goal)
                                  : const _DreamJobStartCard(),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) =>
                                  const SizedBox.shrink(), // ← FIXED
                            );
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom nav ─────────────────────────────────────────────────
          const DrimBottomNav(currentRoute: '/home'),
        ],
      ),
    );
  }
}

// ── Dashboard cards — switches on saved path status ────────────────────────

class _DashboardCards extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onRefresh;

  const _DashboardCards({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // No saved path → show quiz/roadmap CTAs
    if (data.savedMatch == null) {
      return _EmptyState(onStart: () => context.go('/quiz'));
    }

    final match = data.savedMatch!;

    return Column(
      children: [
        // ── YOUR PATH card ─────────────────────────────────────────────
        _YourPathCard(
          data: data,
          onTap: () => context.go('/career/${match.id}', extra: match),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── NEXT STEP card ─────────────────────────────────────────────
        if (data.nextSkill != null)
          _NextStepCard(
            data: data,
            onTap: () {
              // Push the skills screen and refresh dashboard if the user changed anything there.
              context.push('/skills/${match.id}', extra: match).then((changed) {
                if (changed == true) {
                  onRefresh();
                }
              });
            },
          ),

        if (data.nextSkill != null) const SizedBox(height: AppSpacing.md),

        // ── YOUR CONFIDENCE card ───────────────────────────────────────
        if (data.preScore != null)
          _ConfidenceCard(data: data)
        else
          _ConfidenceCheckCta(onTap: () => context.go('/confidence-pre')),

        const SizedBox(height: AppSpacing.md),

        // ── Post-check CTA (if pre done but post not yet) ───────────────
        if (data.preScore != null && data.postScore == null)
          _PostCheckPrompt(onTap: () => context.go('/confidence-post')),
      ],
    );
  }
}

// ── YOUR PATH card ─────────────────────────────────────────────────────────

class _YourPathCard extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onTap;

  const _YourPathCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final match = data.savedMatch!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: const [AppShadows.hard],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.anchor,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                'YOUR PATH',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Career title
            Text(
              match.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Product & Design Track',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            ),

            const SizedBox(height: AppSpacing.md),

            // Skills progress
            Text(
              'SKILLS PROGRESS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Container(
              height: 14,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.line,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: const [AppShadows.hardSm],
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: data.skillProgress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, val, _) => LinearProgressIndicator(
                  value: val,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.sage,
                  ),
                  minHeight: 14,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              data.totalSkills == 0
                  ? 'Skills loading...'
                  : '${data.inProgressCount} of ${data.totalSkills} skills in progress',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── NEXT STEP card ─────────────────────────────────────────────────────────

class _NextStepCard extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onTap;

  const _NextStepCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final skill = data.nextSkill!;
    final skillIndex = data.nextSkillIndex(skill);
    final total = data.totalSkills;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.apricot,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: const [AppShadows.hard],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT STEP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Complete \'${skill.skillName}\' module',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estimated 30–45 min · Module $skillIndex of $total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.ink.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── YOUR CONFIDENCE card ───────────────────────────────────────────────────

class _ConfidenceCard extends StatelessWidget {
  final DashboardData data;

  const _ConfidenceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final pre = data.preScore!;
    final post = data.postScore;
    final delta = data.confidenceDelta;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR CONFIDENCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Score display
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$pre',
                style: GoogleFonts.poppins(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted.withOpacity(0.5),
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.apricot,
                  size: 28,
                ),
              ),
              Text(
                post != null ? '$post' : '?',
                style: GoogleFonts.poppins(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: post != null
                      ? AppColors.sage
                      : AppColors.muted.withOpacity(0.3),
                  height: 1.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Sage progress bar (shows post/10 or pre/10)
          Container(
            height: 10,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.line,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: (post ?? pre) / 10.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (_, val, _) => LinearProgressIndicator(
                value: val,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
                minHeight: 10,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            delta != null
                ? 'You grew $delta ${delta == 1 ? 'point' : 'points'} on this journey'
                : 'Take your post-check to see your growth',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.muted,
              fontStyle: delta == null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Post-check prompt (shown when pre done but post not yet) ───────────────

class _PostCheckPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _PostCheckPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sage.withOpacity(0.15),
          border: Border.all(color: AppColors.sage, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Ready to check how much you\'ve grown?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.anchor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.anchor,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pre-check CTA (no confidence score yet) ────────────────────────────────

class _ConfidenceCheckCta extends StatelessWidget {
  final VoidCallback onTap;
  const _ConfidenceCheckCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: const [AppShadows.hardSm],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR CONFIDENCE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Rate how sure you feel right now',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.ink,
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

// ── Empty state (no saved path yet) ───────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 2),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: const [AppShadows.hard],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.apricot.withOpacity(0.2),
                  border: Border.all(color: AppColors.apricot, width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  'START HERE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.apricot,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Discover your\ncareer path',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '8 questions. No right answers.\nJust what feels true to you.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: const [AppShadows.hardSm],
                ),
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.anchor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: const BorderSide(color: AppColors.border, width: 2),
                    ),
                  ),
                  child: Text(
                    'BEGIN THE QUIZ  →',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Loading state ──────────────────────────────────────────────────────────
class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) => const HomeSkeleton();
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
