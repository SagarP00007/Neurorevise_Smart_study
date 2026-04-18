import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/core/widgets/ui_kit.dart';
import 'package:study_smart/core/widgets/app_text_field.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final vm = context.read<AuthViewModel>();
    await vm.signIn(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (vm.state == AuthState.error) {
      _showError(vm.errorMessage ?? 'Sign in failed');
      vm.clearError();
    }
    // GoRouter redirect handles navigation on success via authViewModel listener
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final vm    = context.watch<AuthViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      // ── Full-screen background ─────────────────────────────────────────
      body: Stack(
        children: [
          // Animated neon glow background
          const GlowBackground(),

          // Floating study icons — subtle, behind the form
          const FloatingIconLayer(icons: FloatingIconLayer.minimalPreset),

          // ── Scrollable content ────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // ── Hero header ────────────────────────────────────
                    FadeScaleIn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AI ring badge
                          const AiCoreRing(size: 80),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome back',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue your learning journey',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Glass form card ────────────────────────────────
                    SlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        blur: 20,
                        fillOpacity: 0.07,
                        borderOpacity: 0.18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email
                            AppTextField(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter your email'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            AppTextField(
                              label: 'Password',
                              hint: '••••••••',
                              controller: _passCtrl,
                              obscureText: _obscure,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min 6 characters'
                                  : null,
                            ),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: NeonTextButton(
                                label: 'Forgot Password?',
                                onTap: () {},
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Submit button ──────────────────────────────────
                    SlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: NeonButton(
                        label: 'Sign In',
                        icon: Icons.arrow_forward_rounded,
                        isLoading: vm.isLoading,
                        onTap: vm.isLoading ? null : _submit,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Sign up link ───────────────────────────────────
                    SlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary),
                          ),
                          NeonTextButton(
                            label: 'Sign Up',
                            onTap: () => context.go(RouteNames.register),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
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
