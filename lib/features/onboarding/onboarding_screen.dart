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

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  String? _ageBand;
  String? _educationStage;
  bool _isLoading = false;

  static const _ageBands = ['13-15', '16-18', '19-22', '22+'];
  static const _stages = [
    ('high_school', 'High School'),
    ('undergrad', 'University'),
    ('other', 'Other'),
  ];

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      _ageBand != null &&
      _educationStage != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_canContinue) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            displayName: _nameController.text.trim(),
            ageBand: _ageBand!,
            educationStage: _educationStage!,
          );
      ref.invalidate(myProfileProvider);
      if (mounted) context.go('/confidence-pre');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // Show real error in debug, generic in release
              'Error: ${e.toString()}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: SingleChildScrollView(
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

              // ── Heading ───────────────────────────────────────────────
              Text(
                "LET'S GET TO\nKNOW YOU",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This helps us personalise your journey.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Name ──────────────────────────────────────────────────
              _SectionLabel("What's your name?"),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Age band ──────────────────────────────────────────────
              _SectionLabel('How old are you?'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(_ageBands.length, (i) {
                  final band = _ageBands[i];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < _ageBands.length - 1 ? AppSpacing.sm : 0,
                      ),
                      child: _SelectChip(
                        label: band,
                        selected: _ageBand == band,
                        onTap: () => setState(() => _ageBand = band),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Education stage ───────────────────────────────────────
              _SectionLabel('Where are you right now?'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _stages.map((s) {
                  return _SelectChip(
                    label: s.$2,
                    selected: _educationStage == s.$1,
                    onTap: () => setState(() => _educationStage = s.$1),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Continue button ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: (_canContinue && !_isLoading)
                      ? const [AppShadows.hard]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: (_canContinue && !_isLoading) ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.anchor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.anchor.withOpacity(0.5),
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
                          'CONTINUE  →',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }
}

// ── Selection chip ─────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md - 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.anchor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm + 2),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
