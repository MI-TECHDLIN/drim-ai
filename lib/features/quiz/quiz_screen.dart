import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drim_ai/data/quiz_questions.dart';
import 'package:drim_ai/models/quiz.dart';
import 'package:drim_ai/state/providers.dart';
import 'package:drim_ai/theme/app_colors.dart';
import 'package:drim_ai/theme/app_radii.dart';
import 'package:drim_ai/theme/app_shadows.dart';
import 'package:drim_ai/theme/app_spacing.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = false;
  bool _slideForward = true;

  QuizQuestion get _question => kQuizQuestions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == kQuizQuestions.length - 1;

  bool get _hasAnswer {
    final a = _answers[_question.id];
    if (a == null) return false;
    if (a is List) return (a as List).isNotEmpty;
    if (a is String) return a.isNotEmpty;
    return false;
  }

  void _selectOption(String option) {
    setState(() {
      final id = _question.id;
      if (_question.type == QuestionType.singleSelect) {
        _answers[id] = option;
      } else {
        final current = List<String>.from(
          (_answers[id] as List<String>?) ?? [],
        );
        if (current.contains(option)) {
          current.remove(option);
        } else {
          final max = _question.maxSelections ?? 999;
          if (current.length < max) current.add(option);
        }
        _answers[id] = current;
      }
    });
  }

  bool _isSelected(String option) {
    final a = _answers[_question.id];
    if (a is String) return a == option;
    if (a is List) return (a as List<String>).contains(option);
    return false;
  }

  void _goNext() {
    if (_isLastQuestion) {
      _handleFinalAction();
      return;
    }
    setState(() {
      _slideForward = true;
      _currentIndex++;
    });
  }

  void _handleFinalAction() {
    final selection = _answers['q8'] as String?;
    if (selection == 'I want to review my answers') {
      // Reset to start
      setState(() {
        _slideForward = false;
        _currentIndex = 0;
        _answers.remove('q8');
      });
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(quizRepositoryProvider).saveResponses(_answers);
      ref.invalidate(quizResponseProvider);
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save your answers. Please try again.',
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
    final progress = (_currentIndex + 1) / kQuizQuestions.length;

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Column(
        children: [
          // ── Full-width teal progress bar (edge to edge, above safe area) ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, val, _) => LinearProgressIndicator(
              value: val,
              backgroundColor: AppColors.line,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.anchor),
              minHeight: 7,
            ),
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),

                    // ── Question counter ────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Question ${_currentIndex + 1} of ${kQuizQuestions.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Animated question + options ─────────────────────
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, animation) {
                          final begin = _slideForward
                              ? const Offset(1.0, 0.0)
                              : const Offset(-1.0, 0.0);
                          return SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: begin,
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _QuestionView(
                          key: ValueKey(_currentIndex),
                          question: _question,
                          isSelected: _isSelected,
                          onSelect: _selectOption,
                        ),
                      ),
                    ),

                    // ── Bottom CTA ──────────────────────────────────────
                    const SizedBox(height: AppSpacing.md),

                    if (_isLastQuestion) ...[
                      // "ALMOST THERE" badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            'ALMOST THERE! 🎯',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // SEE MY ROADMAP — apricot
                      _NeoButton(
                        label: 'SEE MY ROADMAP  →',
                        enabled: _hasAnswer && !_isLoading,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.apricot,
                        foregroundColor: AppColors.ink,
                        onPressed: _hasAnswer ? _goNext : null,
                      ),
                    ] else ...[
                      _NeoButton(
                        label: 'NEXT  →',
                        enabled: _hasAnswer && !_isLoading,
                        isLoading: false,
                        backgroundColor: AppColors.anchor,
                        foregroundColor: Colors.white,
                        onPressed: _hasAnswer ? _goNext : null,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question view (scrollable) ─────────────────────────────────────────────

class _QuestionView extends StatelessWidget {
  final QuizQuestion question;
  final bool Function(String) isSelected;
  final void Function(String) onSelect;

  const _QuestionView({
    super.key,
    required this.question,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.anchor,
              height: 1.3,
            ),
          ),

          if (question.hint != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              question.hint!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Options
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionRow(
                label: option,
                selected: isSelected(option),
                type: question.type,
                onTap: () => onSelect(option),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ── Option row ─────────────────────────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final QuestionType type;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.selected,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md - 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.anchor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.ink,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Icon(
                _iconFor(type, selected),
                key: ValueKey('${type.name}_$selected'),
                color: selected ? Colors.white : AppColors.muted,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(QuestionType type, bool selected) {
    if (type == QuestionType.multiSelect) {
      return selected
          ? Icons.check_box_rounded
          : Icons.check_box_outline_blank_rounded;
    }
    return selected
        ? Icons.radio_button_checked_rounded
        : Icons.radio_button_unchecked_rounded;
  }
}

// ── Reusable Neo-brutalist button ──────────────────────────────────────────

class _NeoButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _NeoButton({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: enabled ? const [AppShadows.hard] : [],
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.45),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            side: const BorderSide(color: AppColors.border, width: 2),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
