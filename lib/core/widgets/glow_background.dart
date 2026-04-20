import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

/// A full-screen animated background with:
/// - Deep navy radial gradient base
/// - Two slowly drifting neon glow orbs (blue + cyan)
/// - Subtle pulsing alpha for a "breathing" depth effect
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     const GlowBackground(),
///     YourContent(),
///   ],
/// )
/// ```
class GlowBackground extends StatefulWidget {
  const GlowBackground({
    super.key,
    this.child,
    /// Override orb colours to match a specific screen accent.
    this.primaryGlowColor,
    this.secondaryGlowColor,
    /// Animation speed multiplier (default 1.0). Use < 1 for slower.
    this.speed = 1.0,
  });

  final Widget? child;
  final Color? primaryGlowColor;
  final Color? secondaryGlowColor;
  final double speed;

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────

  /// Slow drift — moves the orbs gently around the canvas.
  late final AnimationController _driftController;

  /// Pulse — breathes the glow opacity in/out.
  late final AnimationController _pulseController;

  // ── Animations ─────────────────────────────────────────────────────────────

  late final Animation<double> _drift;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _driftController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (18000 / widget.speed).round()),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (4200 / widget.speed).round()),
    )..repeat(reverse: true);

    _drift = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _driftController, curve: Curves.linear),
    );

    _pulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _driftController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primaryColor =
        widget.primaryGlowColor ?? AppTheme.primary;
    final secondaryColor =
        widget.secondaryGlowColor ?? AppTheme.secondary;

    return AnimatedBuilder(
      animation: Listenable.merge([_drift, _pulse]),
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Base radial gradient ──────────────────────────────────────
            _BaseGradient(size: size),

            // ── Primary neon-blue orb (top-left region) ───────────────────
            _GlowOrb(
              size: size,
              color: primaryColor,
              // Drift in a slow ellipse offset to top-left
              cx: 0.15 + 0.12 * math.cos(_drift.value),
              cy: 0.18 + 0.10 * math.sin(_drift.value),
              radiusFactor: 0.52,
              opacity: 0.18 * _pulse.value,
            ),

            // ── Secondary cyan orb (bottom-right region) ──────────────────
            _GlowOrb(
              size: size,
              color: secondaryColor,
              // Drift in an opposite phase ellipse offset to bottom-right
              cx: 0.82 + 0.10 * math.cos(_drift.value + math.pi),
              cy: 0.75 + 0.08 * math.sin(_drift.value + math.pi),
              radiusFactor: 0.44,
              opacity: 0.14 * _pulse.value,
            ),

            // ── Tertiary dark-orange orb (centre) ──────────────────────────────
            _GlowOrb(
              size: size,
              color: const Color(0xFF7A1A00),
              cx: 0.5 + 0.06 * math.cos(_drift.value + math.pi / 2),
              cy: 0.48 + 0.06 * math.sin(_drift.value + math.pi / 2),
              radiusFactor: 0.65,
              opacity: 0.06 * _pulse.value,
            ),

            // ── Vignette overlay — pinches edges darker for depth ──────────
            const _Vignette(),

            // ── Optional child content ─────────────────────────────────────
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Flat dark background radial gradient — the canvas layer.
class _BaseGradient extends StatelessWidget {
  const _BaseGradient({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.4,
          colors: [
            Color(0xFF252527), // slightly lighter charcoal at focal point
            Color(0xFF1C1C1E), // bgDark
            Color(0xFF111113), // near-black edges
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

/// A single soft radial glow orb positioned by fractional [cx]/[cy] offsets.
///
/// [radiusFactor] is relative to screen width.
/// [opacity]      drives how bright the glow is (0–1).
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.cx,
    required this.cy,
    required this.radiusFactor,
    required this.opacity,
  });

  final Size size;
  final Color color;
  final double cx;   // fractional x (0–1)
  final double cy;   // fractional y (0–1)
  final double radiusFactor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final radius = size.width * radiusFactor;
    final left   = size.width  * cx - radius;
    final top    = size.height * cy - radius;

    return Positioned(
      left: left,
      top:  top,
      child: IgnorePointer(
        child: Container(
          width:  radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(opacity),
                color.withOpacity(opacity * 0.35),
                color.withOpacity(0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

/// Edge-darkening vignette — creates a cinematic letterbox depth feeling.
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.0),
              Colors.black.withOpacity(0.55),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
