import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SubjectCard — Futuristic glassmorphism subject card
// ─────────────────────────────────────────────────────────────────────────────

/// Data model for a single subject card entry.
class SubjectCardData {
  const SubjectCardData({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.progress = 0.0,     // 0.0–1.0
    this.cardCount = 0,
    this.color = AppTheme.primary,
    this.tag,
  });

  final String id;
  final String title;
  final IconData icon;
  final String? subtitle;
  final double progress;
  final int cardCount;
  final Color color;
  final String? tag;         // e.g. "New", "Due", "Done"
}

/// A fully animated glassmorphism card for a single subject / deck.
///
/// Features:
///  • Frosted-glass body with backdrop blur
///  • Coloured icon badge with inner glow
///  • Progress bar that fills with [data.progress]
///  • Neon glow border on selection, driven by an [AnimationController]
///  • Spring-scale press animation
///  • Arrow action button that navigates / triggers [onActionTap]
///
/// ```dart
/// SubjectCard(
///   data: SubjectCardData(
///     id: '1', title: 'Physics', icon: Icons.science_rounded,
///     progress: 0.62, cardCount: 47, color: AppTheme.secondary,
///   ),
///   onTap: () {},
///   onActionTap: () {},
/// )
/// ```
class SubjectCard extends StatefulWidget {
  const SubjectCard({
    super.key,
    required this.data,
    this.onTap,
    this.onActionTap,
    this.isSelected = false,
  });

  final SubjectCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final bool isSelected;

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;
  late final Animation<double> _border;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _scale  = Tween<double>(begin: 1.0, end: 0.965).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut,
            reverseCurve: Curves.elasticOut));
    _glow   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _border = Tween<double>(begin: widget.isSelected ? 1.0 : 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(SubjectCard old) {
    super.didUpdateWidget(old);
    // Animate selection border change from parent
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _ctrl.animateTo(1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      } else {
        _ctrl.animateBack(0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _ctrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.data.color;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final glowVal   = widget.isSelected ? 1.0 : _glow.value;
        final borderVal = widget.isSelected ? 1.0 : _glow.value;

        return Transform.scale(
          scale: widget.isSelected ? 1.0 : _scale.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: _CardShell(
              color: color,
              glowVal: glowVal,
              borderVal: borderVal,
              isSelected: widget.isSelected,
              child: _CardBody(
                data: widget.data,
                onActionTap: widget.onActionTap,
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

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.color,
    required this.glowVal,
    required this.borderVal,
    required this.isSelected,
    required this.child,
  });

  final Color color;
  final double glowVal;
  final double borderVal;
  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppTheme.radiusL));

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // Inner tight glow
          BoxShadow(
            color: color.withOpacity(0.22 * glowVal),
            blurRadius: 16,
            spreadRadius: -2,
          ),
          // Wide ambient halo
          BoxShadow(
            color: color.withOpacity(0.12 * glowVal),
            blurRadius: 36,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: isSelected
                  ? color.withOpacity(0.10)
                  : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: color.withOpacity(
                    0.12 + 0.30 * borderVal),   // 0.12 idle → 0.42 selected
                width: 1.3,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.data, this.onActionTap});

  final SubjectCardData data;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = data.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: Icon + text + action ──────────────────────────────────
          Row(
            children: [
              // Icon badge
              _IconBadge(icon: data.icon, color: color),
              const SizedBox(width: 14),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: theme.textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (data.tag != null)
                          _TagBadge(label: data.tag!, color: color),
                      ],
                    ),
                    if (data.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        data.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${data.cardCount} card${data.cardCount == 1 ? '' : 's'}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: color.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action arrow button
              _ActionButton(color: color, onTap: onActionTap),
            ],
          ),

          const SizedBox(height: 14),

          // ── Row 2: Progress bar ───────────────────────────────────────────
          _ProgressBar(progress: data.progress, color: color),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.20),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.color, this.onTap});

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.30), width: 1.2),
        ),
        child: Icon(Icons.arrow_forward_rounded, color: color, size: 16),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppTheme.textSecondary)),
            Text('$pct%',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: [
              // Track
              Container(
                height: 5,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: AppTheme.borderDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: 5,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.white, 0.25)!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.55),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SubjectCardList — Full list implementation with selection state
// ─────────────────────────────────────────────────────────────────────────────

/// A scrollable list of [SubjectCard] widgets with built-in single-selection
/// state, section header, and an animated "Add Subject" footer button.
///
/// ```dart
/// SubjectCardList(
///   subjects: mySubjects,
///   onSubjectTap: (data) => context.push('/deck/${data.id}'),
/// )
/// ```
class SubjectCardList extends StatefulWidget {
  const SubjectCardList({
    super.key,
    required this.subjects,
    this.onSubjectTap,
    this.onSubjectAction,
    this.onAddTap,
    this.title = 'My Subjects',
    this.physics = const BouncingScrollPhysics(),
    this.shrinkWrap = false,
    this.padding,
  });

  final List<SubjectCardData> subjects;
  final void Function(SubjectCardData data)? onSubjectTap;
  final void Function(SubjectCardData data)? onSubjectAction;
  final VoidCallback? onAddTap;
  final String title;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  @override
  State<SubjectCardList> createState() => _SubjectCardListState();
}

class _SubjectCardListState extends State<SubjectCardList> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // ── Section header ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: theme.textTheme.headlineSmall),
            _HeaderBadge(count: widget.subjects.length),
          ],
        ),
        const SizedBox(height: 16),

        // ── Cards ───────────────────────────────────────────────────────────
        ...widget.subjects.asMap().entries.map((entry) {
          final i    = entry.key;
          final data = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // Staggered fade-slide entrance
            child: _StaggeredEntrance(
              index: i,
              child: SubjectCard(
                key: ValueKey(data.id),
                data: data,
                isSelected: _selectedId == data.id,
                onTap: () {
                  setState(() => _selectedId =
                      _selectedId == data.id ? null : data.id);
                  widget.onSubjectTap?.call(data);
                },
                onActionTap: () => widget.onSubjectAction?.call(data),
              ),
            ),
          );
        }),

        // ── Add button ──────────────────────────────────────────────────────
        if (widget.onAddTap != null) ...[
          const SizedBox(height: 4),
          _AddSubjectButton(onTap: widget.onAddTap!),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Stacked count badge shown next to the list section header.
class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
            color: AppTheme.primary.withOpacity(0.25), width: 1),
      ),
      child: Text(
        '$count total',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Dashed-border "Add Subject" button at the bottom of the list.
class _AddSubjectButton extends StatefulWidget {
  const _AddSubjectButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddSubjectButton> createState() => _AddSubjectButtonState();
}

class _AddSubjectButtonState extends State<_AddSubjectButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 350));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut,
            reverseCurve: Curves.elasticOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTapDown: (_) { _ctrl.forward(); HapticFeedback.lightImpact(); },
          onTapUp:   (_) { _ctrl.reverse(); widget.onTap(); },
          onTapCancel: () => _ctrl.reverse(),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.25),
                  width: 1.2,
                  style: BorderStyle.solid),
              color: AppTheme.primary.withOpacity(0.04),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text('Add Subject',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a child in a fade + slide entrance animation staggered by [index].
class _StaggeredEntrance extends StatefulWidget {
  const _StaggeredEntrance({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: each card starts 60ms after the previous
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
