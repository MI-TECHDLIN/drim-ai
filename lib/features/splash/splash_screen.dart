import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_config.dart';
import '../../core/supabase_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/drim_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    if (!AppConfig.isConfigured) {
      context.go('/auth');
      return;
    }
    try {
      final session = supabase.auth.currentSession;
      context.go(session != null ? '/home' : '/auth');
    } catch (_) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Stack(
        children: [
          // ── Decorative: sage circle top-left ──────────────────────────
          Positioned(
            top: 64,
            left: 24,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sage.withOpacity(0.25),
                border: Border.all(color: AppColors.border, width: 2),
              ),
            ),
          ),

          // ── Decorative: apricot square bottom-right ───────────────────
          Positioned(
            bottom: 130,
            right: 28,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.apricot.withOpacity(0.55),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [AppShadows.hard],
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md + 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: const [AppShadows.hard],
                    ),
                    child: const DrimLogo(scale: 2.0),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Tagline card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      boxShadow: const [AppShadows.hardSm],
                    ),
                    child: Text(
                      'Find your way forward —\none calm step at a time.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom: pill bar + dots + copyright ───────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                bottom: AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated sage progress bar
                  Container(
                    height: 10,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 2200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.sage,
                          ),
                          minHeight: 10,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(active: false),
                      const SizedBox(width: 6),
                      _Dot(active: true),
                      const SizedBox(width: 6),
                      _Dot(active: false),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    '© 2026 DRIM INTELLIGENCE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                      letterSpacing: 0.8,
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

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.anchor : AppColors.muted.withOpacity(0.35),
      ),
    );
  }
}
