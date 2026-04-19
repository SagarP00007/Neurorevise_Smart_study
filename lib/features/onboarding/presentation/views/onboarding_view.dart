import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/core/widgets/animations.dart';
import 'package:study_smart/core/widgets/floating_icons.dart';
import 'package:study_smart/core/widgets/spirograph_ring.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingView — Splash / onboarding screen (reference design: left panel)
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background gradient ────────────────────────────────────────
          _Background(ctrl: _bgCtrl, size: size),

          // ── 2. Floating icon orbs (top area) ─────────────────────────────
          const FloatingIconLayer(
            icons: [
              FloatingIconData(
                icon: Icons.calculate_outlined,
                left: 0.65, top: 0.12,
                color: AppTheme.primary,
                size: 50, floatRange: 10, phaseOffset: 0.0,
              ),
              FloatingIconData(
                icon: Icons.settings_outlined,
                left: 0.22, top: 0.16,
                color: AppTheme.primary,
                size: 44, floatRange: 8, phaseOffset: 0.35,
              ),
              FloatingIconData(
                icon: Icons.grid_view_rounded,
                left: 0.72, top: 0.22,
                color: AppTheme.secondary,
                size: 46, floatRange: 9, phaseOffset: 0.6,
              ),
              FloatingIconData(
                icon: Icons.blur_circular_rounded,
                left: 0.38, top: 0.28,
                color: AppTheme.primary,
                size: 58, floatRange: 12, phaseOffset: 0.2,
                glowIntensity: 0.90,
              ),
            ],
          ),

          // ── 3. Bottom blue glow bloom ─────────────────────────────────────
          Positioned(
            bottom: -60,
            left: -40,
            right: -40,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.30),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── 4. Content ────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),

                // ── Tag line + title ────────────────────────────────────────
                FadeScaleIn(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          'Your Smart Study Companion',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Read, learn, and grow with AI-powered tools\ndesigned to support your academic journey.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // ── Get Started button ──────────────────────────────────────
                SlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _GetStartedButton(
                      onTap: () => context.go(RouteNames.login),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({required this.ctrl, required this.size});
  final AnimationController ctrl;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(color: AppTheme.bgDark),
        child: Stack(
          children: [
            // Top-right subtle glow
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Centre-left blue bloom
            Positioned(
              top: size.height * 0.25,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryDark.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wide blue pill "Get Started" button from the reference design.
class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 380),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl,
            curve: Curves.easeOut, reverseCurve: Curves.elasticOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_)   { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              gradient: const LinearGradient(
                colors: [Color(0xFF4A78F5), Color(0xFF2855CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Get Started',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AiChatView — AI assistant screen (reference design: middle panel)
// ─────────────────────────────────────────────────────────────────────────────

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const _MenuIcon(),
                  const Spacer(),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardDark,
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AppTheme.textSecondary, size: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Greeting ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello Alex, I am your virtual assistant',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'How can I help you today',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Spirograph ring ───────────────────────────────────────────
            Center(
              child: SpirographRing(
                size: 220,
                primaryColor: AppTheme.primary,
                secondaryColor: AppTheme.secondary,
                strands: 9,
              ),
            ),

            const SizedBox(height: 16),

            // ── AI description text ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.textSecondary, height: 1.6),
                  children: [
                    TextSpan(
                      text: 'Physics helps us ',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(
                      text:
                          'understand how the universe works, from the smallest particles to the vast cosmos.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Quick action chips ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.4,
                children: const [
                  _QuickChip(icon: Icons.menu_book_rounded, label: 'Study'),
                  _QuickChip(icon: Icons.functions_rounded, label: 'Solve Math'),
                  _QuickChip(icon: Icons.science_rounded, label: 'Physics'),
                  _QuickChip(icon: Icons.psychology_rounded, label: 'IQ Test'),
                ],
              ),
            ),

            const Spacer(),

            // ── Input bar ─────────────────────────────────────────────────
            _AiInputBar(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: const Icon(Icons.menu_rounded,
          color: AppTheme.textPrimary, size: 20),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _AiInputBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Ask me anything',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.textMuted),
              ),
            ),
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
