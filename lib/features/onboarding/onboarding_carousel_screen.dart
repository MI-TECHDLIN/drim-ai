import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/drim_logo.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _animating = false;

  // Per-slide animation controllers
  late final List<AnimationController> _slideControllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _totalPages = 3;

  @override
  void initState() {
    super.initState();

    _slideControllers = List.generate(
      _totalPages,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _fadeAnims = _slideControllers
        .map(
          (c) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _slideAnims = _slideControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    // Animate first slide in
    _slideControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _slideControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (_animating) return;
    _animating = true;

    _slideControllers[page].reset();
    _pageController
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _slideControllers[page].forward();
          _animating = false;
        });

    setState(() => _currentPage = page);
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _finish();
    }
  }

  void _finish() => context.go('/auth');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DrimLogo(),
                  // Skip button
                  GestureDetector(
                    onTap: _finish,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        boxShadow: const [AppShadows.hardSm],
                      ),
                      child: Text(
                        'SKIP',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page view ────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Slide1(fadeAnim: _fadeAnims[0], slideAnim: _slideAnims[0]),
                  _Slide2(fadeAnim: _fadeAnims[1], slideAnim: _slideAnims[1]),
                  _Slide3(fadeAnim: _fadeAnims[2], slideAnim: _slideAnims[2]),
                ],
              ),
            ),

            // ── Bottom controls ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (i) => GestureDetector(
                        onTap: () => _goToPage(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? AppColors.anchor
                                : AppColors.line,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: _currentPage == i
                                  ? AppColors.border
                                  : AppColors.border.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Next / Get Started button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: const [AppShadows.hard],
                    ),
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == _totalPages - 1
                            ? AppColors.apricot
                            : AppColors.anchor,
                        foregroundColor: _currentPage == _totalPages - 1
                            ? AppColors.ink
                            : Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _currentPage == _totalPages - 1
                              ? 'GET STARTED  →'
                              : 'NEXT  →',
                          key: ValueKey(_currentPage),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide wrapper (fade + slide in) ───────────────────────────────────────

class _SlideWrapper extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Widget child;

  const _SlideWrapper({
    required this.fadeAnim,
    required this.slideAnim,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SLIDE 1 — The Problem
// ══════════════════════════════════════════════════════════════════════════

class _Slide1 extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _Slide1({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    return _SlideWrapper(
      fadeAnim: fadeAnim,
      slideAnim: slideAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Big stat card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.anchor,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(AppRadii.xl),
                boxShadow: const [AppShadows.hardLg],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "1%" in massive type
                  Text(
                    '1%',
                    style: GoogleFonts.poppins(
                      fontSize: 96,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'of students reach their\nintended career path.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Decorative divider
                  Container(width: 48, height: 3, color: AppColors.apricot),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── "Built for the 99%" ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: const [AppShadows.hard],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.apricot,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      'DRIM AI IS BUILT FOR',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'The other 99%.',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'The ones who are unsure, underserved, or\njust figuring it out. That\'s most of us.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SLIDE 2 — The Journey
// ══════════════════════════════════════════════════════════════════════════

class _Slide2 extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _Slide2({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    return _SlideWrapper(
      fadeAnim: fadeAnim,
      slideAnim: slideAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Heading ────────────────────────────────────────────────
            Text(
              'HOW IT\nWORKS.',
              style: GoogleFonts.poppins(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: AppColors.anchor,
                height: 1.05,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'A research-backed sequence that actually works.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Step 1: Self-Awareness ─────────────────────────────────
            _JourneyStep(
              number: '01',
              title: 'Self-Awareness',
              body:
                  'Discover your interests, values, and strengths — before anyone tells you what to be.',
              color: AppColors.sage,
              icon: Icons.person_search_rounded,
              isFirst: true,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Connector
            const _StepConnector(),

            const SizedBox(height: AppSpacing.sm),

            // ── Step 2: Exploration ────────────────────────────────────
            _JourneyStep(
              number: '02',
              title: 'Exploration',
              body:
                  'AI matches you to real career paths based on who you actually are.',
              color: AppColors.anchor,
              icon: Icons.explore_rounded,
              lightText: true,
            ),

            const SizedBox(height: AppSpacing.sm),

            const _StepConnector(),

            const SizedBox(height: AppSpacing.sm),

            // ── Step 3: Confidence ─────────────────────────────────────
            _JourneyStep(
              number: '03',
              title: 'Confidence',
              body:
                  'Track your growth and see your confidence score rise — measured, not just felt.',
              color: AppColors.apricot,
              icon: Icons.trending_up_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final Color color;
  final IconData icon;
  final bool lightText;
  final bool isFirst;

  const _JourneyStep({
    required this.number,
    required this.title,
    required this.body,
    required this.color,
    required this.icon,
    this.lightText = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = lightText ? Colors.white : AppColors.ink;
    final mutedColor = lightText
        ? Colors.white.withOpacity(0.75)
        : AppColors.muted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(icon, size: 18, color: textColor.withOpacity(0.7)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xl),
      child: Row(
        children: [Container(width: 2, height: 16, color: AppColors.border)],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SLIDE 3 — The Promise
// ══════════════════════════════════════════════════════════════════════════

class _Slide3 extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _Slide3({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    return _SlideWrapper(
      fadeAnim: fadeAnim,
      slideAnim: slideAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Three bold promises ────────────────────────────────────
            _PromiseCard(
              value: '8',
              unit: 'QUESTIONS',
              body: 'Honest ones. No trick questions, no SAT vibes.',
              color: AppColors.surface,
              valueFontSize: 80,
            ),

            const SizedBox(height: AppSpacing.sm),

            _PromiseCard(
              value: '5',
              unit: 'MINUTES',
              body:
                  'That\'s all it takes to get a personalised career roadmap.',
              color: AppColors.sage,
              valueFontSize: 80,
            ),

            const SizedBox(height: AppSpacing.sm),

            _PromiseCard(
              value: '∞',
              unit: 'DIRECTION',
              body: 'A lifetime of clarity — starting right now.',
              color: AppColors.anchor,
              valueFontSize: 72,
              lightText: true,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Final reassurance ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.sand,
                border: Border.all(
                  color: AppColors.border.withOpacity(0.35),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  Text(
                    '♦',
                    style: TextStyle(fontSize: 16, color: AppColors.apricot),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'No right answers. Just what feels true to you.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromiseCard extends StatelessWidget {
  final String value;
  final String unit;
  final String body;
  final Color color;
  final double valueFontSize;
  final bool lightText;

  const _PromiseCard({
    required this.value,
    required this.unit,
    required this.body,
    required this.color,
    required this.valueFontSize,
    this.lightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = lightText ? Colors.white : AppColors.ink;
    final mutedColor = lightText
        ? Colors.white.withOpacity(0.75)
        : AppColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Big number
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.0,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Vertical divider
          Container(
            width: 2,
            height: 56,
            color: (lightText ? Colors.white : AppColors.border).withOpacity(
              0.3,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
