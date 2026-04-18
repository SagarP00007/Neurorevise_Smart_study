import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/core/widgets/glow_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ParallaxBackground — Scroll-locked background that drifts at a slower rate
// ─────────────────────────────────────────────────────────────────────────────

/// A background layer that moves at [factor] times the scroll speed,
/// creating a natural depth illusion as the foreground scrolls past.
///
/// **How it works:**
/// Uses [GlobalKey] + [RenderObject.localToGlobal] to measure the widget's
/// current position in the viewport on every frame, then translates the
/// background by `offset * (1 - factor)` so it moves proportionally slower.
///
/// [factor] range:
///   • `0.0` — completely fixed (infinite depth)
///   • `0.5` — moves at half the scroll speed (standard parallax)
///   • `1.0` — no parallax (moves with content)
///
/// ```dart
/// // Inside a ListView or CustomScrollView:
/// SizedBox(
///   height: 260,
///   child: ParallaxBackground(
///     factor: 0.45,
///     child: GlowBackground(),
///   ),
/// )
/// ```
class ParallaxBackground extends StatefulWidget {
  const ParallaxBackground({
    super.key,
    required this.child,
    this.factor = 0.45,
    this.height = 260.0,
    this.clipOverflow = true,
  });

  final Widget child;

  /// Scroll-speed fraction for the background. Lower = more parallax.
  final double factor;

  /// Intrinsic height of the card / section this sits inside.
  final double height;

  /// Clip content that moves outside the card bounds.
  final bool clipOverflow;

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  final _bgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // We need a ScrollNotification ancestor — use Flow to recompute on scroll.
    return SizedBox(
      height: widget.height,
      child: ClipRect(
        clipBehavior:
            widget.clipOverflow ? Clip.hardEdge : Clip.none,
        child: Flow(
          delegate: _ParallaxFlowDelegate(
            scrollable: Scrollable.of(context),
            listItemContext: context,
            backgroundImageKey: _bgKey,
            factor: widget.factor,
            height: widget.height,
          ),
          children: [
            SizedBox(
              key: _bgKey,
              // Make the background taller than the card so there's room to slide.
              height: widget.height * (1.0 + (1.0 - widget.factor) * 0.8),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ParallaxFlowDelegate — Repaints every scroll frame; zero-rebuild overhead
// ─────────────────────────────────────────────────────────────────────────────

class _ParallaxFlowDelegate extends FlowDelegate {
  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
    required this.factor,
    required this.height,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;
  final double factor;
  final double height;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox =
        scrollable.context.findRenderObject()! as RenderBox;
    final listItemBox =
        listItemContext.findRenderObject()! as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Fraction of how far the item has scrolled through the viewport (0→1)
    final viewportFraction = listItemOffset.dy / scrollableBox.size.height;

    // Background travel range: bgHeight - cardHeight
    final bgBox =
        backgroundImageKey.currentContext?.findRenderObject() as RenderBox?;
    if (bgBox == null) return;
    final bgHeight  = bgBox.size.height;
    final travelRange = bgHeight - height;

    // Map the viewport fraction to a vertical offset within travelRange
    final bgOffset = (viewportFraction * travelRange * (1 - factor))
        .clamp(-travelRange, 0.0);

    context.paintChild(0,
        transform: Matrix4.translationValues(0, bgOffset, 0));
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate old) =>
      scrollable != old.scrollable ||
      listItemContext != old.listItemContext ||
      backgroundImageKey != old.backgroundImageKey ||
      factor != old.factor;
}

// ─────────────────────────────────────────────────────────────────────────────
// ParallaxCard — Complete glass card with built-in parallax background
// ─────────────────────────────────────────────────────────────────────────────

/// A self-contained card where the background image/gradient drifts at
/// a slower speed than the cards around it as the user scrolls.
///
/// ```dart
/// ParallaxCard(
///   height: 200,
///   background: Image.network(url, fit: BoxFit.cover),
///   child: CardContent(),
/// )
/// ```
class ParallaxCard extends StatelessWidget {
  const ParallaxCard({
    super.key,
    required this.background,
    required this.child,
    this.height = 200.0,
    this.factor = 0.40,
    this.borderRadius = AppTheme.radiusL,
    this.overlayGradient,
  });

  /// The layer that drifts (image, gradient, or [GlowBackground]).
  final Widget background;

  /// Content rendered on top of the parallax background.
  final Widget child;

  final double height;
  final double factor;
  final double borderRadius;

  /// Optional gradient overlay between background and content.
  /// Defaults to a bottom-heavy dark scrim for text legibility.
  final Gradient? overlayGradient;

  @override
  Widget build(BuildContext context) {
    final overlay = overlayGradient ??
        LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.bgDark.withOpacity(0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.3, 1.0],
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // ── Parallax background ─────────────────────────────────────────
          ParallaxBackground(
            factor: factor,
            height: height,
            child: background,
          ),

          // ── Gradient overlay for legibility ─────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: overlay),
            ),
          ),

          // ── Foreground content (scrolls at 1× — normal speed) ────────────
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ParallaxHeader — Full-width hero header at the top of a scroll view
// ─────────────────────────────────────────────────────────────────────────────

/// A [SliverAppBar]-style parallax hero for [CustomScrollView] pages.
///
/// The [GlowBackground] (or any widget) drifts upward as content scrolls.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     ParallaxHeader(title: 'Today Revision', height: 280),
///     SliverList(...),
///   ],
/// )
/// ```
class ParallaxHeader extends StatelessWidget {
  const ParallaxHeader({
    super.key,
    this.title,
    this.subtitle,
    this.background,
    this.height = 260.0,
    this.factor = 0.55,
    this.child,
  });

  final String? title;
  final String? subtitle;
  final Widget? background;
  final double height;
  final double factor;

  /// Override the entire content area.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: ParallaxCard(
        height: height,
        factor: factor,
        background: background ?? const GlowBackground(),
        borderRadius: 0,    // full-width header has no radius
        overlayGradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.bgDark.withOpacity(0.92),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.2, 1.0],
        ),
        child: child ??
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    if (title != null) ...[
                      const SizedBox(height: 4),
                      Text(title!, style: theme.textTheme.displaySmall),
                    ],
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ParallaxListItem — Convenience wrapper for list cards with parallax bg
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps a list-row in a [ParallaxCard] with a subtle neon gradient background.
///
/// Drop this into any [ListView] or [SliverList] for instant parallax rows.
///
/// ```dart
/// ListView.builder(
///   itemBuilder: (ctx, i) => ParallaxListItem(
///     accentColor: subjects[i].color,
///     height: 120,
///     child: SubjectCardBody(subjects[i]),
///   ),
/// )
/// ```
class ParallaxListItem extends StatelessWidget {
  const ParallaxListItem({
    super.key,
    required this.child,
    this.accentColor = AppTheme.primary,
    this.height = 120.0,
    this.factor = 0.35,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
  });

  final Widget child;
  final Color accentColor;
  final double height;
  final double factor;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ParallaxCard(
        height: height,
        factor: factor,
        background: _NeonGradientBackground(color: accentColor),
        overlayGradient: LinearGradient(
          colors: [
            AppTheme.cardDark.withOpacity(0.55),
            AppTheme.cardDark.withOpacity(0.90),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        child: child,
      ),
    );
  }
}

/// Simple neon radial gradient used as a parallex background in list items.
class _NeonGradientBackground extends StatelessWidget {
  const _NeonGradientBackground({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.5),
          radius: 1.2,
          colors: [
            color.withOpacity(0.25),
            AppTheme.cardDark,
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
