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
import '../career_detail/career_detail_screen.dart';

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
  bool _isLoading = true;
  final bool _isFallback = false;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      if (widget.matchId.startsWith('fallback-')) {
        // Use initialMatch's requiredSkills as local state
        final skills =
            widget.initialMatch?.requiredSkills
                .map((s) => SkillProgress.local(s.name))
                .toList() ??
            [];
        if (mounted)
          setState(() {
            _skills = skills;
            _isLoading = false;
          });
      } else {
        final skills = await ref
            .read(skillProgressRepositoryProvider)
            .getSkills(widget.matchId);
        if (mounted)
          setState(() {
            _skills = skills;
            _isLoading = false;
          });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cycleStatus(SkillProgress skill) async {
    final next = skill.nextStatus;

    setState(() => skill.status = next);

    if (!skill.id.startsWith('local_')) {
      try {
        await ref
            .read(skillProgressRepositoryProvider)
            .updateStatus(skill.id, next);
      } catch (_) {
        // Revert on failure
        if (mounted) setState(() => skill.status = skill.nextStatus);
      }
    }
  }

  int get _doneCount => (_skills ?? []).where((s) => s.status == 'done').length;

  double get _progress {
    final total = _skills?.length ?? 0;
    if (total == 0) return 0;
    return _doneCount / total;
  }

  // 12-week × 7-day mock heatmap (fixed, looks realistic for demo)
  static const _heatmapData = [
    [0, 0, 1, 0, 0, 0, 1],
    [0, 1, 0, 1, 0, 0, 0],
    [1, 0, 2, 0, 1, 0, 0],
    [0, 2, 1, 0, 2, 0, 1],
    [1, 1, 2, 1, 1, 0, 0],
    [2, 1, 3, 2, 1, 1, 0],
    [1, 2, 2, 3, 2, 0, 1],
    [2, 3, 3, 2, 3, 1, 0],
    [3, 2, 4, 3, 2, 1, 1],
    [3, 4, 3, 4, 3, 2, 0],
    [4, 3, 4, 3, 4, 2, 1],
    [3, 4, 3, 4, 3, 1, 0],
  ];

  Color _heatColor(int level) {
    switch (level) {
      case 0:
        return AppColors.line;
      case 1:
        return AppColors.sage.withOpacity(0.25);
      case 2:
        return AppColors.sage.withOpacity(0.55);
      case 3:
        return AppColors.sage;
      default:
        return AppColors.anchor.withOpacity(0.75);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skills = _skills ?? [];
    final title = widget.initialMatch?.title ?? 'Career';

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.anchor,
                  strokeWidth: 2,
                ),
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

                        // ── Header row ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SquareIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => context.pop(),
                            ),
                            _SquareIconButton(
                              icon: Icons.more_horiz_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          'SKILLS TRACKER',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.anchor,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Course progress ────────────────────────
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
                            builder: (_, val, __) => LinearProgressIndicator(
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

                        // ── Skill streak heatmap ───────────────────
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'SKILL STREAK',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        '🔥',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '12 DAY STREAK',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.apricot,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Heatmap grid
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Day labels
                                  Column(
                                    children:
                                        ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                            .map(
                                              (d) => SizedBox(
                                                height: 14,
                                                width: 14,
                                                child: Text(
                                                  d,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 9,
                                                    color: AppColors.muted,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),

                                  // Grid
                                  Expanded(
                                    child: Column(
                                      children: List.generate(7, (dayIndex) {
                                        return Row(
                                          children: List.generate(
                                            _heatmapData.length,
                                            (weekIndex) {
                                              final level =
                                                  _heatmapData[weekIndex][dayIndex];
                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    1.5,
                                                  ),
                                                  child: Container(
                                                    height: 11,
                                                    decoration: BoxDecoration(
                                                      color: _heatColor(level),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // Legend
                              Row(
                                children: [
                                  Text(
                                    'LESS',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  ...List.generate(
                                    5,
                                    (i) => Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(
                                        color: _heatColor(i),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'MORE',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(
                                color: AppColors.line,
                                height: AppSpacing.xl,
                                thickness: 1,
                              ),

                              // Stats row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _StatCell(
                                    label: 'BEST STREAK',
                                    value: '18 DAYS',
                                  ),
                                  _StatCell(
                                    label: 'THIS MONTH',
                                    value: '24 SESSIONS',
                                  ),
                                  _StatCell(
                                    label: 'TOTAL TIME',
                                    value: '156 HRS',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Skill rows ─────────────────────────────
                        if (skills.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            child: Text(
                              'No skills tracked yet.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.muted,
                              ),
                            ),
                          )
                        else
                          ...skills.map(
                            (skill) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _SkillRow(
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

class _SkillRow extends StatelessWidget {
  final SkillProgress skill;
  final VoidCallback onTap;

  const _SkillRow({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                skill.skillName,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: skill.status == 'done'
                      ? AppColors.muted
                      : AppColors.ink,
                  decoration: skill.status == 'done'
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: AppColors.muted,
                ),
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
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
