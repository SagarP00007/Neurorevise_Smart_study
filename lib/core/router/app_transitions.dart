import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTransitions — Centralised GoRouter page-transition factory
// ─────────────────────────────────────────────────────────────────────────────

/// All transition builders used by [AppRouter].
///
/// Each method returns a [CustomTransitionPage] ready to pass to a GoRoute's
/// [pageBuilder]. Hero animations work transparently — Flutter handles them
/// as long as matching [Hero] tags exist on both sides of the navigation.
abstract final class AppTransitions {

  // ── Fade + Scale (default — feels "native" on all platforms) ──────────────
  /// Soft material-you style fade with a very subtle 94%→100% scale.
  /// Use for tab switches and standard push navigations.
  static CustomTransitionPage<T> fadeScale<T>({
    required LocalKey pageKey,
    required Widget child,
    Duration duration = const Duration(milliseconds: 380),
  }) {
    return CustomTransitionPage<T>(
      key: pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration:
          Duration(milliseconds: (duration.inMilliseconds * 0.75).round()),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        // Outgoing page fades out slightly while incoming fades+scales in.
        final enter = CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic);
        final exit = CurvedAnimation(
            parent: secondaryAnimation, curve: Curves.easeIn);

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(enter),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.85).animate(exit),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // ── Slide Up + Fade (full-screen detail / modal pages) ───────────────────
  /// Content slides up from just below while fading in.
  /// Use for full-screen modals: TodayRevisionView, DeckDetailView.
  static CustomTransitionPage<T> slideUp<T>({
    required LocalKey pageKey,
    required Widget child,
    Duration duration = const Duration(milliseconds: 430),
  }) {
    return CustomTransitionPage<T>(
      key: pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration:
          Duration(milliseconds: (duration.inMilliseconds * 0.80).round()),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic);
        final exit = CurvedAnimation(
            parent: secondaryAnimation, curve: Curves.easeInCubic);

        return SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(enter),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(enter),
            // Outgoing page dims slightly
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.80).animate(exit),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // ── Slide Right (deep-navigation: auth → dashboard) ───────────────────────
  /// Classic slide from the right — feels like a deliberate forward push.
  static CustomTransitionPage<T> slideRight<T>({
    required LocalKey pageKey,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration:
          Duration(milliseconds: (duration.inMilliseconds * 0.80).round()),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic);
        final exit = CurvedAnimation(
            parent: secondaryAnimation, curve: Curves.easeInCubic);

        return SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1.0, 0), end: Offset.zero)
              .animate(enter),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            // Outgoing page slides slightly left (parallax)
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: Offset.zero, end: const Offset(-0.08, 0))
                  .animate(exit),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // ── Instant (no animation — for redirect/replace navigations) ────────────
  static CustomTransitionPage<T> instant<T>({
    required LocalKey pageKey,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HeroIds — Centralised Hero tag constants
// ─────────────────────────────────────────────────────────────────────────────

/// Shared tag constants to ensure matching Hero widgets on both screens.
///
/// Usage:
/// ```dart
/// // Screen A (list item)
/// Hero(tag: HeroIds.deckIcon(deck.id), child: DeckIcon())
///
/// // Screen B (detail page)
/// Hero(tag: HeroIds.deckIcon(deck.id), child: LargeDeckIcon())
/// ```
abstract final class HeroIds {
  /// Deck icon badge — list card → deck detail header.
  static String deckIcon(String deckId)   => 'deck_icon_$deckId';

  /// Deck title text — list card → deck detail title.
  static String deckTitle(String deckId)  => 'deck_title_$deckId';

  /// Flashcard front face — list → full-screen review.
  static String cardFace(String cardId)   => 'card_face_$cardId';

  /// The AI core ring — dashboard → revision screen.
  static const String aiCoreRing         = 'ai_core_ring';

  /// User avatar — app shell → profile page.
  static const String userAvatar         = 'user_avatar';

  HeroIds._();
}
