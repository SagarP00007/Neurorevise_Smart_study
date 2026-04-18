import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/revision_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVm = context.watch<AuthViewModel>();
    final studyVm = context.watch<StudyViewModel>();
    final revVm = context.watch<RevisionViewModel>();
    final user = authVm.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Student';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning, $firstName! 👋',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            )),
                        const SizedBox(height: 4),
                        Text('Study Smart',
                            style: theme.textTheme.displaySmall),
                      ],
                    ),
                    PopupMenuButton<int>(
                      tooltip: 'Profile options',
                      onSelected: (i) {
                        if (i == 1) authVm.signOut();
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(user?.email ?? 'Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded,
                                  size: 20, color: theme.colorScheme.error),
                              const SizedBox(width: 8),
                              Text('Logout',
                                  style: TextStyle(
                                      color: theme.colorScheme.error)),
                            ],
                          ),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            AppTheme.primary.withOpacity(0.15),
                        child: user?.photoUrl != null
                            ? ClipOval(
                                child: Image.network(user!.photoUrl!,
                                    fit: BoxFit.cover))
                            : const Icon(Icons.person_rounded,
                                color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),


            // ── Stats Row ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Day Streak 🔥',
                      value: '7',
                      color: AppTheme.warning,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Mins Studied',
                      value: '142',
                      color: AppTheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Tasks Done',
                      value: '5/8',
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            // ── Progress Banner ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _ProgressBanner(theme: theme),
              ),
            ),

            // ── Due Revision Banner ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _DueRevisionBanner(revVm: revVm),
              ),
            ),

            // ── Today's Tasks ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text("Today's Tasks",
                    style: theme.textTheme.titleLarge),
              ),
            ),

            StreamBuilder(
              stream: studyVm.watchDueItemsAcrossDecks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Error loading tasks: ${snapshot.error}')),
                    ),
                  );
                }

                final dueItems = snapshot.data ?? [];

                if (dueItems.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('🎉', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text("All caught up for today!", 
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = dueItems[index];
                      // Find the deck name by matching ID, if loaded (otherwise fallback to generic 'Flashcard')
                      final deckTitle = studyVm.decks.firstWhere(
                        (d) => d.id == item.deckId, 
                        orElse: () => throw Exception('Not found')
                      ).title; // Safe catch below
                      
                      String displaySubject = 'Flashcard';
                      try {
                        displaySubject = studyVm.decks.firstWhere((d) => d.id == item.deckId).title;
                      } catch (_) {}

                      return _TaskTile(
                        key: ValueKey(item.id),
                        title: 'Review: ${item.front}',
                        subject: displaySubject,
                        isDone: false,
                      );
                    },
                    childCount: dueItems.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress Banner ───────────────────────────────────────────────────────────
class _ProgressBanner extends StatelessWidget {
  final ThemeData theme;
  const _ProgressBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Goal",
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text("10h studied of 15h goal",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 10 / 15,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text("67% complete — keep it up! 💪",
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

// ── Task Tile ─────────────────────────────────────────────────────────────────
class _TaskTile extends StatefulWidget {
  final String title;
  final String subject;
  final bool isDone;

  const _TaskTile({
    super.key,
    required this.title,
    required this.subject,
    required this.isDone,
  });

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  late bool _done;

  @override
  void initState() {
    super.initState();
    _done = widget.isDone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: () => setState(() => _done = !_done),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _done
                    ? AppTheme.secondary
                    : Colors.transparent,
                border: Border.all(
                  color: _done
                      ? AppTheme.secondary
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _done
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              decoration: _done ? TextDecoration.lineThrough : null,
              color: _done
                  ? theme.colorScheme.onSurface.withOpacity(0.4)
                  : null,
            ),
          ),
          subtitle: Text(widget.subject,
              style: theme.textTheme.bodySmall),
          trailing: const Icon(Icons.chevron_right_rounded, size: 18),
        ),
      ),
    );
  }
}

// ── Due Revision Banner ───────────────────────────────────────────────────────
/// Streams due revisions from Firestore and presents a tap-to-start card.
/// Shows nothing while loading and hides itself when there are 0 due items.
class _DueRevisionBanner extends StatelessWidget {
  const _DueRevisionBanner({required this.revVm});

  final RevisionViewModel revVm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder(
      stream: revVm.watchDueRevisions(),
      builder: (context, snapshot) {
        // Hide while waiting or on error
        if (!snapshot.hasData || snapshot.hasError) return const SizedBox.shrink();

        final count = snapshot.data!.length;
        if (count == 0) return const SizedBox.shrink(); // nothing due

        return GestureDetector(
          onTap: () => context.push(RouteNames.todayRevision),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondary,
                  AppTheme.secondary.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.style_outlined,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count card${count == 1 ? '' : 's'} due today',
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tap to start your revision session',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
