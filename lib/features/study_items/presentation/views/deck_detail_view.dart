import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/widgets/add_study_item_sheet.dart';
import 'package:study_smart/features/study_items/presentation/widgets/study_items_stream_view.dart';


class DeckDetailView extends StatefulWidget {
  final String deckId;
  final DeckEntity? deck;

  const DeckDetailView({super.key, required this.deckId, this.deck});

  @override
  State<DeckDetailView> createState() => _DeckDetailViewState();
}

class _DeckDetailViewState extends State<DeckDetailView> {
  @override
  void initState() {
    super.initState();
    // Stream subscription starts in StudyItemsStreamView — no manual fetch needed.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<StudyViewModel>();
    
    // Fallback if deck entity wasn't passed in extra (from deep link)
    final deck = widget.deck ?? vm.decks.firstWhere((d) => d.id == widget.deckId, orElse: () => DeckEntity(
      id: widget.deckId,
      userId: '',
      title: 'Deck Detail',
      subject: '',
      colorValue: AppTheme.primary.value,
      itemCount: 0,
      createdAt: DateTime.now(),
    ));

    final color = Color(deck.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, deck),
          ),
        ],
      ),
      body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _DeckHeader(deck: deck, color: color),
                  ),
                ),
                StudyItemsStreamView(
                  deckId: widget.deckId,
                  accentColor: color,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddStudyItemSheet.show(context, deck: deck),
        backgroundColor: color,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Card',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DeckEntity deck) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${deck.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final vm = context.read<StudyViewModel>();
              await vm.removeDeck(deck.id);
              if (context.mounted) {
                Navigator.pop(ctx); // Close dialog
                context.pop(); // Go back to deck list
              }
            },
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


}

class _DeckHeader extends StatelessWidget {
  final DeckEntity deck;
  final Color color;
  const _DeckHeader({required this.deck, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Total Cards', value: '${deck.itemCount}'),
              _StatItem(label: 'Ready for Review', value: '0'),
              _StatItem(label: 'Mastered', value: '0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

