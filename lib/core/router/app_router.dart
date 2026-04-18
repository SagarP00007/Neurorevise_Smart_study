import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
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
            // Unauthenticated user -> send to Login if they aren't already there
            return isLoggingIn ? null : RouteNames.login;
          }

          if (isLoggingIn) {
            // Already logged in -> send to Dashboard if they try to access Auth pages
            return RouteNames.dashboard;
          }

          // Let them through
          return null;
        },
        routes: [
          // Auth
          GoRoute(
            path: RouteNames.login,
            name: RouteNames.login,
            builder: (context, state) => const LoginView(),
          ),
          GoRoute(
            path: RouteNames.register,
            name: RouteNames.register,
            builder: (context, state) => const RegisterView(),
          ),

          // Full-screen routes (no bottom nav)
          GoRoute(
            path: RouteNames.todayRevision,
            name: RouteNames.todayRevision,
            builder: (context, state) => const TodayRevisionView(),
          ),

          // Main shell with bottom nav
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: RouteNames.dashboard,
                builder: (context, state) => const DashboardView(),
              ),
              GoRoute(
                path: RouteNames.planner,
                name: RouteNames.planner,
                builder: (context, state) => const PlannerView(),
              ),
              GoRoute(
                path: RouteNames.notes,
                name: RouteNames.notes,
                builder: (context, state) => const NotesView(),
              ),
              GoRoute(
                path: RouteNames.flashcards,
                name: RouteNames.flashcards,
                builder: (context, state) => const FlashcardsView(),
              ),
              GoRoute(
                path: RouteNames.deckDetail,
                name: RouteNames.deckDetail,
                builder: (context, state) => DeckDetailView(
                  deckId: state.pathParameters['deckId']!,
                  deck: state.extra as DeckEntity?,
                ),
              ),
            ],
          ),
        ],
      );
}


