import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/constants/app_constants.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';

/// Renders a real-time, Firestore-backed list of [StudyItemEntity] cards for
/// a given [deckId].
///
/// Internally uses [StreamBuilder] wired to [StudyViewModel.watchItems].
/// Handles all four stream states:
///   1. Loading  → shimmer skeleton rows
///   2. Empty    → empty-state illustration
///   3. Data     → animated card list
///   4. Error    → inline error with retry suggestion
class StudyItemsStreamView extends StatelessWidget {
  const StudyItemsStreamView({
    super.key,
    required this.deckId,
    required this.accentColor,
  });

  final String deckId;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudyViewModel>();

    return StreamBuilder<List<StudyItemEntity>>(
      stream: vm.watchItems(deckId),
      builder: (context, snapshot) {
        // ── Loading state ────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const _ShimmerCard(),
              childCount: 5,
            ),
          );
        }

        // ── Error state ──────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorState(
              message: snapshot.error.toString(),
              color: accentColor,
            ),
          );
        }

        final items = snapshot.data ?? [];

        // ── Empty state ──────────────────────────────────────────────────────
        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(color: accentColor),
          );
        }

        // ── Data: animated card list ─────────────────────────────────────────
        return SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return _AnimatedItemCard(
                  key: ValueKey(item.id),
                  item: item,
                  index: index,
                  accentColor: accentColor,
                );
              },
              childCount: items.length,
            ),
          ),
        );
      },
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _AnimatedItemCard extends StatefulWidget {
  const _AnimatedItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.accentColor,
  });

  final StudyItemEntity item;
  final int index;
  final Color accentColor;

  @override
  State<_AnimatedItemCard> createState() => _AnimatedItemCardState();
}

class _AnimatedItemCardState extends State<_AnimatedItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger cards: each card starts 40 ms later than the previous one.
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: _StudyItemCard(
            item: widget.item,
            accentColor: widget.accentColor,
          ),
        ),
      ),
    );
  }
}

class _StudyItemCard extends StatelessWidget {
  const _StudyItemCard({required this.item, required this.accentColor});

  final StudyItemEntity item;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isDue = !item.nextReviewDate.isAfter(now);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        side: BorderSide(
          color: isDue
              ? accentColor.withOpacity(0.4)
              : theme.colorScheme.outline.withOpacity(0.15),
          width: isDue ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Front (question) ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 36,
                  margin: const EdgeInsets.only(right: AppConstants.paddingS),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.front,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isDue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      'Due',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            // ── Divider ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingS),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline.withOpacity(0.15),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),

            // ── Back (answer) ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.back,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.65)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Tags ─────────────────────────────────────────────────────
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingS),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.tags
                    .map((t) => _TagBadge(label: t, color: accentColor))
                    .toList(),
              ),
            ],

            // ── Stats row ─────────────────────────────────────────────────
            const SizedBox(height: AppConstants.paddingS),
            Row(
              children: [
                _StatBadge(
                  icon: Icons.repeat_rounded,
                  label: '${item.repetitions} reps',
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: AppConstants.paddingS),
                _StatBadge(
                  icon: Icons.schedule_rounded,
                  label: _dueLabel(item.nextReviewDate),
                  color: isDue
                      ? accentColor
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dueLabel(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative || diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays}d';
  }
}

// ── Supporting micro-widgets ──────────────────────────────────────────────────

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingM,
          0,
          AppConstants.paddingM,
          AppConstants.paddingM,
        ),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Color.lerp(base, base.withOpacity(0.4), _anim.value),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerLine(width: 200, height: 12, base: base),
              const SizedBox(height: 8),
              _ShimmerLine(width: double.infinity, height: 10, base: base),
              const SizedBox(height: 16),
              _ShimmerLine(width: 140, height: 10, base: base),
              const SizedBox(height: 6),
              _ShimmerLine(width: double.infinity, height: 9, base: base),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine(
      {required this.width, required this.height, required this.base});
  final double width;
  final double height;
  final Color base;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.style_outlined, size: 36, color: color),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'No flashcards yet',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'Tap "Add Card" to create your first flashcard\nand start learning.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'Could not load flashcards',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
