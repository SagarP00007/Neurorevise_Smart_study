import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:study_smart/core/router/route_names.dart';
import 'package:study_smart/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShell — Production-grade bottom nav shell
//
// Changes from original:
//  • Custom frosted-glass nav bar (BackdropFilter) — not Material NavigationBar
//  • AnimatedContainer indicator glides between tabs
//  • Each tab icon animates scale on selection
//  • RepaintBoundary around nav bar prevents full repaints on scroll
//  • SystemChrome overlay matches bar transparency
// ─────────────────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  // One AnimationController per tab item for the icon scale bounce.
  late final List<AnimationController> _iconCtrls;
  late final List<Animation<double>> _iconScales;

  static const _tabs = [
    _TabItem(
      route: RouteNames.dashboard,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _TabItem(
      route: RouteNames.planner,
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Planner',
    ),
    _TabItem(
      route: RouteNames.notes,
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note_rounded,
      label: 'Notes',
    ),
    _TabItem(
      route: RouteNames.flashcards,
      icon: Icons.style_outlined,
      activeIcon: Icons.style_rounded,
      label: 'Cards',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrls = List.generate(
      _tabs.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
    _iconScales = _iconCtrls
        .map((c) => Tween<double>(begin: 1.0, end: 1.25).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOutBack),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _iconCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.planner))    return 1;
    if (location.startsWith(RouteNames.notes))      return 2;
    if (location.startsWith(RouteNames.flashcards)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int newIndex, int currentIndex) {
    if (newIndex == currentIndex) return;
    HapticFeedback.selectionClick();
    // Animate icon bounce
    _iconCtrls[newIndex].forward().then((_) => _iconCtrls[newIndex].reverse());
    // Navigate
    switch (newIndex) {
      case 0: context.go(RouteNames.dashboard);
      case 1: context.go(RouteNames.planner);
      case 2: context.go(RouteNames.notes);
      case 3: context.go(RouteNames.flashcards);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      extendBody: true,          // content flows under the transparent nav bar
      body: widget.child,
      bottomNavigationBar: RepaintBoundary(
        child: _FrostedNavBar(
          currentIndex: index,
          tabs: _tabs,
          iconScales: _iconScales,
          onTap: (i) => _onTap(context, i, index),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FrostedNavBar — Glassmorphism bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _FrostedNavBar extends StatelessWidget {
  const _FrostedNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.iconScales,
    required this.onTap,
  });

  final int currentIndex;
  final List<_TabItem> tabs;
  final List<Animation<double>> iconScales;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(
            top: 8,
            bottom: bottom + 8,
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.72),
            border: const Border(
              top: BorderSide(color: AppTheme.borderDark, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              return _NavItem(
                tab: tabs[i],
                isSelected: i == currentIndex,
                scaleAnim: iconScales[i],
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavItem — Single tab destination with animated indicator pill
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.scaleAnim,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isSelected;
  final Animation<double> scaleAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Indicator pill + icon ─────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.primary.withOpacity(0.30),
                        width: 1,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.20),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedBuilder(
                animation: scaleAnim,
                builder: (_, __) => Transform.scale(
                  scale: scaleAnim.value,
                  child: Icon(
                    isSelected ? tab.activeIcon : tab.icon,
                    size: 22,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // ── Label ─────────────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
