import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpirographRing — Multi-strand Lissajous / spirograph orbit ring
//
// Matches the AI core ring shown in the reference design:
// multiple overlapping elliptical blue strands rotating slowly.
// ─────────────────────────────────────────────────────────────────────────────

class SpirographRing extends StatefulWidget {
  const SpirographRing({
    super.key,
    this.size = 220.0,
    this.primaryColor = AppTheme.primary,
    this.secondaryColor = AppTheme.secondary,
    this.strands = 8,
    this.speedMs = 12000,
    this.strokeWidth = 1.4,
  });

  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final int strands;
  final int speedMs;
  final double strokeWidth;

  @override
  State<SpirographRing> createState() => _SpirographRingState();
}

class _SpirographRingState extends State<SpirographRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.speedMs),
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
          painter: _SpirographPainter(
            progress: _ctrl.value,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            strands: widget.strands,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _SpirographPainter extends CustomPainter {
  const _SpirographPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.strands,
    required this.strokeWidth,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final int strands;
  final double strokeWidth;

  static const int _steps = 300;  // points per strand

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.44;

    // ── Background bloom glow ──────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), r * 1.1,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy), r * 1.1,
          [primaryColor.withOpacity(0.08), Colors.transparent],
        ),
    );

    final baseAngle = progress * math.pi * 2;

    for (int s = 0; s < strands; s++) {
      // Each strand has a slightly different phase and tilt
      final strandPhase = (s / strands) * math.pi * 2;
      final tiltY = 0.25 + (s / strands) * 0.65;   // 0.25 (flat) → 0.90 (circle)
      final opacity = 0.55 + 0.45 * math.sin(strandPhase);

      // Interpolate colour along strands
      final t = s / strands;
      final color = Color.lerp(primaryColor, secondaryColor, t)!
          .withOpacity(opacity);

      final path = Path();
      for (int i = 0; i <= _steps; i++) {
        final theta = (i / _steps) * math.pi * 2;

        // Lissajous-inspired: x uses theta, y uses theta + phase offset
        final x = r * math.cos(theta + strandPhase + baseAngle);
        final y = r * math.sin(theta + strandPhase + baseAngle) * tiltY;

        final px = cx + x;
        final py = cy + y;

        i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
      }

      // ── Glow pass ────────────────────────────────────────────────────────
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 3
          ..color = color.withOpacity(0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // ── Main strand ───────────────────────────────────────────────────────
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = color
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Centre dot ────────────────────────────────────────────────────────
    final pulse = 0.85 + 0.15 * math.sin(progress * math.pi * 4);
    canvas.drawCircle(
      Offset(cx, cy), 4 * pulse,
      Paint()..color = primaryColor,
    );
    canvas.drawCircle(
      Offset(cx, cy), 12 * pulse,
      Paint()
        ..color = primaryColor.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(_SpirographPainter old) => old.progress != progress;
}
