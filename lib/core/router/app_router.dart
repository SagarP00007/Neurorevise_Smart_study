import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:study_smart/core/router/app_transitions.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/auth/presentation/views/login_view.dart';
import 'package:study_smart/features/auth/presentation/views/register_view.dart';
import 'package:study_smart/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:study_smart/features/study_items/presentation/views/flashcards_view.dart';
import 'package:study_smart/features/study_items/presentation/views/deck_detail_view.dart';
import 'package:study_smart/features/study_items/presentation/views/today_revision_view.dart';
import 'package:study_smart/features/notes/presentation/views/notes_view.dart';
import 'package:study_smart/features/planner/presentation/views/planner_view.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/core/widgets/app_shell.dart';

class AppRouter {
  static GoRouter router(AuthViewModel authViewModel) => GoRouter(
        initialLocation: RouteNames.dashboard,
        debugLogDiagnostics: true,
        refreshListenable: authViewModel,
        redirect: (context, state) {
          final isAuthenticated = authViewModel.isAuthenticated;
          final isLoggingIn = state.uri.toString() == RouteNames.login ||
              state.uri.toString() == RouteNames.register;

          if (!isAuthenticated) {
            return isLoggingIn ? null : RouteNames.login;
          }
          if (isLoggingIn) {
            return RouteNames.dashboard;
          }
          return null;
        },
        routes: [
          // ── Auth ──────────────────────────────────────────────────────────
          // slideRight: feels like entering a new area of the app.
          GoRoute(
            path: RouteNames.login,
            name: RouteNames.login,
            pageBuilder: (context, state) => AppTransitions.slideRight(
              pageKey: state.pageKey,
              child: const LoginView(),
            ),
          ),
          GoRoute(
            path: RouteNames.register,
            name: RouteNames.register,
            pageBuilder: (context, state) => AppTransitions.slideRight(
              pageKey: state.pageKey,
              child: const RegisterView(),
            ),
          ),

          // ── Full-screen modal routes (no bottom nav) ───────────────────────
          // slideUp: feels like a sheet rising from the content below.
          GoRoute(
            path: RouteNames.todayRevision,
            name: RouteNames.todayRevision,
            pageBuilder: (context, state) => AppTransitions.slideUp(
              pageKey: state.pageKey,
              child: const TodayRevisionView(),
            ),
          ),

          // ── Shell (bottom nav tabs) ────────────────────────────────────────
          // fadeScale: soft, ephemeral feel between same-level tabs.
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: RouteNames.dashboard,
                pageBuilder: (context, state) => AppTransitions.fadeScale(
                  pageKey: state.pageKey,
                  child: const DashboardView(),
                ),
              ),
              GoRoute(
                path: RouteNames.planner,
                name: RouteNames.planner,
                pageBuilder: (context, state) => AppTransitions.fadeScale(
                  pageKey: state.pageKey,
                  child: const PlannerView(),
                ),
              ),
              GoRoute(
                path: RouteNames.notes,
                name: RouteNames.notes,
                pageBuilder: (context, state) => AppTransitions.fadeScale(
                  pageKey: state.pageKey,
                  child: const NotesView(),
                ),
              ),
              GoRoute(
                path: RouteNames.flashcards,
                name: RouteNames.flashcards,
                pageBuilder: (context, state) => AppTransitions.fadeScale(
                  pageKey: state.pageKey,
                  child: const FlashcardsView(),
                ),
              ),
              // slideUp: drilling into a deck feels like zooming into a card.
              GoRoute(
                path: RouteNames.deckDetail,
                name: RouteNames.deckDetail,
                pageBuilder: (context, state) => AppTransitions.slideUp(
                  pageKey: state.pageKey,
                  child: DeckDetailView(
                    deckId: state.pathParameters['deckId']!,
                    deck: state.extra as DeckEntity?,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}
