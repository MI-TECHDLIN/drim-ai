import 'package:drim_ai/widgets/drim_states.dart';
import 'package:drim_ai/widgets/skeletons/career_detail_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/career_match.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerDetailScreen extends ConsumerStatefulWidget {
  final String matchId;
  final CareerMatch? initialMatch;

  const CareerDetailScreen({
    super.key,
    required this.matchId,
    this.initialMatch,
  });

  @override
  ConsumerState<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends ConsumerState<CareerDetailScreen> {
  CareerMatch? _match;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMatch != null) {
      _match = widget.initialMatch;
      _isLoading = false;
    } else {
      _loadMatch();
    }
  }

  Future<void> _loadMatch() async {
    try {
      final m = await ref
          .read(roadmapRepositoryProvider)
          .getMatch(widget.matchId);
      if (mounted) {
        setState(() {
          _match = m;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePath() async {
    if (_match == null || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      await ref
          .read(skillProgressRepositoryProvider)
          .initializeSkills(widget.matchId, _match!.requiredSkills);
      await ref.read(roadmapRepositoryProvider).saveMatch(widget.matchId);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        context.push('/skills/${widget.matchId}', extra: _match);
      }
    } catch (e, st) {
      // Log the error for debugging and show a helpful message with retry.
      // Errors here are often Supabase permission or network issues.
      // Print so it's visible in the logs when running locally.
      // ignore: avoid_print
      print('Failed to save path: $e\n$st');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save path: ${e.toString()}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _savePath();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _potentialLabel {
    final score = _match?.fitScore ?? 0;
    if (score >= 80) return 'HIGH POTENTIAL';
    if (score >= 65) return 'GOOD FIT';
    return 'WORTH EXPLORING';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: _isLoading
          ? const Center(child: CareerDetailSkeleton())
          : _match == null
          ? _ErrorBody(
              onBack: () => GoRouter.of(context).canPop()
                  ? context.pop()
                  : context.go('/home'),
            )
          : _DetailBody(
              match: _match!,
              potentialLabel: _potentialLabel,
              isSaving: _isSaving,
              onBack: () => GoRouter.of(context).canPop()
                  ? context.pop()
                  : context.go('/home'),
              onSave: _savePath,
              onJobs: () =>
                  context.go('/jobs/${Uri.encodeComponent(_match!.title)}'),
            ),
    );
  }
}

// ── Detail body ────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final CareerMatch match;
  final String potentialLabel;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onJobs;

  const _DetailBody({
    required this.match,
    required this.potentialLabel,
    required this.isSaving,
    required this.onBack,
    required this.onSave,
    required this.onJobs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Status bar spacer ──────────────────────────
                    const SizedBox(height: 56),

                    // ── Back button ────────────────────────────────
                    _SquareIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: onBack,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Title ──────────────────────────────────────
                    Text(
                      match.title.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.anchor,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Match % + potential label ──────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${match.fitScore ?? 0}% MATCH',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          potentialLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Fit score bar ──────────────────────────────
                    Container(
                      height: 14,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: const [AppShadows.hardSm],
                      ),
                      child: LinearProgressIndicator(
                        value: (match.fitScore ?? 0) / 100.0,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.sage,
                        ),
                        minHeight: 14,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── WHAT IT IS ─────────────────────────────────
                    _SectionHeader('WHAT IT IS'),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: const [AppShadows.hardSm],
                      ),
                      child: Text(
                        match.summary ?? 'No description available.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.ink,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── SKILLS YOU'LL NEED ─────────────────────────
                    _SectionHeader('SKILLS YOU\'LL NEED'),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: match.requiredSkills
                            .map(
                              (skill) => Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.sm,
                                ),
                                child: _SkillChip(skill: skill),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── YOUR ROADMAP ───────────────────────────────
                    _SectionHeader('YOUR ROADMAP'),
                    const SizedBox(height: AppSpacing.md),
                    ...match.roadmap.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _RoadmapStepCard(step: step),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── See real jobs link ─────────────────────────
                    GestureDetector(
                      onTap: onJobs,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'See real job listings for ${match.title}  →',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.anchor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.anchor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // ── Sticky SAVE THIS PATH button ───────────────────────────────
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
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.anchor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    side: const BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SAVE THIS PATH',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.bookmark_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error body ─────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final VoidCallback onBack;
  const _ErrorBody({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SquareIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
            const SizedBox(height: AppSpacing.xl),
            DrimErrorState(
              title: 'Couldn\'t load this career',
              body:
                  'We lost the details for this path. '
                  'Go back and try opening it again.',
              buttonLabel: 'GO BACK',
              onRetry: onBack,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: Divider(color: AppColors.line, thickness: 1.5)),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillTag skill;
  const _SkillChip({required this.skill});

  IconData get _icon {
    final name = skill.name.toLowerCase();
    if (name.contains('figma') || name.contains('design')) {
      return Icons.brush_rounded;
    }
    if (name.contains('research') || name.contains('user')) {
      return Icons.search_rounded;
    }
    if (name.contains('wire') || name.contains('layer')) {
      return Icons.layers_rounded;
    }
    if (name.contains('python') || name.contains('code')) {
      return Icons.code_rounded;
    }
    if (name.contains('data') || name.contains('stat')) {
      return Icons.bar_chart_rounded;
    }
    if (name.contains('agile') || name.contains('scrum')) {
      return Icons.loop_rounded;
    }
    if (name.contains('strategy')) return Icons.lightbulb_rounded;
    return Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.sage,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        boxShadow: const [AppShadows.hardSm],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: AppColors.ink),
          const SizedBox(width: 5),
          Text(
            skill.name.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStepCard extends StatefulWidget {
  final RoadmapStep step;
  const _RoadmapStepCard({required this.step});

  @override
  State<_RoadmapStepCard> createState() => _RoadmapStepCardState();
}

class _RoadmapStepCardState extends State<_RoadmapStepCard> {
  bool _expanded = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final hasResources = step.resources.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: const [AppShadows.hardSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step header row ──────────────────────────────────────────
          InkWell(
            onTap: hasResources
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number box
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(AppRadii.sm - 2),
                    ),
                    child: Center(
                      child: Text(
                        '${step.order}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.title.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (hasResources)
                              Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.muted,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.detail,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.muted,
                            height: 1.45,
                          ),
                        ),
                        if (hasResources && !_expanded) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                size: 13,
                                color: AppColors.anchor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${step.resources.length} ${step.resources.length == 1 ? 'resource' : 'resources'}  —  tap to view',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.anchor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Resources list (expanded) ─────────────────────────────────
          if (_expanded && hasResources) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.sand,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      4,
                    ),
                    child: Text(
                      'RESOURCES TO LEARN THIS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...step.resources.asMap().entries.map((entry) {
                    final i = entry.key;
                    final resource = entry.value;
                    return Column(
                      children: [
                        if (i > 0)
                          const Divider(
                            color: AppColors.line,
                            height: 1,
                            thickness: 1,
                            indent: AppSpacing.md,
                            endIndent: AppSpacing.md,
                          ),
                        InkWell(
                          onTap: resource.url.isNotEmpty
                              ? () => _openUrl(resource.url)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 2,
                            ),
                            child: Row(
                              children: [
                                // Platform icon
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _platformColor(resource.platform),
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.sm - 2,
                                    ),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    _platformIcon(resource.platform),
                                    size: 16,
                                    color: AppColors.ink,
                                  ),
                                ),

                                const SizedBox(width: AppSpacing.sm),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resource.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            resource.platform,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: resource.isFree
                                                  ? AppColors.sage.withOpacity(
                                                      0.25,
                                                    )
                                                  : AppColors.apricot
                                                        .withOpacity(0.25),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              resource.isFree ? 'FREE' : 'PAID',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: resource.isFree
                                                    ? AppColors.anchor
                                                    : AppColors.apricot,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 16,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _platformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return const Color(0xFFFF0000).withOpacity(0.12);
      case 'coursera':
        return const Color(0xFF0056D2).withOpacity(0.12);
      case 'kaggle':
        return const Color(0xFF20BEFF).withOpacity(0.12);
      case 'khan academy':
        return const Color(0xFF14BF96).withOpacity(0.12);
      case 'udemy':
        return const Color(0xFFA435F0).withOpacity(0.12);
      case 'freecodecamp':
        return const Color(0xFF0A0A23).withOpacity(0.08);
      case 'github':
        return AppColors.line;
      case 'book':
        return AppColors.apricot.withOpacity(0.2);
      default:
        return AppColors.sand;
    }
  }

  IconData _platformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_outline_rounded;
      case 'coursera':
      case 'edx':
      case 'udemy':
      case 'khan academy':
        return Icons.school_rounded;
      case 'kaggle':
        return Icons.bar_chart_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'website':
        return Icons.language_rounded;
      default:
        return Icons.link_rounded;
    }
  }
}

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
