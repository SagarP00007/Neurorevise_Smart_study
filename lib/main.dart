import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:study_smart/core/router/app_router.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/core/utils/service_locator.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';
import 'package:study_smart/firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Orientation ───────────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar ────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Hive (local DB) ───────────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── Dependency Injection ──────────────────────────────────────────────────
  await setupDependencies();

  runApp(const StudySmartApp());
}

class StudySmartApp extends StatelessWidget {
  const StudySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthViewModel is created by GetIt so all UseCases are injected
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => sl<AuthViewModel>()..loadCurrentUser(),
        ),
        ChangeNotifierProvider<StudyViewModel>(
          create: (_) => sl<StudyViewModel>()..loadDecks(),
        ),
        // Add future ViewModels here:

        // ChangeNotifierProvider(create: (_) => sl<PlannerViewModel>()),
        // ChangeNotifierProvider(create: (_) => sl<NotesViewModel>()),
        // ChangeNotifierProvider(create: (_) => sl<FlashcardsViewModel>()),
        // ChangeNotifierProvider(create: (_) => sl<AnalyticsViewModel>()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp.router(
          title: 'Study Smart',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          routerConfig: AppRouter.router(context.read<AuthViewModel>()),
        );
      }),
    );
  }
}

