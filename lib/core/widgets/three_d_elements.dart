import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Rotating3DCube — Pure Flutter Matrix4 3D rotating cube
// ─────────────────────────────────────────────────────────────────────────────

/// A real 3D rotating cube built entirely with Flutter's [Transform] +
/// [Matrix4]. No packages required.
///
/// Each face is painted independently with a perspective-correct transform.
/// A neon glow halo beneath the cube grounds it in 3D space.
///
/// ```dart
/// Rotating3DCube(size: 80, faceColor: AppTheme.primary)
/// Rotating3DCube(size: 120, autoRotate: false, rotationX: 0.4, rotationY: 0.6)
/// ```
class Rotating3DCube extends StatefulWidget {
  const Rotating3DCube({
    super.key,
    this.size = 80.0,
    this.faceColor = AppTheme.primary,
    this.autoRotate = true,
    this.rotationX = 0.3,
    this.rotationY = 0.0,
    this.icon,
    this.speedMs = 6000,
  });

  final double size;
  final Color faceColor;
  final bool autoRotate;
  final double rotationX; // static tilt angle (radians)
  final double rotationY; // starting Y angle (radians)
  final IconData? icon;
  final int speedMs;

  @override
  State<Rotating3DCube> createState() => _Rotating3DCubeState();
}

class _Rotating3DCubeState extends State<Rotating3DCube>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.speedMs),
    );
    if (widget.autoRotate) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angleY = widget.rotationY + _ctrl.value * math.pi * 2;
        final angleX = widget.rotationX;

        return SizedBox(
          width: widget.size * 2,
          height: widget.size * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Ground glow shadow ──────────────────────────────────────
              _GroundGlow(size: widget.size, color: widget.faceColor),

              // ── 3D cube ─────────────────────────────────────────────────
              _CubeWidget(
                size: widget.size,
                angleX: angleX,
                angleY: angleY,
                faceColor: widget.faceColor,
                icon: widget.icon,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CubeWidget — 6-faced cube via Transform + Matrix4 perspective
// ─────────────────────────────────────────────────────────────────────────────

class _CubeWidget extends StatelessWidget {
  const _CubeWidget({
    required this.size,
    required this.angleX,
    required this.angleY,
    required this.faceColor,
    this.icon,
  });

  final double size;
  final double angleX;
  final double angleY;
  final Color faceColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final half = size / 2;

    // Perspective matrix — applied to the whole cube
    final perspective = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)       // perspective depth
      ..rotateX(angleX)
      ..rotateY(angleY);

    return Transform(
      transform: perspective,
      alignment: Alignment.center,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Front
            _Face(
              transform: Matrix4.translationValues(0, 0, half),
              size: size,
              color: faceColor,
              opacity: 1.0,
              icon: icon,
            ),
            // Back
            _Face(
              transform: Matrix4.translationValues(0, 0, -half)
                ..rotateY(math.pi),
              size: size,
              color: faceColor,
              opacity: 0.25,
            ),
            // Left
            _Face(
              transform: Matrix4.translationValues(-half, 0, 0)
                ..rotateY(-math.pi / 2),
              size: size,
              color: faceColor,
              opacity: 0.55,
            ),
            // Right
            _Face(
              transform: Matrix4.translationValues(half, 0, 0)
                ..rotateY(math.pi / 2),
              size: size,
              color: faceColor,
              opacity: 0.55,
            ),
            // Top
            _Face(
              transform: Matrix4.translationValues(0, -half, 0)
                ..rotateX(math.pi / 2),
              size: size,
              color: faceColor,
              opacity: 0.80,
            ),
            // Bottom
            _Face(
              transform: Matrix4.translationValues(0, half, 0)
                ..rotateX(-math.pi / 2),
              size: size,
              color: faceColor,
              opacity: 0.15,
            ),
          ],
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({
    required this.transform,
    required this.size,
    required this.color,
    required this.opacity,
    this.icon,
  });

  final Matrix4 transform;
  final double size;
  final Color color;
  final double opacity;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(opacity * 0.18),
          border: Border.all(
            color: color.withOpacity(opacity * 0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity * 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: icon != null && opacity > 0.8
            ? Icon(icon, color: color, size: size * 0.45)
            : null,
      ),
    );
  }
}

class _GroundGlow extends StatelessWidget {
  const _GroundGlow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: size * 0.08,
      child: Container(
        width: size * 1.1,
        height: size * 0.18,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.40),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rotating3DSphere — Wireframe sphere via CustomPainter + Matrix4
// ─────────────────────────────────────────────────────────────────────────────

/// A neon wireframe rotating sphere — great as the "AI core" base.
///
/// Draws latitude/longitude lines with [CustomPainter] after rotating each
/// vertex through a combined X+Y [Matrix4].
///
/// ```dart
/// Rotating3DSphere(size: 160, color: AppTheme.primary, rings: 8)
/// ```
class Rotating3DSphere extends StatefulWidget {
  const Rotating3DSphere({
    super.key,
    this.size = 160.0,
    this.color = AppTheme.primary,
    this.rings = 7,
    this.segments = 16,
    this.speedMs = 8000,
    this.tiltX = 0.3,
  });

  final double size;
  final Color color;
  final int rings;
  final int segments;
  final int speedMs;
  final double tiltX;

  @override
  State<Rotating3DSphere> createState() => _Rotating3DSphereState();
}

class _Rotating3DSphereState extends State<Rotating3DSphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.speedMs))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size.square(widget.size),
        painter: _SpherePainter(
          angleY: _ctrl.value * math.pi * 2,
          tiltX: widget.tiltX,
          color: widget.color,
          rings: widget.rings,
          segments: widget.segments,
        ),
      ),
    );
  }
}

class _SpherePainter extends CustomPainter {
  const _SpherePainter({
    required this.angleY,
    required this.tiltX,
    required this.color,
    required this.rings,
    required this.segments,
  });

  final double angleY;
  final double tiltX;
  final Color color;
  final int rings;
  final int segments;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.44;

    final sinY = math.sin(angleY);
    final cosY = math.cos(angleY);
    final sinX = math.sin(tiltX);
    final cosX = math.cos(tiltX);

    // Project a 3D point to 2D — Y rotation then X tilt
    Offset project(double px, double py, double pz) {
      // Y rotation
      final rx = px * cosY - pz * sinY;
      final ry = py;
      final rz = px * sinY + pz * cosY;
      // X tilt
      final tx = rx;
      final ty = ry * cosX - rz * sinX;
      final tz = ry * sinX + rz * cosX;
      // Perspective divide
      final perspective = 1.0 + tz * 0.0006;
      return Offset(cx + tx / perspective, cy + ty / perspective);
    }

    // ── Draw latitude rings ────────────────────────────────────────────────
    for (int i = 1; i < rings; i++) {
      final phi = math.pi * i / rings;
      final ringR = r * math.sin(phi);
      final y     = -r * math.cos(phi);

      final path = Path();
      for (int j = 0; j <= segments; j++) {
        final theta = math.pi * 2 * j / segments;
        final p = project(
            ringR * math.cos(theta), y, ringR * math.sin(theta));
        j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }

      // Fade rings that are on the back hemisphere
      final facingFactor = math.cos(math.pi * i / rings - math.pi / 2).abs();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withOpacity(0.12 + 0.35 * facingFactor),
      );
    }

    // ── Draw longitude lines ───────────────────────────────────────────────
    final lonCount = (segments / 2).round();
    for (int j = 0; j < lonCount; j++) {
      final theta = math.pi * 2 * j / lonCount;
      final path = Path();
      for (int i = 0; i <= rings * 2; i++) {
        final phi = math.pi * i / (rings * 2);
        final px  = r * math.sin(phi) * math.cos(theta);
        final py  = -r * math.cos(phi);
        final pz  = r * math.sin(phi) * math.sin(theta);
        final p   = project(px, py, pz);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }

      final facingFactor = (math.cos(theta - angleY).abs());
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withOpacity(0.08 + 0.30 * facingFactor),
      );
    }

    // ── Neon core dot ──────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), 4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(cx, cy), 12,
      Paint()
        ..color = color.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(_SpherePainter old) => old.angleY != angleY;
}
