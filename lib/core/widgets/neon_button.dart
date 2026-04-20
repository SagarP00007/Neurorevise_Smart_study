import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NeonButton — Primary futuristic glowing button
// ─────────────────────────────────────────────────────────────────────────────

/// A fully animated neon-glow button.
///
/// On tap it:
///   1. Scales down slightly (tactile press feel)
///   2. Briefly dims the glow (depth illusion)
///   3. Fires haptic feedback
///   4. Restores to idle state with a spring curve
///
/// ```dart
/// NeonButton(
///   label: 'Start Revision',
///   icon: Icons.bolt_rounded,
///   onTap: () {},
/// )
/// ```
class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.color = AppTheme.primary,
    this.textColor,
    this.width = double.infinity,
    this.height = 54.0,
    this.borderRadius = AppTheme.radiusM,
    this.isLoading = false,
    this.enabled = true,
    this.variant = NeonButtonVariant.filled,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;

  /// Defaults to [AppTheme.bgDark] for filled, [color] for outlined/ghost.
  final Color? textColor;

  final double width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;
  final NeonButtonVariant variant;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

enum NeonButtonVariant { filled, outlined, ghost }

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 380),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.955).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut,
          reverseCurve: Curves.elasticOut),
    );

    _glow = Tween<double>(begin: 1.0, end: 0.25).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut,
          reverseCurve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Interaction ────────────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled || widget.isLoading) return;
    _pressed = true;
    _ctrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _release();
    if (widget.enabled && !widget.isLoading) widget.onTap?.call();
  }

  void _onTapCancel() => _release();

  void _release() {
    if (!_pressed) return;
    _pressed = false;
    _ctrl.reverse();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isActive = widget.enabled && !widget.isLoading;
    final color    = isActive ? widget.color : AppTheme.borderDark;
    final fgColor  = widget.textColor ??
        (widget.variant == NeonButtonVariant.filled
            ? AppTheme.bgDark
            : color);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: _ButtonShell(
              color: color,
              fgColor: fgColor,
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
              glowIntensity: _glow.value,
              variant: widget.variant,
              child: _ButtonContent(
                label: widget.label,
                icon: widget.icon,
                fgColor: fgColor,
                isLoading: widget.isLoading,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ButtonShell extends StatelessWidget {
  const _ButtonShell({
    required this.color,
    required this.fgColor,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.glowIntensity,
    required this.variant,
    required this.child,
  });

  final Color color;
  final Color fgColor;
  final double width;
  final double height;
  final double borderRadius;
  final double glowIntensity;
  final NeonButtonVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    // ── Glow shadows layer ────────────────────────────────────────────────
    final List<BoxShadow> shadows = [
      // Tight inner glow
      BoxShadow(
        color: color.withOpacity(0.55 * glowIntensity),
        blurRadius: 14,
        spreadRadius: -2,
        offset: const Offset(0, 2),
      ),
      // Outer ambient halo
      BoxShadow(
        color: color.withOpacity(0.28 * glowIntensity),
        blurRadius: 32,
        spreadRadius: -4,
        offset: const Offset(0, 6),
      ),
      // Wide diffuse glow
      BoxShadow(
        color: color.withOpacity(0.12 * glowIntensity),
        blurRadius: 60,
        spreadRadius: -2,
        offset: const Offset(0, 10),
      ),
    ];

    // ── Fill / decoration ─────────────────────────────────────────────────
    BoxDecoration decoration;
    switch (variant) {
      case NeonButtonVariant.filled:
        decoration = BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            colors: [
              color,
              Color.lerp(color, AppTheme.primaryDark, 0.50)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: shadows,
        );
      case NeonButtonVariant.outlined:
        decoration = BoxDecoration(
          borderRadius: radius,
          color: color.withOpacity(0.08),
          border: Border.all(color: color, width: 1.5),
          boxShadow: shadows,
        );
      case NeonButtonVariant.ghost:
        decoration = BoxDecoration(
          borderRadius: radius,
          color: Colors.transparent,
          boxShadow: const [],
        );
    }

    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: radius,
        child: child,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.fgColor,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final Color fgColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: fgColor,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NeonIconButton — Compact circular icon-only variant
// ─────────────────────────────────────────────────────────────────────────────

/// A circular icon button with the same neon-glow press animation.
///
/// ```dart
/// NeonIconButton(
///   icon: Icons.add_rounded,
///   onTap: () {},
/// )
/// ```
class NeonIconButton extends StatefulWidget {
  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppTheme.primary,
    this.size = 50.0,
    this.iconSize = 22.0,
    this.variant = NeonButtonVariant.outlined,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;
  final double iconSize;
  final NeonButtonVariant variant;

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
        CurvedAnimation(parent: _ctrl,
            curve: Curves.easeOut, reverseCurve: Curves.elasticOut));
    _glow = Tween<double>(begin: 1.0, end: 0.20).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    _ctrl.forward();
    HapticFeedback.lightImpact();
  }

  void _up(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTapDown: _down,
          onTapUp: _up,
          onTapCancel: _cancel,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.variant == NeonButtonVariant.filled
                  ? widget.color
                  : widget.color.withOpacity(0.10),
              border: widget.variant != NeonButtonVariant.ghost
                  ? Border.all(color: widget.color.withOpacity(0.50), width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.45 * _glow.value),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: widget.color.withOpacity(0.18 * _glow.value),
                  blurRadius: 36,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: widget.variant == NeonButtonVariant.filled
                  ? AppTheme.bgDark
                  : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NeonTextButton — Minimal inline text link with glow underline
// ─────────────────────────────────────────────────────────────────────────────

/// A text-only button that animates a glowing underline on press.
///
/// ```dart
/// NeonTextButton(label: 'Sign In', onTap: () {})
/// ```
class NeonTextButton extends StatefulWidget {
  const NeonTextButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  State<NeonTextButton> createState() => _NeonTextButtonState();
}

class _NeonTextButtonState extends State<NeonTextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp: (_)   { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 1.5,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_opacity.value),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6 * _opacity.value),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
