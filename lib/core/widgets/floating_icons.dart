import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FloatingIcon — Single animated, glowing floating icon
// ─────────────────────────────────────────────────────────────────────────────

/// A circular icon that floats up and down with a neon glow halo.
///
/// Randomises its own phase offset so every instance in a [FloatingIconLayer]
/// moves independently for an organic feel.
///
/// ```dart
/// FloatingIcon(
///   icon: Icons.auto_stories_rounded,
///   color: AppTheme.primary,
///   size: 54,
///   floatRange: 12,
/// )
/// ```
class FloatingIcon extends StatefulWidget {
  const FloatingIcon({
    super.key,
    required this.icon,
    this.color = AppTheme.primary,
    this.size = 54.0,
    this.iconSize = 22.0,
    /// Vertical travel distance in logical pixels.
    this.floatRange = 10.0,
    /// Full float cycle duration. Stagger via [phaseOffset].
    this.duration = const Duration(milliseconds: 3200),
    /// Phase shift (0.0–1.0) so icons don't move in sync.
    this.phaseOffset = 0.0,
    /// Intensity of the glow halo (0–1).
    this.glowIntensity = 0.7,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double floatRange;
  final Duration duration;
  final double phaseOffset;
  final double glowIntensity;
  final VoidCallback? onTap;

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;  // -1 → +1
  late final Animation<double> _pulse;  // glow size breathes

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    // Start at phase offset so each icon is at a different point in the cycle.
    _ctrl.value = widget.phaseOffset.clamp(0.0, 1.0);

    _float = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (context, _) {
        final dy = _float.value * widget.floatRange;
        final glowSpread = _pulse.value * widget.glowIntensity;

        return Transform.translate(
          offset: Offset(0, dy),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Frosted glass fill
                color: widget.color.withOpacity(0.12),
                border: Border.all(
                  color: widget.color.withOpacity(0.30),
                  width: 1.5,
                ),
                boxShadow: [
                  // Tight inner glow
                  BoxShadow(
                    color: widget.color.withOpacity(0.40 * glowSpread),
                    blurRadius: 12,
                    spreadRadius: -1,
                  ),
                  // Wide ambient halo
                  BoxShadow(
                    color: widget.color.withOpacity(0.20 * glowSpread),
                    blurRadius: 28,
                    spreadRadius: -2,
                  ),
                  // Ultra-wide diffuse glow
                  BoxShadow(
                    color: widget.color.withOpacity(0.08 * glowSpread),
                    blurRadius: 56,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FloatingIconLayer — Scatter a collection of icons across a canvas
// ─────────────────────────────────────────────────────────────────────────────

/// Describes a single entry in a [FloatingIconLayer].
class FloatingIconData {
  const FloatingIconData({
    required this.icon,
    required this.left,
    required this.top,
    this.color = AppTheme.primary,
    this.size = 54.0,
    this.iconSize = 22.0,
    this.floatRange = 10.0,
    this.durationMs = 3200,
    this.phaseOffset = 0.0,
    this.glowIntensity = 0.65,
    this.onTap,
  });

  final IconData icon;

  /// Fractional horizontal position (0.0 = left edge, 1.0 = right edge).
  final double left;

  /// Fractional vertical position (0.0 = top edge, 1.0 = bottom edge).
  final double top;

  final Color color;
  final double size;
  final double iconSize;
  final double floatRange;
  final int durationMs;
  final double phaseOffset;
  final double glowIntensity;
  final VoidCallback? onTap;
}

/// Places [FloatingIcon] widgets at fractional positions inside a [Stack].
///
/// Sized with [SizedBox.expand] so it fills its parent.
///
/// **Tip:** Wrap your screen in a [Stack] and put [FloatingIconLayer] behind
/// your main content:
/// ```dart
/// Stack(
///   children: [
///     GlowBackground(),
///     FloatingIconLayer(icons: FloatingIconLayer.studyPreset),
///     SafeArea(child: YourPageContent()),
///   ],
/// )
/// ```
class FloatingIconLayer extends StatelessWidget {
  const FloatingIconLayer({super.key, required this.icons});

  final List<FloatingIconData> icons;

  // ── Ready-made presets ─────────────────────────────────────────────────────

  /// Study-themed scatter for the Dashboard / Home screen.
  static const List<FloatingIconData> studyPreset = [
    FloatingIconData(
      icon: Icons.auto_stories_rounded,
      left: 0.82, top: 0.08,
      color: AppTheme.primary,
      size: 54, floatRange: 12, phaseOffset: 0.0,
    ),
    FloatingIconData(
      icon: Icons.lightbulb_rounded,
      left: 0.06, top: 0.14,
      color: AppTheme.secondary,
      size: 46, floatRange: 9, phaseOffset: 0.3,
    ),
    FloatingIconData(
      icon: Icons.psychology_rounded,
      left: 0.72, top: 0.28,
      color: Color(0xFFB48EFF), // soft purple
      size: 40, floatRange: 8, phaseOffset: 0.6,
      glowIntensity: 0.55,
    ),
    FloatingIconData(
      icon: Icons.calculate_rounded,
      left: 0.10, top: 0.44,
      color: AppTheme.warning,
      size: 44, floatRange: 11, phaseOffset: 0.15,
    ),
    FloatingIconData(
      icon: Icons.science_rounded,
      left: 0.88, top: 0.56,
      color: AppTheme.secondary,
      size: 38, floatRange: 7, phaseOffset: 0.5,
      glowIntensity: 0.50,
    ),
    FloatingIconData(
      icon: Icons.music_note_rounded,
      left: 0.18, top: 0.70,
      color: Color(0xFFFF6B9D), // pink
      size: 42, floatRange: 10, phaseOffset: 0.75,
    ),
    FloatingIconData(
      icon: Icons.history_edu_rounded,
      left: 0.65, top: 0.78,
      color: AppTheme.primary,
      size: 36, floatRange: 8, phaseOffset: 0.9,
      glowIntensity: 0.45,
    ),
    FloatingIconData(
      icon: Icons.biotech_rounded,
      left: 0.40, top: 0.06,
      color: Color(0xFFFFB347), // amber
      size: 32, floatRange: 6, phaseOffset: 0.45,
      glowIntensity: 0.40,
    ),
  ];

  /// Minimal 3-icon preset for focused screens (login, onboarding).
  static const List<FloatingIconData> minimalPreset = [
    FloatingIconData(
      icon: Icons.auto_stories_rounded,
      left: 0.78, top: 0.10,
      color: AppTheme.primary,
      size: 56, floatRange: 13, phaseOffset: 0.0,
    ),
    FloatingIconData(
      icon: Icons.lightbulb_rounded,
      left: 0.08, top: 0.18,
      color: AppTheme.secondary,
      size: 44, floatRange: 9, phaseOffset: 0.4,
    ),
    FloatingIconData(
      icon: Icons.bolt_rounded,
      left: 0.85, top: 0.72,
      color: AppTheme.warning,
      size: 38, floatRange: 8, phaseOffset: 0.7,
      glowIntensity: 0.50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Allow taps to pass through unless an individual icon has onTap set.
      ignoring: icons.every((e) => e.onTap == null),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: icons.map((data) {
                // Convert fractional to absolute, centred on the icon.
                final l = constraints.maxWidth  * data.left - data.size / 2;
                final t = constraints.maxHeight * data.top  - data.size / 2;

                return Positioned(
                  left: l,
                  top: t,
                  child: Opacity(
                    opacity: 0.75,        // slightly faded so content stays readable
                    child: FloatingIcon(
                      icon: data.icon,
                      color: data.color,
                      size: data.size,
                      iconSize: data.iconSize,
                      floatRange: data.floatRange,
                      duration: Duration(milliseconds: data.durationMs),
                      phaseOffset: data.phaseOffset,
                      glowIntensity: data.glowIntensity,
                      onTap: data.onTap,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FloatingIconRandom — Procedurally scatter icons with no manual positioning
// ─────────────────────────────────────────────────────────────────────────────

/// Auto-generates [count] floating icons from [iconPool] at random positions.
///
/// Seeded with [seed] for reproducible layouts across rebuilds.
///
/// ```dart
/// FloatingIconRandom(
///   count: 6,
///   iconPool: [Icons.star, Icons.bolt, Icons.lightbulb],
///   colorPool: [AppTheme.primary, AppTheme.secondary, AppTheme.warning],
/// )
/// ```
class FloatingIconRandom extends StatelessWidget {
  const FloatingIconRandom({
    super.key,
    this.count = 6,
    this.iconPool = const [
      Icons.auto_stories_rounded,
      Icons.lightbulb_rounded,
      Icons.psychology_rounded,
      Icons.calculate_rounded,
      Icons.science_rounded,
      Icons.history_edu_rounded,
    ],
    this.colorPool = const [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.warning,
    ],
    this.seed = 42,
    this.minSize = 32.0,
    this.maxSize = 58.0,
  });

  final int count;
  final List<IconData> iconPool;
  final List<Color> colorPool;
  final int seed;
  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(seed);

    final icons = List.generate(count, (i) {
      final size = minSize + rng.nextDouble() * (maxSize - minSize);
      return FloatingIconData(
        icon: iconPool[i % iconPool.length],
        color: colorPool[rng.nextInt(colorPool.length)],
        left: 0.05 + rng.nextDouble() * 0.90,
        top:  0.05 + rng.nextDouble() * 0.90,
        size: size,
        iconSize: size * 0.4,
        floatRange: 6 + rng.nextDouble() * 8,
        durationMs: 2800 + rng.nextInt(1600),
        phaseOffset: rng.nextDouble(),
        glowIntensity: 0.40 + rng.nextDouble() * 0.35,
      );
    });

    return FloatingIconLayer(icons: icons);
  }
}
