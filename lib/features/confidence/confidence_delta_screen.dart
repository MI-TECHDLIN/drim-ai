import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class ConfidenceDeltaScreen extends ConsumerStatefulWidget {
  const ConfidenceDeltaScreen({super.key});

  @override
  ConsumerState<ConfidenceDeltaScreen> createState() =>
      _ConfidenceDeltaScreenState();
}

class _ConfidenceDeltaScreenState extends ConsumerState<ConfidenceDeltaScreen> {
  int? _preScore;
  int? _postScore;
  bool _isLoading = true;

  // Sequential animation flags
  bool _showHeadline = false;
  bool _showNumbers = false;
  bool _showDescription = false;
  bool _showCard = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final scores = await ref
          .read(profileRepositoryProvider)
          .getConfidenceScores();
      if (mounted) {
        setState(() {
          _preScore = scores['pre'];
          _postScore = scores['post'];
          _isLoading = false;
        });
        _startAnimation();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _preScore = 4;
          _postScore = 8;
          _isLoading = false;
        });
        _startAnimation();
      }
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _showHeadline = true);
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showNumbers = true);
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _showDescription = true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showCard = true);
    });
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _showButton = true);
    });
  }

  String get _messageText {
    final delta = (_postScore ?? 8) - (_preScore ?? 4);
    if (delta >= 4) {
      return 'You showed up, explored, and grew. That\'s what progress looks like. Keep going — this is just the beginning.';
    }
    if (delta >= 2) {
      return 'Every point of confidence you gained today was earned. You\'re on the right path — keep going.';
    }
    if (delta == 1) {
      return 'Even one point of growth shows real courage. You showed up — and that already matters.';
    }
    return 'Clarity takes time. You showed up today, and that already matters more than you know.';
  }

  String get _headlineText {
    final delta = (_postScore ?? 8) - (_preScore ?? 4);
    return delta > 0 ? 'YOU\nGREW.' : 'YOU\nSHOWED UP.';
  }

  @override
  Widget build(BuildContext context) {
    final pre = _preScore ?? 4;
    final post = _postScore ?? 8;
    final delta = post - pre;

    return Scaffold(
      backgroundColor: AppColors.anchor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── DRIM AI wordmark (light) ───────────────────────
                    Row(
                      children: [
                        Text(
                          'DRIM ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.apricot,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'AI',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── YOU GREW ───────────────────────────────────────
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showHeadline ? 1.0 : 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _headlineText,
                            style: GoogleFonts.poppins(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: 48,
                            height: 2,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl + AppSpacing.md),

                    // ── Numbers ────────────────────────────────────────
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showNumbers ? 1.0 : 0.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Pre score (muted)
                          Text(
                            '$pre',
                            style: GoogleFonts.poppins(
                              fontSize: 80,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.35),
                              height: 1.0,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.apricot,
                              size: 40,
                            ),
                          ),

                          // Post score (sage green)
                          Text(
                            '$post',
                            style: GoogleFonts.poppins(
                              fontSize: 80,
                              fontWeight: FontWeight.w800,
                              color: AppColors.sage,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Description ────────────────────────────────────
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showDescription ? 1.0 : 0.0,
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'Your confidence jumped '),
                              TextSpan(
                                text:
                                    '$delta ${delta == 1 ? 'point' : 'points'}.',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Sage message card ──────────────────────────────
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showCard ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 500),
                        offset: _showCard ? Offset.zero : const Offset(0, 0.15),
                        curve: Curves.easeOut,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            boxShadow: const [AppShadows.hard],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '♦',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.ink.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _messageText,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.ink,
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── GO TO DASHBOARD ────────────────────────────────
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showButton ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          boxShadow: const [AppShadows.hard],
                        ),
                        child: ElevatedButton(
                          onPressed: _showButton
                              ? () {
                                  ref.invalidate(dashboardProvider);
                                  context.go('/home');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.apricot,
                            foregroundColor: AppColors.ink,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              side: const BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'GO TO YOUR DASHBOARD  →',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
    );
  }
}
