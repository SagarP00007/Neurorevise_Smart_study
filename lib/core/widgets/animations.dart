import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 1 — Low-level animation wrappers
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Pressable — Spring-scale press feedback for ANY widget
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps any [child] with a spring-scale press animation.
///
/// Drop-in replacement for [GestureDetector] wherever you need tactile press
/// feedback without building a custom StatefulWidget.
///
/// ```dart
/// Pressable(
///   onTap: () {},
///   child: MyCard(),
/// )
/// ```
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleTo = 0.96,
    this.pressMs = 120,
    this.releaseMs = 380,
    this.haptic = true,
    this.enabled = true,
    this.cursor = SystemMouseCursors.click,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale when pressed. Typical range: 0.92 – 0.98.
  final double scaleTo;
  final int pressMs;
  final int releaseMs;
  final bool haptic;
  final bool enabled;
  final MouseCursor cursor;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.pressMs),
      reverseDuration: Duration(milliseconds: widget.releaseMs),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleTo).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: Curves.easeOut,
          reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down(TapDownDetails _) {
    if (!widget.enabled) return;
    _ctrl.forward();
    if (widget.haptic) HapticFeedback.lightImpact();
  }

  void _up(TapUpDetails _) {
    _ctrl.reverse();
    if (widget.enabled) widget.onTap?.call();
  }

  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? widget.cursor : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HoverCard — Scale + glow on mouse hover (desktop / web)
// ─────────────────────────────────────────────────────────────────────────────

/// Lifts and subtly scales any widget when the mouse hovers over it.
/// On mobile (no hover) it behaves as a plain [Pressable].
///
/// ```dart
/// HoverCard(
///   glowColor: AppTheme.primary,
///   onTap: () {},
///   child: MyGlassCard(),
/// )
/// ```
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor = AppTheme.primary,
    this.hoverScale = 1.025,
    this.hoverMs = 200,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color glowColor;
  final double hoverScale;
  final int hoverMs;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.hoverMs),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.hoverScale).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glow  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit:  (_) => _ctrl.reverse(),
      child: Pressable(
        onTap: widget.onTap,
        haptic: true,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.20 * _glow.value),
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: child,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 2 — Route & visibility transitions
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// FadeScaleIn — Entrance animation: fade + scale up from slightly smaller
// ─────────────────────────────────────────────────────────────────────────────

/// Animates its [child] from invisible + slightly shrunk → fully visible.
/// Starts immediately unless [delay] is provided.
///
/// ```dart
/// FadeScaleIn(delay: Duration(milliseconds: 200), child: MyWidget())
/// ```
class FadeScaleIn extends StatefulWidget {
  const FadeScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.fromScale = 0.88,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double fromScale;
  final Curve curve;

  @override
  State<FadeScaleIn> createState() => _FadeScaleInState();
}

class _FadeScaleInState extends State<FadeScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    final curve = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _scale   = Tween<double>(begin: widget.fromScale, end: 1.0).animate(curve);

    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(scale: _scale.value, child: child),
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SlideIn — Entrance: slide from a given direction + fade
// ─────────────────────────────────────────────────────────────────────────────

/// Slides content in from [direction] with a simultaneous fade.
///
/// ```dart
/// SlideIn(direction: AxisDirection.up, child: MyBanner())
/// ```
class SlideIn extends StatefulWidget {
  const SlideIn({
    super.key,
    required this.child,
    this.direction = AxisDirection.up,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.distance = 32.0,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final AxisDirection direction;
  final Duration delay;
  final Duration duration;
  final double distance;
  final Curve curve;

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    final curve = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    final d = widget.distance;
    final begin = switch (widget.direction) {
      AxisDirection.up    => Offset(0,  d),
      AxisDirection.down  => Offset(0, -d),
      AxisDirection.left  => Offset( d, 0),
      AxisDirection.right => Offset(-d, 0),
    };

    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(curve);

    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(offset: _slide.value, child: child),
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StaggeredList — Wraps each child in a staggered SlideIn entrance
// ─────────────────────────────────────────────────────────────────────────────

/// Given a list of [children], wraps each in a [SlideIn] with a stagger gap.
///
/// ```dart
/// StaggeredList(
///   staggerMs: 70,
///   children: myItems.map((i) => MyCard(i)).toList(),
/// )
/// ```
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerMs = 60,
    this.initialDelayMs = 0,
    this.direction = AxisDirection.up,
    this.distance = 24.0,
  });

  final List<Widget> children;
  final int staggerMs;
  final int initialDelayMs;
  final AxisDirection direction;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.asMap().entries.map((e) {
        return SlideIn(
          direction: direction,
          delay: Duration(milliseconds: initialDelayMs + e.key * staggerMs),
          distance: distance,
          child: e.value,
        );
      }).toList(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 3 — State-change animations
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedVisibility — Cross-fades + scales between shown/hidden
// ─────────────────────────────────────────────────────────────────────────────

/// Animates presence of [child] — fades + scales in when [visible] is true.
///
/// Unlike [AnimatedOpacity], the widget is completely removed from the tree
/// when hidden (no accessibility hit-testing on invisible elements).
///
/// ```dart
/// AnimatedVisibility(visible: _showBanner, child: MyBanner())
/// ```
class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);
  }

  @override
  void didUpdateWidget(AnimatedVisibility old) {
    super.didUpdateWidget(old);
    widget.visible ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        if (_anim.value == 0.0) return const SizedBox.shrink();
        return Opacity(
          opacity: _anim.value,
          child: Transform.scale(
              scale: 0.92 + 0.08 * _anim.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedNumber — Smoothly counts from one value to another
// ─────────────────────────────────────────────────────────────────────────────

/// Animates a numeric display from its previous value to [value].
/// Great for stats, badges, and counters.
///
/// ```dart
/// AnimatedNumber(value: streak, style: theme.textTheme.headlineMedium)
/// ```
class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.fractionDigits = 0,
  });

  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;
  final int fractionDigits;

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _value;
  double _from = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _value = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: widget.curve));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = _value.value;
      _value = Tween<double>(begin: _from, end: widget.value).animate(
          CurvedAnimation(parent: _ctrl..reset(), curve: widget.curve));
      _ctrl.forward();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _value,
      builder: (_, __) {
        final display = widget.fractionDigits > 0
            ? _value.value.toStringAsFixed(widget.fractionDigits)
            : _value.value.round().toString();
        return Text(
          '${widget.prefix}$display${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerBox — Loading skeleton shimmer effect
// ─────────────────────────────────────────────────────────────────────────────

/// Paints an animated shimmer gradient over a rounded rectangle.
/// Use as a placeholder while data loads.
///
/// ```dart
/// ShimmerBox(width: double.infinity, height: 80, radius: 16)
/// ```
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppTheme.radiusM,
    this.baseColor,
    this.highlightColor,
  });

  final double width;
  final double height;
  final double radius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final base      = widget.baseColor      ?? AppTheme.cardDark;
    final highlight = widget.highlightColor ?? AppTheme.borderDark;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [base, highlight, base],
            stops: [
              (_shimmer.value - 0.5).clamp(0.0, 1.0),
              _shimmer.value.clamp(0.0, 1.0),
              (_shimmer.value + 0.5).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 4 — Reusable animation helper functions
// ═════════════════════════════════════════════════════════════════════════════

/// Collection of static page-route and widget transition builders.
class Transitions {
  Transitions._();

  // GoRouter page-level transitions (fadeScale, slideUp, slideRight) live in:
  //   lib/core/router/app_transitions.dart
  //
  // Only pure-Flutter AnimatedSwitcher helpers belong in this class.

  // ── Widget transitions ───────────────────────────────────────────────────

  /// Returns an [AnimatedSwitcher] with a cross-fade + scale transition.
  static Widget switchFadeScale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child),
        );
      },
      child: child,
    );
  }

  /// Bouncy scale switcher — great for toggling icons (e.g. ♡ → ♥).
  static Widget switchBounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide + fade switcher — great for stepping through content.

  static Widget switchSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    AxisDirection direction = AxisDirection.up,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        final begin = switch (direction) {
          AxisDirection.up    => const Offset(0,  0.1),
          AxisDirection.down  => const Offset(0, -0.1),
          AxisDirection.left  => const Offset( 0.1, 0),
          AxisDirection.right => const Offset(-0.1, 0),
        };
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: child,
    );
  }
}

// Note: GoRouter types (GoRouterState, CustomTransitionPage) are provided
// by the go_router package. The Transitions class above uses local Flutter
// AnimatedSwitcher helpers only — GoRouter transitions live in app_transitions.dart.
