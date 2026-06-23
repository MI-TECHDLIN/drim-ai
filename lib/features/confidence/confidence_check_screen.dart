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
import 'widgets/confidence_meter.dart';

class ConfidenceCheckScreen extends ConsumerStatefulWidget {
  final String phase;

  const ConfidenceCheckScreen({super.key, required this.phase});

  @override
  ConsumerState<ConfidenceCheckScreen> createState() =>
      _ConfidenceCheckScreenState();
}

class _ConfidenceCheckScreenState extends ConsumerState<ConfidenceCheckScreen> {
  // Post-check starts at 7 to feel more confident by default
  late int _value;
  bool _isLoading = false;

  bool get _isPre => widget.phase == 'pre';

  @override
  void initState() {
    super.initState();
    _value = _isPre ? 5 : 7;
  }

  String get _headline =>
      _isPre ? 'HOW SURE\nARE YOU?' : 'HOW DO YOU\nFEEL NOW?';

  String get _subtext => _isPre
      ? 'About your future right now. Be honest —\nthere\'s no wrong answer.'
      : 'After everything you\'ve explored today.';

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .saveConfidenceScore(phase: widget.phase, score: _value);
    } catch (_) {
      // Non-blocking — continue even if save fails
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // Pre → quiz | Post → delta result screen
        context.go(_isPre ? '/quiz' : '/confidence-delta');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

              const SizedBox(height: AppSpacing.xxl),

              // ── Headline ──────────────────────────────────────────────
              Text(
                _headline,
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                _subtext,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Confidence meter (signature element) ──────────────────
              ConfidenceMeter(
                value: _value,
                isPost: !_isPre,
                onChanged: (v) => setState(() => _value = v),
              ),

              const Spacer(),

              // ── CTA ───────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: const [AppShadows.hard],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.anchor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: const BorderSide(color: AppColors.border, width: 2),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'THIS FEELS RIGHT  →',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
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
