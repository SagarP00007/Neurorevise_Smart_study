import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/exceptions.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/core/network/network_info.dart';
import 'package:study_smart/features/auth/domain/repositories/auth_repository.dart';
import 'package:study_smart/features/study_items/data/datasources/study_local_datasource.dart';
import 'package:study_smart/features/study_items/data/datasources/study_remote_datasource.dart';
import 'package:study_smart/features/study_items/data/models/deck_model.dart';
import 'package:study_smart/features/study_items/data/models/study_item_model.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/domain/repositories/study_repository.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyRemoteDataSource remoteDataSource;
  final StudyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final AuthRepository authRepository;

  StudyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authRepository,
  });

  Future<String> _getUserId() async {
    final userResult = await authRepository.getCurrentUser();
    return userResult.fold(
      (failure) => throw AuthException(message: failure.message),
      (user) => user?.uid ?? (throw const AuthException(message: 'User not logged in')),
    );
  }

  // ── Decks ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DeckEntity>>> getDecks() async {
    try {
      if (await networkInfo.isConnected) {
        final userId = await _getUserId();
        final remoteDecks = await remoteDataSource.getDecks(userId);
        await localDataSource.saveDecks(remoteDecks);
        return Right(remoteDecks);
      } else {
        final localDecks = await localDataSource.getDecks();
        return Right(localDecks);
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeckEntity>> createDeck(DeckEntity deck) async {
    try {
      final model = DeckModel.fromEntity(deck);
      if (await networkInfo.isConnected) {
        final created = await remoteDataSource.createDeck(model);
        await localDataSource.saveDeck(created);
        return Right(created);
      } else {
        // Offline support: save locally first, sync later
        await localDataSource.saveDeck(model);
        return Right(model);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeck(DeckEntity deck) async {
    try {
      final model = DeckModel.fromEntity(deck);
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateDeck(model);
      }
      await localDataSource.saveDeck(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(String deckId) async {
    try {
      if (await networkInfo.isConnected) {
        final userId = await _getUserId();
        await remoteDataSource.deleteDeck(userId, deckId);
      }
      await localDataSource.deleteDeck(deckId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<DeckEntity>> watchDecks() async* {
    if (await networkInfo.isConnected) {
      try {
        final userId = await _getUserId();
        yield* remoteDataSource.watchDecks(userId);
      } catch (_) {
        yield [];
      }
    } else {
      yield* Stream.fromFuture(localDataSource.getDecks());
    }
  }

  // ── Study Items ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<StudyItemEntity>>> getItemsByDeck(String deckId) async {
    try {
      if (await networkInfo.isConnected) {
        final userId = await _getUserId();
        final remoteItems = await remoteDataSource.getItems(userId, deckId);
        await localDataSource.saveItems(deckId, remoteItems);
        return Right(remoteItems);
      } else {
        final localItems = await localDataSource.getItems(deckId);
        return Right(localItems);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudyItemEntity>> addItem(StudyItemEntity item) async {
    try {
      final model = StudyItemModel.fromEntity(item);
      if (await networkInfo.isConnected) {
        final created = await remoteDataSource.addItem(model);
        await remoteDataSource.createRevisionSchedule(
          model.userId,
          model.deckId,
          model.id,
        );
        await localDataSource.saveItem(created);
        return Right(created);
      } else {
        await localDataSource.saveItem(model);
        return Right(model);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(StudyItemEntity item) async {
    try {
      final model = StudyItemModel.fromEntity(item);
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateItem(model);
      }
      await localDataSource.saveItem(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      if (await networkInfo.isConnected) {
        final userId = await _getUserId();
        // Retrieve deckId from local cache before touching remote.
        final localItems = await localDataSource.getDecks();
        // Walk through all local decks to find the item's deckId.
        String? deckId;
        for (final deck in localItems) {
          final items = await localDataSource.getItems(deck.id);
          final match = items.where((i) => i.id == itemId).toList();
          if (match.isNotEmpty) {
            deckId = deck.id;
            break;
          }
        }
        if (deckId != null) {
          await remoteDataSource.deleteItem(userId, deckId, itemId);
        }
      }
      await localDataSource.deleteItem(itemId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<StudyItemEntity>> watchItems(String deckId) async* {
    if (await networkInfo.isConnected) {
      try {
        final userId = await _getUserId();
        yield* remoteDataSource.watchItems(userId, deckId);
      } catch (_) {
        yield [];
      }
    } else {
      yield* Stream.fromFuture(localDataSource.getItems(deckId));
    }
  }

  @override
  Stream<List<StudyItemEntity>> watchDueItemsAcrossDecks() async* {
    if (await networkInfo.isConnected) {
      try {
        final userId = await _getUserId();
        yield* remoteDataSource.watchDueItemsAcrossDecks(userId);
      } catch (_) {
        yield [];
      }
    } else {
      // For offline: simple fallback or empty since cross-deck query locally isn't strictly requested.
      yield [];
    }
  }

  @override
  Future<void> syncRemote() async {
    if (await networkInfo.isConnected) {
      try {
        final userId = await _getUserId();
        final remoteDecks = await remoteDataSource.getDecks(userId);
        await localDataSource.saveDecks(remoteDecks);
        // Deep sync for items would go here
      } catch (_) {}
    }
  }
}
