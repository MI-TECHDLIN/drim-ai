import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

// ── Error state ────────────────────────────────────────────────────────────
// Use when an API call fails and we can't show real data.

class DrimErrorState extends StatelessWidget {
  final String title;
  final String body;
  final String? buttonLabel;
  final VoidCallback? onRetry;
  final bool compact;

  const DrimErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.body =
        'We couldn\'t load this right now. '
        'Tap retry or check your connection.',
    this.buttonLabel,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              border: Border.all(color: AppColors.error, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'SOMETHING WENT WRONG',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),

          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),

          if (onRetry != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: const [AppShadows.hardSm],
              ),
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.anchor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    side: const BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
                child: Text(
                  buttonLabel ?? 'TRY AGAIN',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
// Use when an API call succeeds but returns zero results.

class DrimEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const DrimEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.body,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: const [AppShadows.hard],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.sand,
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: const [AppShadows.hardSm],
            ),
            child: Icon(icon, size: 30, color: AppColors.muted),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),

          if (onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: const [AppShadows.hardSm],
              ),
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.anchor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    side: const BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
                child: Text(
                  buttonLabel ?? 'GET STARTED',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Loading skeleton card ──────────────────────────────────────────────────
// Use during async operations as a placeholder.

class DrimLoadingCard extends StatefulWidget {
  final double height;
  final String? message;

  const DrimLoadingCard({super.key, this.height = 120, this.message});

  @override
  State<DrimLoadingCard> createState() => _DrimLoadingCardState();
}

class _DrimLoadingCardState extends State<DrimLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 2),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.anchor,
                ),
              ),
              if (widget.message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.message!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Offline banner ─────────────────────────────────────────────────────────
// Shown at the top of any screen when Supabase is not configured.
// Also useful for demo: shows graceful degradation message.

class DrimOfflineBanner extends StatelessWidget {
  final String message;

  const DrimOfflineBanner({
    super.key,
    this.message = 'Running in demo mode — showing example data.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.apricot,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.ink),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inline error snackbar helper ───────────────────────────────────────────
// Call from any ConsumerState to show a consistent error snackbar.

void showDrimError(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      margin: const EdgeInsets.all(AppSpacing.md),
    ),
  );
}

// ── Fallback info banner ───────────────────────────────────────────────────
// Shown when displaying fallback/example content instead of live data.

class DrimFallbackBanner extends StatelessWidget {
  final String message;

  const DrimFallbackBanner({
    super.key,
    this.message = 'Showing example data. Connect to see your real results.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.sky.withOpacity(0.25),
        border: Border.all(color: AppColors.sky, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: AppColors.anchor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.anchor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
