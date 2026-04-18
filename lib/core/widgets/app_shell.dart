import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.planner)) return 1;
    if (location.startsWith(RouteNames.notes)) return 2;
    if (location.startsWith(RouteNames.flashcards)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go(RouteNames.dashboard);
            case 1:
              context.go(RouteNames.planner);
            case 2:
              context.go(RouteNames.notes);
            case 3:
              context.go(RouteNames.flashcards);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.notes_outlined),
            selectedIcon: Icon(Icons.notes_rounded),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded),
            label: 'Cards',
          ),
        ],
        indicatorColor: AppTheme.primary.withOpacity(0.2),
      ),
    );
  }
}
