import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/constants/app_constants.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/features/study_items/domain/entities/revision_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/domain/logic/sm2_algorithm.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/revision_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';

/// Full-screen flash-card review session for today's due revisions.
///
/// Uses a [StreamBuilder] to watch due revisions in real time.  Each card
/// is answered by swiping or tapping a quality button (0–5 → SM-2).
/// After the last card the screen shows a completion celebration.
class TodayRevisionView extends StatefulWidget {
  const TodayRevisionView({super.key});

  static const routeName = '/revision/today';

  @override
  State<TodayRevisionView> createState() => _TodayRevisionViewState();
}

class _TodayRevisionViewState extends State<TodayRevisionView> {
  // Index of the card currently being reviewed.
  int _currentIndex = 0;

  // Whether the back (answer) side of the current card is showing.
  bool _flipped = false;

  // Remember which revision IDs have been completed during this session so
  // the stream doesn't re-inject them once the batch write propagates.
  final Set<String> _completedIds = {};

  @override
  Widget build(BuildContext context) {
    final revVm = context.watch<RevisionViewModel>();
    final studyVm = context.watch<StudyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Revisions'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RevisionEntity>>(
        stream: revVm.watchDueRevisions(),
        builder: (context, snapshot) {
          // ── Loading ───────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ─────────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return _ErrorBody(message: snapshot.error.toString());
          }

          // Filter out already-completed ones from this session
          final all = snapshot.data ?? [];
          final pending = all
              .where((r) => !_completedIds.contains(r.id))
              .toList();

          // ── Empty / Done ──────────────────────────────────────────────────
          if (pending.isEmpty) {
            return const _AllDoneBody();
          }

          // Reset index if it overflows (e.g. stream removed items)
          if (_currentIndex >= pending.length) {
            _currentIndex = pending.length - 1;
          }

          final revision = pending[_currentIndex];

          // Look up the matching study item from the ViewModel cache
          StudyItemEntity? item;
          try {
            item = studyVm.currentDeckItems.firstWhere(
                (i) => i.id == revision.itemId);
          } catch (_) {} // not in cache yet — handled below

          return Column(
            children: [
              // ── Progress bar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${pending.length}',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / pending.length,
                          minHeight: 6,
                          backgroundColor:
                              AppTheme.primary.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Flash card ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: GestureDetector(
                    onTap: () => setState(() => _flipped = !_flipped),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _FlashCard(
                        key: ValueKey('$_currentIndex-$_flipped'),
                        item: item,
                        revision: revision,
                        showAnswer: _flipped,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Action area ─────────────────────────────────────────────
              if (!_flipped) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 0, 20, AppConstants.paddingXL),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _flipped = true),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Reveal Answer'),
                    ),
                  ),
                ),
              ] else ...[
                _QualityButtons(
                  isLoading: revVm.isCompleting,
                  onQuality: item == null
                      ? null
                      : (rating) => _onQualitySelected(
                            context, revVm, revision, item!, rating),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Quality selection handler ──────────────────────────────────────────────

  Future<void> _onQualitySelected(
    BuildContext context,
    RevisionViewModel vm,
    RevisionEntity revision,
    StudyItemEntity item,
    PerformanceRating rating,
  ) async {
    final result = await vm.rateRevision(
      revision: revision,
      item: item,
      rating: rating,
    );

    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${result.error}'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Mark done locally so it doesn't re-appear instantly
    _completedIds.add(revision.id);

    setState(() {
      _flipped = false;
      if (_currentIndex < 1000) _currentIndex++;
    });
  }
}

// ── Flash Card ────────────────────────────────────────────────────────────────

class _FlashCard extends StatelessWidget {
  const _FlashCard({
    super.key,
    required this.item,
    required this.revision,
    required this.showAnswer,
  });

  final StudyItemEntity? item;
  final RevisionEntity revision;
  final bool showAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tag row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                showAnswer ? 'Answer' : 'Question',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (item == null)
              const CircularProgressIndicator()
            else
              Text(
                showAnswer ? item!.back : item!.front,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge
                    ?.copyWith(height: 1.4),
              ),
            if (showAnswer && item != null && item!.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 6,
                children: item!.tags
                    .map((t) => Chip(
                          label: Text('#$t'),
                          labelStyle: const TextStyle(fontSize: 11),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            if (!showAnswer)
              Text(
                'Tap to reveal answer',
                style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withOpacity(0.35)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Quality Buttons ───────────────────────────────────────────────────────────

class _QualityButtons extends StatelessWidget {
  const _QualityButtons({required this.onQuality, required this.isLoading});

  final void Function(PerformanceRating rating)? onQuality;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text('How well did you recall it?',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5))),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: PerformanceRating.values.map((rating) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _QualityButton(
                      rating: rating,
                      onTap: onQuality == null ? null : () => onQuality!(rating),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _QualityButton extends StatelessWidget {
  const _QualityButton({
    required this.rating,
    required this.onTap,
  });

  final PerformanceRating rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(rating.colorValue);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(rating.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(rating.label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


// ── All Done ──────────────────────────────────────────────────────────────────

class _AllDoneBody extends StatelessWidget {
  const _AllDoneBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            Text('All caught up!',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'You have no revisions due today.\nCome back tomorrow to keep your streak going!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Could not load revisions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
