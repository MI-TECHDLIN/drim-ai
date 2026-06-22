import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/drim_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final quizAsync = ref.watch(quizResponseProvider);

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──────────────────────────────────────────────────
              const DrimLogo(),

              const SizedBox(height: AppSpacing.xl),

              // ── Greeting ──────────────────────────────────────────────
              profileAsync.when(
                data: (profile) => Text(
                  profile?.displayName != null
                      ? 'HEY, ${profile!.displayName!.toUpperCase()} 👋'
                      : 'HEY THERE 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.anchor,
                    height: 1.1,
                  ),
                ),
                loading: () => const SizedBox(height: 36),
                error: (_, _) => const SizedBox(height: 36),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Quiz card ─────────────────────────────────────────────
              quizAsync.when(
                data: (quiz) => quiz == null
                    ? _StartQuizCard(onTap: () => context.go('/quiz'))
                    : const _QuizCompleteCard(),
                loading: () => const _LoadingCard(),
                error: (_, _) =>
                    _StartQuizCard(onTap: () => context.go('/quiz')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Start quiz card ────────────────────────────────────────────────────────

class _StartQuizCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StartQuizCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border, width: 2),
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
              onPressed: onTap,
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
    );
  }
}

// ── Quiz complete card ─────────────────────────────────────────────────────

class _QuizCompleteCard extends StatelessWidget {
  const _QuizCompleteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border, width: 2),
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
              color: AppColors.sage.withOpacity(0.2),
              border: Border.all(color: AppColors.sage, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              'QUIZ COMPLETE ✓',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.sage,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your paths\nare ready',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'See the career matches AI built\njust for you.',
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
              onPressed: () => context.go('/roadmap'),
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
                'VIEW MY ROADMAP  →',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading card ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.anchor,
          ),
        ),
      ),
    );
  }
}
