class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Study Smart';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String notesBox = 'notes_box';
  static const String flashcardsBox = 'flashcards_box';
  static const String plannerBox = 'planner_box';
  static const String settingsBox = 'settings_box';

  // SharedPrefs Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';

  // Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Padding / Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // Study Session defaults
  static const int defaultPomodoroMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
}
