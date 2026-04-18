import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final _notes = <_Note>[
    _Note(title: 'Binary Search Trees', subject: 'CS', preview: 'A BST is a tree data structure in which each node has at most two children...', color: AppTheme.primary),
    _Note(title: 'Integration by Parts', subject: 'Math', preview: '∫u dv = uv − ∫v du. Use LIATE to choose u: Log, Inverse, Algebraic...', color: AppTheme.secondary),
    _Note(title: 'Krebs Cycle', subject: 'Biology', preview: 'The citric acid cycle produces 2 ATP, 6 NADH, 2 FADH2 per glucose molecule...', color: AppTheme.warning),
    _Note(title: 'Organic Chemistry Reactions', subject: 'Chemistry', preview: 'SN1 reactions proceed via carbocation intermediate, rates depend on substrate...', color: AppTheme.error),
  ];

  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _notes
        .where((n) => n.title.toLowerCase().contains(_search.toLowerCase()) ||
            n.subject.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No notes found',
                        style: theme.textTheme.bodyMedium),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _NoteCard(note: filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Note',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Note {
  final String title;
  final String subject;
  final String preview;
  final Color color;
  _Note({required this.title, required this.subject, required this.preview, required this.color});
}

class _NoteCard extends StatelessWidget {
  final _Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: note.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.subject,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: note.color, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Text(note.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.preview,
                  style: theme.textTheme.bodySmall,
                  maxLines: 4,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text('Today', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
