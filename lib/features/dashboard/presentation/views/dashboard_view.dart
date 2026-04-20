import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/core/widgets/animations.dart';
import 'package:study_smart/core/widgets/spirograph_ring.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/revision_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardView — Matches the Kommodo "Learn Now" reference design
// ─────────────────────────────────────────────────────────────────────────────

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const _subjects = [
    _SubjectData('Physics',  Icons.bolt_rounded,        AppTheme.primary,   'Revise last topic'),
    _SubjectData('Math',     Icons.calculate_rounded,    AppTheme.secondary, 'Explain a concept'),
    _SubjectData('Biology',  Icons.biotech_rounded,      Color(0xFF30D158),  'Practice questions'),
    _SubjectData('History',  Icons.history_edu_rounded,  AppTheme.amber,     'Learn from basics'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final authVm  = context.watch<AuthViewModel>();
    final studyVm = context.watch<StudyViewModel>();
    final revVm   = context.watch<RevisionViewModel>();
    final user    = authVm.currentUser;
    final name    = user?.displayName?.split(' ').first ?? 'Student';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Top bar ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello $name,',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text('Study Smart',
                              style: theme.textTheme.headlineLarge),
                        ],
                      ),
                    ),
                    // Avatar + settings
                    _AvatarMenu(authVm: authVm, user: user),
                  ],
                ),
              ),
            ),

            // ── AI Banner card ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeScaleIn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: StreamBuilder(
                    stream: revVm.watchDueRevisions(),
                    builder: (ctx, snap) {
                      final count = snap.data?.length ?? 0;
                      return _AiBanner(
                        dueCount: count,
                        onTap: () => context.go(RouteNames.todayRevision),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Stats row ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SlideIn(
                delay: const Duration(milliseconds: 80),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: StreamBuilder(
                    stream: revVm.watchDueRevisions(),
                    builder: (ctx, snap) {
                      final count = snap.data?.length ?? 0;
                      return Row(
                        children: [
                          _StatCard(
                            label: 'Due Today',
                            value: '$count',
                            icon: Icons.event_available_rounded,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: 'Decks',
                            value: '${studyVm.decks.length}',
                            icon: Icons.style_rounded,
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          const _StatCard(
                            label: 'Streak',
                            value: '7d',
                            icon: Icons.local_fire_department_rounded,
                            color: AppTheme.warning,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── "Learn Now" heading ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Learn Now',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Choose a topic and start learning smarter',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),

            // ── Subject rows ───────────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => SlideIn(
                  delay: Duration(milliseconds: 100 + i * 60),
                  child: _SubjectRow(data: _subjects[i]),
                ),
                childCount: _subjects.length,
              ),
            ),

            // ── AI Study Tip ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SlideIn(
                delay: const Duration(milliseconds: 380),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _AiTipCard(),
                ),
              ),
            ),

            // ── Study Modes heading ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Text('Study Modes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700)),
              ),
            ),

            // ── Study mode cards ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SlideIn(
                    delay: const Duration(milliseconds: 440),
                    child: _StudyModeCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Concept Explanation',
                      subtitle: 'Learn any topic step by step',
                      onTap: () => context.go(RouteNames.flashcards),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SlideIn(
                    delay: const Duration(milliseconds: 500),
                    child: _StudyModeCard(
                      icon: Icons.science_rounded,
                      title: 'Practice Questions',
                      subtitle: 'Test your knowledge with MCQs',
                      onTap: () => context.go(RouteNames.flashcards),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SlideIn(
                    delay: const Duration(milliseconds: 560),
                    child: _StudyModeCard(
                      icon: Icons.repeat_rounded,
                      title: 'Spaced Repetition',
                      subtitle: 'Revise at the perfect moment',
                      onTap: () => context.go(RouteNames.todayRevision),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({required this.authVm, required this.user});
  final AuthViewModel authVm;
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Profile',
      color: AppTheme.cardHighDark,
      onSelected: (i) { if (i == 1) authVm.signOut(); },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 0,
          child: Text(user?.email ?? 'Profile',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 1,
          child: Text('Logout',
              style: TextStyle(color: AppTheme.error)),
        ),
      ],
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary.withOpacity(0.15),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.35), width: 1.5),
        ),
        child: const Icon(Icons.person_rounded,
            color: AppTheme.primary, size: 20),
      ),
    );
  }
}

// AI banner with the spirograph ring
class _AiBanner extends StatelessWidget {
  const _AiBanner({required this.dueCount, required this.onTap});
  final int dueCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.borderDark),
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.08),
              AppTheme.cardDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Mini spirograph
            SpirographRing(
              size: 72,
              primaryColor: AppTheme.primary,
              secondaryColor: AppTheme.secondary,
              strands: 7,
              speedMs: 8000,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dueCount cards due today',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to start your revision session',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.15),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppTheme.primary, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color, fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// Subject row — matches right panel of reference
class _SubjectData {
  const _SubjectData(this.name, this.icon, this.color, this.action);
  final String name;
  final IconData icon;
  final Color color;
  final String action;
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.data});
  final _SubjectData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(
          children: [
            // Subject icon
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: data.color.withOpacity(0.25)),
              ),
              child: Icon(data.icon, color: data.color, size: 18),
            ),
            const SizedBox(width: 14),
            // Subject name
            Expanded(
              child: Text(data.name,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            // Action chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardHighDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(data.action,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.06),
            AppTheme.cardDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text('AI Study Tip',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tip of the day',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            '"Studying for 25 minutes with full focus improves memory retention."',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondary, fontStyle: FontStyle.italic, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StudyModeCard extends StatelessWidget {
  const _StudyModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded,
                color: AppTheme.secondary.withOpacity(0.6), size: 20),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded,
                color: AppTheme.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
