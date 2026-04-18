import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlassCard — The core glassmorphism container
// ─────────────────────────────────────────────────────────────────────────────

/// A reusable glassmorphism card that sits on top of any background.
///
/// Combines [BackdropFilter] blur, a semi-transparent frosted fill,
/// and an optional neon glow border for a premium futuristic look.
///
/// **Must be placed inside a [Stack] that has a visual background** (e.g.
/// [GlowBackground]) for the blur effect to be visible.
///
/// ```dart
/// GlassCard(
///   child: Text('Hello'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = AppTheme.radiusL,
    // ── Blur ──────────────────────────────────────────────────────────────
    this.blur = 18.0,
    // ── Fill ──────────────────────────────────────────────────────────────
    this.fillColor,
    this.fillOpacity = 0.08,
    // ── Border ────────────────────────────────────────────────────────────
    this.borderColor,
    this.borderOpacity = 0.18,
    this.borderWidth = 1.2,
    // ── Glow ──────────────────────────────────────────────────────────────
    this.glowColor,
    this.glowOpacity = 0.0,    // 0 = no glow, > 0 enables box-shadow glow
    this.glowRadius = 24.0,
    // ── Layout ────────────────────────────────────────────────────────────
    this.width,
    this.height,
    this.margin,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  final double blur;

  final Color? fillColor;
  final double fillOpacity;

  final Color? borderColor;
  final double borderOpacity;
  final double borderWidth;

  final Color? glowColor;
  final double glowOpacity;
  final double glowRadius;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final fill   = (fillColor   ?? Colors.white).withOpacity(fillOpacity);
    final border = (borderColor ?? AppTheme.primary).withOpacity(borderOpacity);
    final glow   = (glowColor   ?? AppTheme.primary).withOpacity(glowOpacity);
    final radius = BorderRadius.circular(borderRadius);

    Widget card = ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width:  width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border, width: borderWidth),
            boxShadow: glowOpacity > 0
                ? [
                    BoxShadow(
                      color: glow,
                      blurRadius: glowRadius,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Named presets — convenience constructors for common use cases
// ─────────────────────────────────────────────────────────────────────────────

/// [GlassCard] with a soft neon-blue glow border — great for feature cards.
class GlassCardGlowing extends StatelessWidget {
  const GlassCardGlowing({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.glowColor = AppTheme.primary,
    this.onTap,
    this.width,
    this.height,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color glowColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      blur: 24,
      fillOpacity: 0.10,
      borderColor: glowColor,
      borderOpacity: 0.35,
      borderWidth: 1.5,
      glowColor: glowColor,
      glowOpacity: 0.22,
      glowRadius: 28,
      onTap: onTap,
      width: width,
      height: height,
      margin: margin,
      child: child,
    );
  }
}

/// Minimal, barely-there glass — for subtle overlays (tooltips, tags).
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppTheme.primary,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: AppTheme.radiusXL,
      blur: 10,
      fillColor: color,
      fillOpacity: 0.12,
      borderColor: color,
      borderOpacity: 0.30,
      glowColor: color,
      glowOpacity: 0.10,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Glass bottom sheet header handle bar.
class GlassSheetHandle extends StatelessWidget {
  const GlassSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: AppTheme.radiusXL,
        blur: 8,
        fillOpacity: 0.15,
        borderOpacity: 0.12,
        width: 40,
        height: 4,
        child: const SizedBox(),
      ),
    );
  }
}

/// Full-screen frosted glass overlay — use as modal/dialog backdrop.
class GlassOverlay extends StatelessWidget {
  const GlassOverlay({
    super.key,
    required this.child,
    this.blur = 12,
    this.color = Colors.black,
    this.opacity = 0.45,
  });

  final Widget child;
  final double blur;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: ColoredBox(
        color: color.withOpacity(opacity),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassStatCard — ready-made stat tile used on the Dashboard
// ─────────────────────────────────────────────────────────────────────────────

/// A compact stat card with an accent icon, label, and value.
///
/// ```dart
/// GlassStatCard(
///   icon: Icons.local_fire_department_rounded,
///   label: 'Day Streak',
///   value: '7',
///   accentColor: AppTheme.warning,
/// )
/// ```
class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor = AppTheme.primary,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        blur: 20,
        fillColor: accentColor,
        fillOpacity: 0.07,
        borderColor: accentColor,
        borderOpacity: 0.22,
        glowColor: accentColor,
        glowOpacity: 0.12,
        glowRadius: 20,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
