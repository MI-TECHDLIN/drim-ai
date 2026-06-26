import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class GoalSetupScreen extends ConsumerStatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  ConsumerState<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends ConsumerState<GoalSetupScreen> {
  int? _selectedMonths;
  DateTime? _customDate;
  bool _isLoading = false;

  static const _options = [
    (3, '3', 'MONTHS'),
    (6, '6', 'MONTHS'),
    (12, '1', 'YEAR'),
    (0, '?', 'CUSTOM'),
  ];

  bool get _canSet =>
      (_selectedMonths != null && _selectedMonths != 0) ||
      (_selectedMonths == 0 && _customDate != null);

  Future<void> _setGoal() async {
    if (!_canSet || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final months = _selectedMonths == 0 ? 0 : _selectedMonths!;
      final targetDate = _selectedMonths == 0
          ? _customDate!
          : DateTime.now()
              .add(Duration(days: (_selectedMonths! * 30)));

      await ref.read(goalRepositoryProvider).setGoal(
            durationMonths: _selectedMonths == 0
                ? targetDate.difference(DateTime.now()).inDays ~/ 30
                : months,
            targetDate: targetDate,
          );

      ref.invalidate(activeGoalProvider);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not set goal.',
                style: GoogleFonts.inter()),
            backgroundColor: AppColors.error,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SET YOUR GOAL',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'How long do you have?',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.muted),
              ),

              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: ListView(
                  children: [
                    ..._options.map((opt) {
                      final months = opt.$1;
                      final numStr = opt.$2;
                      final unitStr = opt.$3;
                      final selected = _selectedMonths == months;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedMonths = months),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.anchor
                                  : AppColors.surface,
                              border: Border.all(
                                  color: AppColors.border, width: 2),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.lg),
                              boxShadow: selected
                                  ? const [AppShadows.hardLg]
                                  : const [AppShadows.hard],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.lg,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  numStr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.anchor,
                                    height: 1.0,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  unitStr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white.withOpacity(0.8)
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Custom date picker
                    if (_selectedMonths == 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now()
                                .add(const Duration(days: 90)),
                            firstDate: DateTime.now()
                                .add(const Duration(days: 7)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 730)),
                          );
                          if (picked != null) {
                            setState(() => _customDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                                color: AppColors.border, width: 2),
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  size: 18, color: AppColors.muted),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _customDate != null
                                    ? '${_customDate!.day}/${_customDate!.month}/${_customDate!.year}'
                                    : 'Select target date...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: _customDate != null
                                      ? AppColors.ink
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow:
                      _canSet ? const [AppShadows.hard] : [],
                ),
                child: ElevatedButton(
                  onPressed: (_canSet && !_isLoading) ? _setGoal : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.apricot,
                    foregroundColor: AppColors.ink,
                    disabledBackgroundColor:
                        AppColors.apricot.withOpacity(0.4),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: const BorderSide(
                          color: AppColors.border, width: 2),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink))
                      : Text(
                          'SET THIS GOAL  →',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}