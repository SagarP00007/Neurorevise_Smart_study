/// User-facing performance rating shown after reviewing a flashcard.
///
/// Internally maps to SM-2 quality values (0–5):
///   hard   → quality 1 (incorrect recall, resets progress)
///   medium → quality 3 (correct with difficulty, moderate EF delta)
///   easy   → quality 5 (perfect recall,  maximum EF boost)
enum PerformanceRating {
  hard,
  medium,
  easy;

  /// The raw SM-2 quality value (0–5) this rating maps to.
  int get quality {
    switch (this) {
      case PerformanceRating.hard:   return 1; // wrong — resets interval
      case PerformanceRating.medium: return 3; // correct with effort
      case PerformanceRating.easy:   return 5; // perfect recall
    }
  }

  /// Human-readable label.
  String get label {
    switch (this) {
      case PerformanceRating.hard:   return 'Hard';
      case PerformanceRating.medium: return 'Medium';
      case PerformanceRating.easy:   return 'Easy';
    }
  }

  /// Emoji helper used by the UI buttons.
  String get emoji {
    switch (this) {
      case PerformanceRating.hard:   return '😓';
      case PerformanceRating.medium: return '🤔';
      case PerformanceRating.easy:   return '😊';
    }
  }

  /// Accent colour for each rating button.
  static const Map<PerformanceRating, int> _colorValues = {
    PerformanceRating.hard:   0xFFE53E3E, // red
    PerformanceRating.medium: 0xFFECC94B, // amber
    PerformanceRating.easy:   0xFF48BB78, // green
  };

  int get colorValue => _colorValues[this]!;
}

// ── SM-2 Response ─────────────────────────────────────────────────────────────

class SM2Response {
  final int easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewDate;

  /// A plain description of what the algorithm decided. Useful for logging.
  final String summary;

  SM2Response({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewDate,
    required this.summary,
  });
}

// ── SM-2 Algorithm ────────────────────────────────────────────────────────────

class SM2Algorithm {
  /// Calculates the next review state based on the SM-2 algorithm.
  ///
  /// [quality] is the raw quality rating (0–5):
  ///   5: perfect response
  ///   4: correct response after a hesitation
  ///   3: correct response recalled with serious difficulty
  ///   2: incorrect response; where the correct one seemed easy to recall
  ///   1: incorrect response; the correct one remembered
  ///   0: complete blackout.
  ///
  /// For the common 3-rating case, pass [PerformanceRating.quality] instead.
  static SM2Response calculate({
    required int quality,
    required int previousEaseFactor,
    required int previousInterval,
    required int previousRepetitions,
  }) {
    int easeFactor = previousEaseFactor;
    int interval;
    int repetitions;

    if (quality >= 3) {
      // Correct response
      if (previousRepetitions == 0) {
        interval = 1;
      } else if (previousRepetitions == 1) {
        interval = 6;
      } else {
        interval = (previousInterval * (previousEaseFactor / 100)).round();
      }
      repetitions = previousRepetitions + 1;

      // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      // Normalized: EF' = EF + (10 - (5 - q) * (8 + (5 - q) * 2))
      easeFactor = previousEaseFactor +
          (10 - (5 - quality) * (8 + (5 - quality) * 2));
    } else {
      // Incorrect response: reset repetitions and interval
      repetitions = 0;
      interval = 1;
    }

    if (easeFactor < 130) easeFactor = 130; // minimum EF = 1.3

    final nextReviewDate = DateTime.now().add(Duration(days: interval));

    final summary = quality >= 3
        ? 'Next review in $interval day${interval == 1 ? '' : 's'} '
          '(EF ${(easeFactor / 100).toStringAsFixed(2)})'
        : 'Interval reset to 1 day (incorrect recall)';

    return SM2Response(
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      nextReviewDate: nextReviewDate,
      summary: summary,
    );
  }

  /// Convenience factory — takes a [PerformanceRating] instead of raw quality.
  ///
  /// ```dart
  /// final result = SM2Algorithm.fromPerformance(
  ///   rating: PerformanceRating.easy,
  ///   previousEaseFactor: item.easeFactor,
  ///   previousInterval: item.interval,
  ///   previousRepetitions: item.repetitions,
  /// );
  /// print(result.summary); // "Next review in 6 days (EF 2.60)"
  /// ```
  static SM2Response fromPerformance({
    required PerformanceRating rating,
    required int previousEaseFactor,
    required int previousInterval,
    required int previousRepetitions,
  }) =>
      calculate(
        quality: rating.quality,
        previousEaseFactor: previousEaseFactor,
        previousInterval: previousInterval,
        previousRepetitions: previousRepetitions,
      );
}
