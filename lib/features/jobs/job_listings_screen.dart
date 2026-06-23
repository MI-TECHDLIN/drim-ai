import 'package:drim_ai/widgets/drim_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/job_listing.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class JobListingsScreen extends ConsumerWidget {
  final String careerTitle;

  const JobListingsScreen({super.key, required this.careerTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(jobListingsProvider(careerTitle));

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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Header row ─────────────────────────────
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
                              icon: Icons.search_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          'REAL OPPORTUNITIES',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.anchor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Live listings for $careerTitle',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Content ────────────────────────────────
                        // Inside JobListingsScreen.build(), replace the listingsAsync.when block:
                        listingsAsync.when(
                          data: (rawListings) {
                            final listings = rawListings.cast<JobListing>();
                            if (listings.isEmpty) {
                              return DrimEmptyState(
                                icon: Icons.work_off_rounded,
                                title: 'No listings found',
                                body:
                                    'We couldn\'t find live roles for ${careerTitle} right now. '
                                    'Try searching on LinkedIn or Glassdoor directly.',
                                buttonLabel: 'BACK TO YOUR PATH',
                                onAction: () => context.pop(),
                              );
                            }
                            return _ListingsContent(
                              listings: listings,
                              careerTitle: careerTitle,
                            );
                          },
                          loading: () => Column(
                            children: [
                              DrimLoadingCard(
                                height: 100,
                                message: 'Finding live opportunities...',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              DrimLoadingCard(height: 100),
                              const SizedBox(height: AppSpacing.md),
                              DrimLoadingCard(height: 100),
                            ],
                          ),
                          error: (_, __) => DrimErrorState(
                            title: 'Couldn\'t load job listings',
                            body:
                                'The listings service is unavailable. '
                                'Here are some example roles to give you an idea of what\'s out there.',
                            buttonLabel: 'SEE EXAMPLE ROLES',
                            onRetry: () => ref.invalidate(
                              jobListingsProvider(careerTitle),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom nav ─────────────────────────────────────────────────
          _BottomNav(activeIndex: 2, careerTitle: careerTitle),
        ],
      ),
    );
  }
}

// ── Listings content ───────────────────────────────────────────────────────

class _ListingsContent extends StatelessWidget {
  final List<JobListing> listings;
  final String careerTitle;

  const _ListingsContent({required this.listings, required this.careerTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning banner (always shown — Adzuna fallback for most geographies)
        _FallbackBanner(
          message: 'No listings found nearby. Showing global roles.',
        ),

        const SizedBox(height: AppSpacing.lg),

        ...listings.map(
          (job) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _JobCard(job: job),
          ),
        ),
      ],
    );
  }
}

// ── Job card ───────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final JobListing job;

  const _JobCard({required this.job});

  IconData get _icon {
    final title = job.title.toLowerCase();
    if (title.contains('design') || title.contains('ux')) {
      return Icons.design_services_rounded;
    }
    if (title.contains('data') || title.contains('analyst')) {
      return Icons.bar_chart_rounded;
    }
    if (title.contains('research')) return Icons.search_rounded;
    if (title.contains('product') || title.contains('manager')) {
      return Icons.inventory_2_rounded;
    }
    if (title.contains('engineer') || title.contains('dev')) {
      return Icons.code_rounded;
    }
    return Icons.work_rounded;
  }

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link.', style: GoogleFonts.inter()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: const [AppShadows.hard],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.company.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(_icon, size: 20, color: AppColors.muted),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Location + salary chips
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (job.location != null)
                _InfoChip(
                  icon: Icons.location_on_rounded,
                  label: job.location!,
                  color: AppColors.surface,
                ),
              if (job.salary != null)
                _InfoChip(
                  icon: null,
                  label: job.salary!,
                  color: AppColors.sage.withOpacity(0.5),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.line, thickness: 1),
          const SizedBox(height: AppSpacing.sm),

          // Posted time + VIEW JOB
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POSTED ${job.timeAgo.toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                  letterSpacing: 0.4,
                ),
              ),
              ElevatedButton(
                onPressed: () => _openUrl(context, job.url),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.anchor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    side: const BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
                child: Text(
                  'VIEW JOB  →',
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

// ── Fallback banner ────────────────────────────────────────────────────────

class _FallbackBanner extends StatelessWidget {
  final String message;
  const _FallbackBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md - 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.apricot.withOpacity(0.85),
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, size: 18, color: AppColors.ink),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;

  const _InfoChip({this.icon, required this.label, required this.color});

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.ink),
            const SizedBox(width: 3),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading state ──────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.anchor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ── Bottom nav ─────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final String careerTitle;

  const _BottomNav({required this.activeIndex, required this.careerTitle});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'HOME'),
      (Icons.bar_chart_rounded, 'TRACKER'),
      (Icons.work_rounded, 'JOBS'),
      (Icons.search_rounded, 'SEARCH'),
      (Icons.person_rounded, 'PROFILE'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i == 0) context.go('/home');
                    if (i == 2) {
                      // Already on jobs
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 48 : 32,
                        height: isActive ? 36 : 32,
                        decoration: isActive
                            ? BoxDecoration(
                                color: AppColors.apricot,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              )
                            : null,
                        child: Icon(
                          items[i].$1,
                          size: 22,
                          color: isActive ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$2,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive ? AppColors.ink : AppColors.muted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Square icon button ─────────────────────────────────────────────────────

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
