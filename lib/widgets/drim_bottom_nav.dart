import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class DrimBottomNav extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String>? onNavigate;

  const DrimBottomNav({super.key, required this.currentRoute, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(icon: Icons.home_rounded, label: 'Home', route: '/home'),
      _NavItemData(
        icon: Icons.map_outlined,
        label: 'Roadmap',
        route: '/roadmap',
      ),
      _NavItemData(
        icon: Icons.add_rounded,
        label: '',
        route: '/dream-job',
        isCenter: true,
      ),
      _NavItemData(
        icon: Icons.bar_chart_rounded,
        label: 'Activity',
        route: '/activity',
      ),
      _NavItemData(
        icon: Icons.person_rounded,
        label: 'Profile',
        route: '/profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 2),
        ),
        boxShadow: const [AppShadows.soft],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Row(
            children: items.map((item) {
              final isActive = item.route == currentRoute;
              if (item.isCenter) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _handleTap(context, item.route),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.apricot,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(color: AppColors.border, width: 2),
                          boxShadow: const [AppShadows.hard],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 26,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(context, item.route),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isActive ? 50 : 38,
                        height: isActive ? 36 : 32,
                        decoration: isActive
                            ? BoxDecoration(
                                color: AppColors.anchor,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                              )
                            : null,
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: isActive ? Colors.white : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (item.label.isNotEmpty)
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.anchor
                                : AppColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String route) {
    if (route == currentRoute) return;
    if (onNavigate != null) {
      onNavigate!(route);
      return;
    }
    context.go(route);
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final String route;
  final bool isCenter;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.isCenter = false,
  });
}
