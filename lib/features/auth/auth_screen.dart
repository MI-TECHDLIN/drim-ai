import 'package:drim_ai/widgets/drim_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drim_ai/core/app_config.dart';
import 'package:drim_ai/state/providers.dart';
import 'package:drim_ai/theme/app_colors.dart';
import 'package:drim_ai/theme/app_radii.dart';
import 'package:drim_ai/theme/app_shadows.dart';
import 'package:drim_ai/theme/app_spacing.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!AppConfig.isConfigured) {
      _showError('Supabase is not configured.');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authRepositoryProvider);

      if (_isSignUp) {
        await auth.signUp(email: email, password: password);
        // New user always needs onboarding
        if (mounted) context.go('/onboarding');
      } else {
        await auth.signIn(email: email, password: password);
        if (!mounted) return;
        // Check if returning user has completed onboarding
        final profile = await ref
            .read(profileRepositoryProvider)
            .getMyProfile();
        if (!mounted) return;
        context.go(
          (profile != null && profile.isComplete) ? '/home' : '/onboarding',
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _emailController.clear();
      _passwordController.clear();
    });
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
              // ── Logo ────────────────────────────────────────────────
              const DrimLogo(),

              const SizedBox(height: AppSpacing.xxl),

              // ── Heading ─────────────────────────────────────────────
              Text(
                _isSignUp ? 'CREATE YOUR\nACCOUNT' : 'WELCOME\nBACK',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.anchor,
                  height: 1.1,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 52,
                height: 3,
                color: AppColors.ink,
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Email field ──────────────────────────────────────────
              const _FieldLabel('EMAIL ADDRESS'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'hello@example.com',
                  suffixIcon: Icon(
                    _isSignUp
                        ? Icons.mail_outline_rounded
                        : Icons.alternate_email_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Password field ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FieldLabel(_isSignUp ? 'CREATE PASSWORD' : 'PASSWORD'),
                  if (!_isSignUp)
                    GestureDetector(
                      onTap: () {}, // TODO: forgot password flow
                      child: Text(
                        'Forgot?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.anchor,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.anchor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Primary CTA button ───────────────────────────────────
              _NeoButton(
                label: _isSignUp ? 'GET STARTED  →' : 'SIGN IN  →',
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
              ),

              // ── Sign Up extras ───────────────────────────────────────
              if (_isSignUp) ...[
                const SizedBox(height: AppSpacing.xl + AppSpacing.md),
                Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 72,
                    color: AppColors.muted.withOpacity(0.18),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              const SizedBox(height: AppSpacing.xl),

              // ── Toggle link ──────────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                    children: [
                      TextSpan(
                        text: _isSignUp
                            ? 'Already have an account?  '
                            : 'New here?  ',
                      ),

                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: _toggleMode,
                          child: Text(
                            _isSignUp ? 'Sign in' : 'Create account.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.anchor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.anchor,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Shared label widget ────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Neo-brutalist primary button (hard shadow via BoxDecoration) ───────────

class _NeoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _NeoButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = onPressed != null && !isLoading;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: active ? const [AppShadows.hard] : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.anchor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.anchor.withOpacity(0.6),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            side: const BorderSide(color: AppColors.border, width: 2),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
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

// ── OR divider ─────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.muted.withOpacity(0.35),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.muted.withOpacity(0.35),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ── Social sign-in button ──────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Color labelColor;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.labelColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: const [AppShadows.hardSm],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
      ),
    );
  }
}
