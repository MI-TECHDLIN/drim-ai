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

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen>
    with SingleTickerProviderStateMixin {
  List<CareerMatch>? _matches;
  bool _isLoading = true;
  int _messageIndex = 0;

  static const _messages = [
    'Matching your answers to real career paths...',
    'Finding your best matches...',
    'Building your personalised roadmap...',
    'Almost there...',
  ];

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();
    _cycleMessages();
    _load();
  }

  void _cycleMessages() {
    for (int i = 1; i < _messages.length; i++) {
      Future.delayed(Duration(seconds: i * 2 + 1), () {
        if (mounted && _isLoading) setState(() => _messageIndex = i);
      });
    }
  }

  Future<void> _load() async {
    try {
      final matches = await ref.read(roadmapRepositoryProvider).getOrGenerate();
      if (mounted) {
        setState(() {
          _matches = matches;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _isLoading ? AppColors.anchor : AppColors.sand,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isLoading
              ? _LoadingBody(
                  key: const ValueKey('loading'),
                  progressController: _progressController,
                  message: _messages[_messageIndex],
                )
              : _ResultsBody(
                  key: const ValueKey('results'),
                  matches: _matches ?? [],
                  onSave: () => context.go('/home'),
                ),
        ),
      ),
    );
  }
}

// ── Loading body ───────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  final AnimationController progressController;
  final String message;

  const _LoadingBody({
    super.key,
    required this.progressController,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // ── Decorative: small gray square top-left ───────────────────
          Positioned(
            top: 100,
            left: 20,
            child: _DecoSquare(
              size: 40,
              color: Colors.white.withOpacity(0.1),
              borderColor: Colors.white.withOpacity(0.3),
            ),
          ),

          // ── Decorative: larger sage square top-right ─────────────────
          Positioned(
            top: 80,
            right: 20,
            child: _DecoSquare(
              size: 62,
              color: AppColors.sage.withOpacity(0.35),
              borderColor: Colors.white.withOpacity(0.4),
            ),
          ),

          // ── Decorative: small gray square bottom-left ────────────────
          Positioned(
            bottom: 130,
            left: 20,
            child: _DecoSquare(
              size: 44,
              color: Colors.white.withOpacity(0.08),
              borderColor: Colors.white.withOpacity(0.2),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CPU icon card (white square, hard shadow, no border radius)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [AppShadows.hardLg],
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      size: 46,
                      color: AppColors.ink,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Heading
                  Text(
                    'BUILDING YOUR\nROADMAP',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Animated progress bar
                  AnimatedBuilder(
                    animation: progressController,
                    builder: (context, _) => Container(
                      height: 16,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: const [AppShadows.hardSm],
                      ),
                      child: LinearProgressIndicator(
                        value: progressController.value * 0.82,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.sage,
                        ),
                        minHeight: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Rotating caption
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      message,
                      key: ValueKey(message),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Apricot pill tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.apricot,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [AppShadows.hardSm],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 16,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),
                        Text(
                          'This usually takes a few seconds',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Decorative square ──────────────────────────────────────────────────────

class _DecoSquare extends StatelessWidget {
  final double size;
  final Color color;
  final Color borderColor;

  const _DecoSquare({
    required this.size,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [AppShadows.hard],
      ),
    );
  }
}

// ── Results body ───────────────────────────────────────────────────────────

class _ResultsBody extends StatelessWidget {
  final List<CareerMatch> matches;
  final VoidCallback onSave;

  const _ResultsBody({super.key, required this.matches, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      // Heading
                      Text(
                        'YOUR PATHS',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.anchor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Based on who you actually are.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Career cards
                      ...matches.map(
                        (match) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _CareerCard(match: match),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Sticky "SAVE MY ROADMAP" button ──────────────────────────
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
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.apricot,
                  foregroundColor: AppColors.ink,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    side: const BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
                child: Text(
                  'SAVE MY ROADMAP',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Career card ────────────────────────────────────────────────────────────

class _CareerCard extends StatelessWidget {
  final CareerMatch match;

  const _CareerCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [AppShadows.hardLg],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + fit score badge ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  match.title.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (match.fitScore != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    border: Border.all(color: AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    '${match.fitScore}%',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Match reason ────────────────────────────────────────────
          if (match.matchReason != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              match.matchReason!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Skill chips + EXPLORE button ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chips
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: match.requiredSkills
                      .take(3)
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadii.sm - 2,
                            ),
                          ),
                          child: Text(
                            skill.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // EXPLORE button — flat (no shadow, contrasts with card shadow)

              // Inside _CareerCard build(), update the EXPLORE ElevatedButton:
              ElevatedButton(
                onPressed: () =>
                    context.go('/career/${match.id}', extra: match),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.anchor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    side: const BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
                child: Text(
                  'EXPLORE  →',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
