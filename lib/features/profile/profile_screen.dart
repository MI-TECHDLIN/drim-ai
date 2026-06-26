import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/profile.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/skeletons/skeleton_box.dart';
import '../../widgets/skeletons/skeleton_pill.dart';
import '../../widgets/drim_states.dart';
import '../../widgets/drim_bottom_nav.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go('/auth');
    } catch (_) {
      if (mounted) {
        showDrimError(context, 'Could not sign out. Please try again.');
        setState(() => _isSigningOut = false);
      }
    }
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _ageBandLabel(String? band) {
    switch (band) {
      case '13-15':
        return '13–15 years old';
      case '16-18':
        return '16–18 years old';
      case '19-22':
        return '19–22 years old';
      case '22+':
        return '22+ years old';
      default:
        return 'Age not set';
    }
  }

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'high_school':
        return 'High School';
      case 'undergrad':
        return 'University';
      case 'other':
        return 'Other';
      default:
        return 'Not set';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Column(
        children: [
          Expanded(
            child: profileAsync.when(
              data: (profile) => _ProfileBody(
                profile: profile,
                dashboardAsync: dashboardAsync,
                initials: _initials(profile?.displayName),
                ageBandLabel: _ageBandLabel(profile?.ageBand),
                stageLabel: _stageLabel(profile?.educationStage),
                isSigningOut: _isSigningOut,
                onSignOut: _signOut,
                onEditProfile: () => context.go('/onboarding'),
              ),
              loading: () => const _ProfileSkeleton(),
              error: (_, __) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: DrimErrorState(
                    title: 'Couldn\'t load your profile',
                    body: 'Tap retry to try again.',
                    onRetry: () => ref.invalidate(myProfileProvider),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom nav ─────────────────────────────────────────────
          const DrimBottomNav(currentRoute: '/profile'),
        ],
      ),
    );
  }
}

// ── Profile body ───────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final Profile? profile;
  final AsyncValue dashboardAsync;
  final String initials;
  final String ageBandLabel;
  final String stageLabel;
  final bool isSigningOut;
  final VoidCallback onSignOut;
  final VoidCallback onEditProfile;

  const _ProfileBody({
    required this.profile,
    required this.dashboardAsync,
    required this.initials,
    required this.ageBandLabel,
    required this.stageLabel,
    required this.isSigningOut,
    required this.onSignOut,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Status bar spacer ──────────────────────────────────
              const SizedBox(height: 64),

              // ── Avatar ────────────────────────────────────────────
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.anchor,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: const [AppShadows.hardLg],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Name ──────────────────────────────────────────────
              Center(
                child: Text(
                  profile?.displayName?.toUpperCase() ?? 'YOUR PROFILE',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.anchor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Education stage badge ──────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: const [AppShadows.hardSm],
                  ),
                  child: Text(
                    stageLabel.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Stats row ──────────────────────────────────────────
              dashboardAsync.when(
                data: (data) {
                  final d = data as dynamic;
                  final preScore = d.preScore as int?;
                  final postScore = d.postScore as int?;
                  final doneCount = d.doneCount as int;
                  final hasSaved = d.savedMatch != null;

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'CONFIDENCE',
                          value: postScore != null
                              ? '$postScore / 10'
                              : preScore != null
                              ? '$preScore / 10'
                              : '—',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.sage,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _StatCard(
                          label: 'SKILLS DONE',
                          value: '$doneCount',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.apricot,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _StatCard(
                          label: 'PATH SAVED',
                          value: hasSaved ? 'YES' : 'NO',
                          icon: hasSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: hasSaved ? AppColors.anchor : AppColors.line,
                          lightText: hasSaved,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i < 2 ? AppSpacing.sm : 0,
                        ),
                        child: SkeletonBox(height: 80),
                      ),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── YOUR DETAILS ───────────────────────────────────────
              _SectionHeader('YOUR DETAILS'),
              const SizedBox(height: AppSpacing.md),

              _DetailCard(
                children: [
                  _DetailRow(
                    label: 'AGE BAND',
                    value: ageBandLabel,
                    icon: Icons.cake_outlined,
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'EDUCATION',
                    value: stageLabel,
                    icon: Icons.school_outlined,
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'EMAIL',
                    value: '••••••••@••••.com',
                    icon: Icons.mail_outline_rounded,
                    muted: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Edit profile link
              GestureDetector(
                onTap: onEditProfile,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Edit profile  →',
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
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── ACCOUNT ────────────────────────────────────────────
              _SectionHeader('ACCOUNT'),
              const SizedBox(height: AppSpacing.md),

              _DetailCard(
                children: [
                  _DetailRow(
                    label: 'VERSION',
                    value: 'Drim AI v1.0.0',
                    icon: Icons.info_outline_rounded,
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'TRACK',
                    value: 'Track 04 — Career Planning',
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Sign out button ────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: const [AppShadows.hard],
                ),
                child: ElevatedButton(
                  onPressed: isSigningOut ? null : onSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.error,
                    disabledBackgroundColor: AppColors.surface.withOpacity(0.6),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: BorderSide(
                        color: isSigningOut
                            ? AppColors.border.withOpacity(0.3)
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                  ),
                  child: isSigningOut
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'SIGN OUT',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Bottom attribution ─────────────────────────────────
              Center(
                child: Text(
                  '© 2026 DRIM INTELLIGENCE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted.withOpacity(0.5),
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool lightText;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.lightText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: const [AppShadows.hard],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: lightText ? Colors.white : AppColors.ink),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: lightText ? Colors.white : AppColors.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: (lightText ? Colors.white : AppColors.muted).withOpacity(
                0.8,
              ),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

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
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: Divider(color: AppColors.line, thickness: 1.5)),
      ],
    );
  }
}

// ── Detail card ────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      child: Column(children: children),
    );
  }
}

// ── Detail row ─────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool muted;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: muted ? AppColors.muted : AppColors.ink,
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

// ── Detail divider ─────────────────────────────────────────────────────────

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.line,
      thickness: 1,
      height: 1,
      indent: AppSpacing.lg + 18,
    );
  }
}

// ── Profile skeleton ───────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: 64),

            // Avatar
            const Center(
              child: SkeletonBox(
                width: 96,
                height: 96,
                borderRadius: AppRadii.lg,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Name
            const Center(child: SkeletonBox(width: 180, height: 28)),
            const SizedBox(height: 8),
            const Center(child: SkeletonPill(width: 100, height: 26)),

            const SizedBox(height: AppSpacing.xl),

            // Stats row
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
                    child: SkeletonBox(height: 80, borderRadius: AppRadii.md),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Details section
            SkeletonBox(height: 120, borderRadius: AppRadii.lg),

            const SizedBox(height: AppSpacing.xl),

            // Account section
            SkeletonBox(height: 80, borderRadius: AppRadii.lg),

            const SizedBox(height: AppSpacing.xl),

            // Sign out button
            SkeletonBox(height: 52, borderRadius: AppRadii.md),
          ],
        ),
      ),
    );
  }
}
