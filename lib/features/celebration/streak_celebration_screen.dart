import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/celebration_data.dart';
import '../../models/user_badge.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class StreakCelebrationScreen extends StatelessWidget {
  final StreakCelebrationData data;

  const StreakCelebrationScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final badge = data.newBadgeId != null
        ? kBadgeDefinitions[data.newBadgeId]
        : null;

    return Scaffold(
      body: Column(
        children: [
          // Top half — Anchor teal
          Expanded(
            flex: 5,
            child: Container(
              color: AppColors.anchor,
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
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

                      // Flame emoji
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 72),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        '${data.currentStreak} DAY\nSTREAK',
                        style: GoogleFonts.poppins(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        'You\'ve shown up ${data.currentStreak} days straight.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom half — sand
          Expanded(
            flex: 6,
            child: Container(
              color: AppColors.sand,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl,
                  AppSpacing.lg, 0,
                ),
                child: Column(
                  children: [
                    // Stats card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                            color: AppColors.border, width: 2),
                        borderRadius:
                            BorderRadius.circular(AppRadii.lg),
                        boxShadow: const [AppShadows.hard],
                      ),
                      child: Row(
                        children: [
                          _StatCell(
                              'CURRENT', '${data.currentStreak}'),
                          _Divider(),
                          _StatCell('BEST', '${data.bestStreak}'),
                          _Divider(),
                          _StatCell(
                              'THIS MONTH', '${data.thisMonth}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Badge card
                    if (badge != null)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.apricot,
                          border: Border.all(
                              color: AppColors.border, width: 2),
                          borderRadius:
                              BorderRadius.circular(AppRadii.lg),
                          boxShadow: const [AppShadows.hard],
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BADGE UNLOCKED',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink.withOpacity(0.7),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.anchor,
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                    border: Border.all(
                                        color: AppColors.border,
                                        width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      badge.emoji,
                                      style: const TextStyle(
                                          fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      badge.name.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      badge.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.ink
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Keep the streak button
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.lg),
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
                                  const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                side: const BorderSide(
                                    color: AppColors.border, width: 2),
                              ),
                            ),
                            child: Text(
                              'KEEP THE STREAK  →',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.anchor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: AppColors.line,
    );
  }
}