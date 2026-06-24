import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/celebration_data.dart';
import '../../models/user_badge.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class SkillCelebrationScreen extends StatefulWidget {
  final SkillCelebrationData data;

  const SkillCelebrationScreen({super.key, required this.data});

  @override
  State<SkillCelebrationScreen> createState() =>
      _SkillCelebrationScreenState();
}

class _SkillCelebrationScreenState extends State<SkillCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _show = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.data.newBadgeId != null
        ? kBadgeDefinitions[widget.data.newBadgeId]
        : null;

    return Scaffold(
      backgroundColor: AppColors.anchor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DRIM AI wordmark
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
                            horizontal: 5, vertical: 2),
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

                  // Trophy icon
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: const [AppShadows.hardLg],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 52,
                      color: AppColors.anchor,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Achievement unlocked
                  Row(
                    children: [
                      const Text('✦',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'ACHIEVEMENT UNLOCKED',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('✦',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'SKILL\nUNLOCKED!',
                    style: GoogleFonts.poppins(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  Container(width: 48, height: 2, color: Colors.white38),
                  const SizedBox(height: AppSpacing.xl),

                  // Skill name card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: const [AppShadows.hard],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data.skillName,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                widget.data.category.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                                color: AppColors.border, width: 1.5),
                            borderRadius:
                                BorderRadius.circular(AppRadii.sm - 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'COMPLETED',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.check_rounded,
                                  size: 14, color: AppColors.anchor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // XP card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.apricot,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: const [AppShadows.hard],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded,
                              size: 18, color: AppColors.ink),
                          const SizedBox(width: 4),
                          Text(
                            '+${widget.data.xpEarned} XP · Keep going',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Encouragement card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: const [AppShadows.hardSm],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('♦',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.anchor)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${widget.data.skillName} opens the door to bigger opportunities. You\'re leveling up fast.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.ink,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge earned (if applicable)
                  if (badge != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withOpacity(0.3),
                        border: Border.all(
                            color: AppColors.sage, width: 2),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Row(
                        children: [
                          Text(
                            badge.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BADGE UNLOCKED',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                badge.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                            boxShadow: const [AppShadows.hard],
                          ),
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.anchor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize:
                                  const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                side: const BorderSide(
                                    color: Colors.white38, width: 2),
                              ),
                            ),
                            child: Text(
                              'NEXT SKILL  →',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                            boxShadow: const [AppShadows.hard],
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                context.go('/activity'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.ink,
                              elevation: 0,
                              minimumSize:
                                  const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                side: const BorderSide(
                                    color: AppColors.border, width: 2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                    Icons.trending_up_rounded,
                                    size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'VIEW',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Center(
                    child: Text(
                      'DRIM AI · SKILL ENGINE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}