import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/constants/app_strings.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:uuid/uuid.dart';



class FlashcardsView extends StatefulWidget {
  const FlashcardsView({super.key});

  @override
  State<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<FlashcardsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<StudyViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: vm.isLoading && vm.decks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.loadDecks,
              child: vm.decks.isEmpty && !vm.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('No decks yet', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Create one to start studying!', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.decks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _DeckCard(
                        deck: vm.decks[i],
                        onStudy: () => _startStudy(context, vm.decks[i]),
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDeck(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Deck',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _startStudy(BuildContext context, DeckEntity deck) {
    // Navigate to study session (SM-2 logic)
  }

  void _showCreateDeck(BuildContext context) {
    final theme = Theme.of(context);
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    Color selectedColor = AppTheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Deck', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Deck Title (e.g. Algorithms)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(hintText: 'Subject (e.g. CS 101)'),
              ),
              const SizedBox(height: 20),
              Text('Select Color', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final color = _colors[i];
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    
                    final vm = context.read<StudyViewModel>();
                    final auth = context.read<AuthViewModel>();
                    
                    final newDeck = DeckEntity(
                      id: const Uuid().v4(),
                      userId: auth.currentUser?.uid ?? 'unknown',
                      title: titleCtrl.text.trim(),
                      subject: subjectCtrl.text.trim(),
                      colorValue: selectedColor.value,
                      itemCount: 0,
                      createdAt: DateTime.now(),
                    );
                    
                    await vm.createDeck(newDeck);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Create Deck'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<Color> _colors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.warning,
    AppTheme.error,
    Color(0xFF8E44AD),
    Color(0xFF2980B9),
    Color(0xFF27AE60),
    Color(0xFFD35400),
  ];
}


class _DeckCard extends StatelessWidget {
  final DeckEntity deck;
  final VoidCallback onStudy;
  const _DeckCard({required this.deck, required this.onStudy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(deck.colorValue);
    final progress = 0.0; // Wait for review logic

    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          RouteNames.deckDetail,
          pathParameters: {'deckId': deck.id},
          extra: deck,
        ),
        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.style_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deck.title, style: theme.textTheme.titleMedium),
                        Text(deck.subject, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onStudy,
                    style: TextButton.styleFrom(
                      backgroundColor: color.withOpacity(0.1),
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Study', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${deck.itemCount} cards', style: theme.textTheme.bodySmall),
                ],
              ),

              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── Flashcard Study Screen ─────────────────────────────────────────────────────
class _FlashcardStudyScreen extends StatefulWidget {
  final DeckEntity deck;
  const _FlashcardStudyScreen({required this.deck});


  @override
  State<_FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<_FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  final _cards = [
    {'front': 'What is a Binary Search Tree?', 'back': 'A BST is a tree where each node has at most 2 children and left < root < right.'},
    {'front': 'Time complexity of BST search?', 'back': 'O(log n) average case, O(n) worst case (unbalanced).'},
    {'front': 'What is a Hash Map?', 'back': 'A data structure that maps keys to values using a hash function for O(1) average access.'},
  ];

  int _index = 0;
  bool _isFlipped = false;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _next() {
    if (_index < _cards.length - 1) {
      setState(() {
        _index++;
        _isFlipped = false;
      });
      _ctrl.reset();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() {
        _index--;
        _isFlipped = false;
      });
      _ctrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = _cards[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_index + 1}/${_cards.length}',
                  style: theme.textTheme.titleMedium),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, child) {
                    final angle = _anim.value * 3.14159;
                    final isBack = angle > 1.5708;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isBack
                                ? [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)]
                                : [AppTheme.primary, AppTheme.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: (isBack ? AppTheme.secondary : AppTheme.primary).withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isBack ? 'ANSWER' : 'QUESTION',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(isBack ? 3.14159 : 0),
                              child: Text(
                                isBack ? card['back']! : card['front']!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Tap to flip',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavButton(icon: Icons.arrow_back_rounded, onTap: _prev, enabled: _index > 0),
                _NavButton(icon: Icons.close_rounded, onTap: () {}, color: AppTheme.error),
                _NavButton(icon: Icons.check_rounded, onTap: () {}, color: AppTheme.secondary),
                _NavButton(icon: Icons.arrow_forward_rounded, onTap: _next, enabled: _index < _cards.length - 1),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool enabled;

  const _NavButton({required this.icon, required this.onTap, this.color, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? c.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: enabled ? c.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
        ),
        child: Icon(icon, color: enabled ? c : Colors.grey, size: 22),
      ),
    );
  }
}
