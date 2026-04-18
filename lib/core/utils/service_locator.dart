import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:study_smart/core/network/network_info.dart';
import 'package:study_smart/core/services/firebase_service.dart';
import 'package:study_smart/core/services/firestore_service.dart';
import 'package:study_smart/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:study_smart/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:study_smart/features/auth/domain/repositories/auth_repository.dart';
import 'package:study_smart/features/auth/domain/usecases/auth_usecases.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/study_items/data/datasources/study_local_datasource.dart';
import 'package:study_smart/features/study_items/data/datasources/study_remote_datasource.dart';
import 'package:study_smart/features/study_items/data/repositories/revision_repository_impl.dart';
import 'package:study_smart/features/study_items/data/repositories/study_repository_impl.dart';
import 'package:study_smart/features/study_items/data/services/revision_firestore_service.dart';
import 'package:study_smart/features/study_items/domain/repositories/revision_repository.dart';
import 'package:study_smart/features/study_items/domain/repositories/study_repository.dart';
import 'package:study_smart/features/study_items/domain/usecases/study_usecases.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/revision_viewmodel.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';
import 'package:get_it/get_it.dart';


final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Core / Network ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance());
  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreService(firebaseService: sl()),
  );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(firebaseService: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));

  sl.registerFactory(
    () => AuthViewModel(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      sendPasswordResetEmailUseCase: sl(),
    ),
  );

  // ── Study Items ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StudyRemoteDataSource>(
    () => FirestoreStudyRemoteDataSource(firestoreService: sl()),
  );
  sl.registerLazySingleton<StudyLocalDataSource>(
    () => HiveStudyLocalDataSource(),
  );
  sl.registerLazySingleton<StudyRepository>(
    () => StudyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      authRepository: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetDecksUseCase(sl()));
  sl.registerLazySingleton(() => CreateDeckUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeckUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsByDeckUseCase(sl()));
  sl.registerLazySingleton(() => AddItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));

  sl.registerFactory(
    () => StudyViewModel(
      getDecksUseCase: sl(),
      createDeckUseCase: sl(),
      deleteDeckUseCase: sl(),
      getItemsByDeckUseCase: sl(),
      addItemUseCase: sl(),
      repository: sl(),
    ),
  );

  // ── Revisions ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<RevisionFirestoreService>(
    () => RevisionFirestoreService(firestoreService: sl()),
  );
  sl.registerLazySingleton<RevisionRepository>(
    () => RevisionRepositoryImpl(
      revisionService: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => CompleteRevisionUseCase(sl()));

  sl.registerFactory(
    () => RevisionViewModel(
      repository: sl(),
      completeRevisionUseCase: sl(),
    ),
  );
}


