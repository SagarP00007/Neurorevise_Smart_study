import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AiCoreRing — Futuristic rotating 3D ring widget
// ─────────────────────────────────────────────────────────────────────────────

/// A multi-ring animated "AI core" widget that simulates depth with:
///  • Three independent rings at different tilt angles (3-D perspective via
///    canvas scale on the Y axis)
///  • Gradient arc strokes using [ui.Gradient.sweep]
///  • A pulsing neon glow orb at the centre
///  • Each ring rotates at its own speed and direction
///
/// ```dart
/// AiCoreRing(size: 220)
/// AiCoreRing(size: 160, primaryColor: AppTheme.secondary)
/// ```
class AiCoreRing extends StatefulWidget {
  const AiCoreRing({
    super.key,
    this.size = 200.0,
    this.primaryColor = AppTheme.primary,
    this.secondaryColor = AppTheme.secondary,
    this.accentColor = const Color(0xFF7B5FFF),
  });

  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  @override
  State<AiCoreRing> createState() => _AiCoreRingState();
}

class _AiCoreRingState extends State<AiCoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // A single looping ticker drives all rings — each ring uses a different
    // speed multiplier inside the painter, so one controller is enough.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: Size.square(widget.size),
          painter: _AiCorePainter(
            progress: _ctrl.value,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            accentColor: widget.accentColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AiCorePainter — CustomPainter that draws the rings
// ─────────────────────────────────────────────────────────────────────────────

class _AiCorePainter extends CustomPainter {
  const _AiCorePainter({
    required this.progress,    // 0.0 → 1.0, loops
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  // ── Constants ──────────────────────────────────────────────────────────────
  static const double _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.46;

    // ── 1. Background glow bloom ─────────────────────────────────────────────
    _drawBloom(canvas, cx, cy, maxR * 1.05, primaryColor);

    // ── 2. Outer ring — slowest, tilted most (appears deepest) ───────────────
    _drawRing(
      canvas, cx, cy,
      radius:     maxR,
      tiltY:      0.28,         // how "flat" the ellipse looks (0=circle, 0→ flat)
      strokeW:    3.5,
      arcSweep:   _tau * 0.72,
      rotation:   progress * _tau * 0.60,         // 0.6 full turns per 6 s
      colors:     [primaryColor, primaryColor.withOpacity(0)],
      glowColor:  primaryColor,
    );

    // Second arc on outer ring — counter segment for a broken-ring look
    _drawRing(
      canvas, cx, cy,
      radius:     maxR,
      tiltY:      0.28,
      strokeW:    1.5,
      arcSweep:   _tau * 0.15,
      rotation:   progress * _tau * 0.60 + _tau * 0.78,
      colors:     [primaryColor.withOpacity(0.5), primaryColor.withOpacity(0)],
      glowColor:  primaryColor,
    );

    // ── 3. Middle ring — medium tilt, opposite direction ─────────────────────
    _drawRing(
      canvas, cx, cy,
      radius:     maxR * 0.72,
      tiltY:      0.45,
      strokeW:    3.0,
      arcSweep:   _tau * 0.60,
      rotation:   -progress * _tau * 0.85 + math.pi / 4,
      colors:     [secondaryColor, secondaryColor.withOpacity(0)],
      glowColor:  secondaryColor,
    );

    _drawRing(
      canvas, cx, cy,
      radius:     maxR * 0.72,
      tiltY:      0.45,
      strokeW:    1.2,
      arcSweep:   _tau * 0.12,
      rotation:   -progress * _tau * 0.85 + _tau * 0.68,
      colors:     [secondaryColor.withOpacity(0.4), secondaryColor.withOpacity(0)],
      glowColor:  secondaryColor,
    );

    // ── 4. Inner ring — most vertical, fastest ────────────────────────────────
    _drawRing(
      canvas, cx, cy,
      radius:     maxR * 0.46,
      tiltY:      0.18,         // nearly a circle — stands upright
      strokeW:    2.5,
      arcSweep:   _tau * 0.50,
      rotation:   progress * _tau * 1.30,         // 1.3 turns per 6 s
      colors:     [accentColor, accentColor.withOpacity(0)],
      glowColor:  accentColor,
    );

    // ── 5. Core orb with pulsing glow ─────────────────────────────────────────
    _drawCoreOrb(canvas, cx, cy, maxR * 0.18, progress);
  }

  // ── Ring drawing helper ───────────────────────────────────────────────────

  void _drawRing(
    Canvas canvas,
    double cx,
    double cy, {
    required double radius,
    required double tiltY,   // Y-scale factor to create the 3-D tilt
    required double strokeW,
    required double arcSweep,
    required double rotation,
    required List<Color> colors,
    required Color glowColor,
  }) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(1.0, tiltY);   // squish vertically → looks like a tilted ring
    canvas.rotate(rotation);
    canvas.translate(-cx, -cy);

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // ── Glow pass (blurred, wider) ─────────────────────────────────────────
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = ui.Gradient.sweep(
          Offset(cx, cy),
          [glowColor.withOpacity(0.35), Colors.transparent],
          [0.0, 1.0],
          TileMode.clamp,
          0,
          arcSweep,
        );

    canvas.drawArc(rect, 0, arcSweep, false, glowPaint);

    // ── Main arc pass (crisp) ──────────────────────────────────────────────
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.sweep(
          Offset(cx, cy),
          colors,
          List.generate(colors.length, (i) => i / (colors.length - 1)),
          TileMode.clamp,
          0,
          arcSweep,
        );

    canvas.drawArc(rect, 0, arcSweep, false, paint);

    // ── Sharp dot at the arc head ──────────────────────────────────────────
    final headX = cx + radius * math.cos(arcSweep);
    final headY = cy + radius * math.sin(arcSweep);
    final dotPaint = Paint()
      ..color = colors.first.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(headX, headY), strokeW * 0.9, dotPaint);

    canvas.restore();
  }

  // ── Background bloom (wide blurred radial glow) ───────────────────────────

  void _drawBloom(Canvas canvas, double cx, double cy, double r, Color color) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy), r,
        [color.withOpacity(0.10), Colors.transparent],
      );
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  // ── Core orb — pulsing neon sphere at the centre ──────────────────────────

  void _drawCoreOrb(
      Canvas canvas, double cx, double cy, double r, double progress) {
    // Pulse: radius breathes every 3 s (half the controller period)
    final pulse = 0.85 + 0.15 * math.sin(progress * _tau * 2);
    final pr = r * pulse;

    // Outer glow
    canvas.drawCircle(
      Offset(cx, cy),
      pr * 2.6,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy), pr * 2.6,
          [primaryColor.withOpacity(0.18), Colors.transparent],
        ),
    );

    // Mid halo
    canvas.drawCircle(
      Offset(cx, cy),
      pr * 1.6,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy), pr * 1.6,
          [primaryColor.withOpacity(0.35), Colors.transparent],
        ),
    );

    // Core sphere gradient (bright centre → slightly darker edge)
    canvas.drawCircle(
      Offset(cx, cy),
      pr,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx - pr * 0.25, cy - pr * 0.25), pr,   // off-centre highlight
          [Colors.white.withOpacity(0.85), primaryColor, primaryColor.withOpacity(0.6)],
          [0.0, 0.5, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_AiCorePainter old) =>
      old.progress != progress ||
      old.primaryColor != primaryColor;
}
