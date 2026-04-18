import 'package:flutter/foundation.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/core/utils/use_case.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/domain/repositories/study_repository.dart';
import 'package:study_smart/features/study_items/domain/usecases/study_usecases.dart';

enum StudyState { idle, loading, success, error }

/// Granular result returned by [StudyViewModel.addStudyItem].
class AddItemResult {
  const AddItemResult({this.error});
  final String? error;
  bool get isSuccess => error == null;
}

class StudyViewModel extends ChangeNotifier {
  final GetDecksUseCase getDecksUseCase;
  final CreateDeckUseCase createDeckUseCase;
  final DeleteDeckUseCase deleteDeckUseCase;
  final GetItemsByDeckUseCase getItemsByDeckUseCase;
  final AddItemUseCase addItemUseCase;
  /// Direct repository reference — used for real-time streams only.
  final StudyRepository repository;

  StudyViewModel({
    required this.getDecksUseCase,
    required this.createDeckUseCase,
    required this.deleteDeckUseCase,
    required this.getItemsByDeckUseCase,
    required this.addItemUseCase,
    required this.repository,
  });

  StudyState _state = StudyState.idle;
  List<DeckEntity> _decks = [];
  List<StudyItemEntity> _currentDeckItems = [];
  String? _errorMessage;

  // ── Isolated add-item state ────────────────────────────────────────────────
  bool _isAddingItem = false;
  String? _addItemError;

  StudyState get state => _state;
  List<DeckEntity> get decks => _decks;
  List<StudyItemEntity> get currentDeckItems => _currentDeckItems;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == StudyState.loading;
  bool get isAddingItem => _isAddingItem;
  String? get addItemError => _addItemError;

  // ── Decks ──────────────────────────────────────────────────────────────────

  Future<void> loadDecks() async {
    _setState(StudyState.loading);
    final result = await getDecksUseCase(const NoParams());
    result.fold(
      (failure) => _setError(failure),
      (decks) {
        _decks = decks;
        _setState(StudyState.success);
      },
    );
  }

  Future<void> createDeck(DeckEntity deck) async {
    _setState(StudyState.loading);
    final result = await createDeckUseCase(deck);
    result.fold(
      (failure) => _setError(failure),
      (newDeck) {
        _decks.add(newDeck);
        _setState(StudyState.success);
      },
    );
  }

  Future<void> removeDeck(String deckId) async {
    _setState(StudyState.loading);
    final result = await deleteDeckUseCase(deckId);
    result.fold(
      (failure) => _setError(failure),
      (_) {
        _decks.removeWhere((d) => d.id == deckId);
        _setState(StudyState.success);
      },
    );
  }

  // ── Study Items ────────────────────────────────────────────────────────────

  Future<void> loadItems(String deckId) async {
    _setState(StudyState.loading);
    final result = await getItemsByDeckUseCase(deckId);
    result.fold(
      (failure) => _setError(failure),
      (items) {
        _currentDeckItems = items;
        _setState(StudyState.success);
      },
    );
  }

  // ── Real-time stream ───────────────────────────────────────────────────────

  /// Live Firestore stream of study items for [deckId].
  /// Automatically falls back to the local Hive cache when offline.
  /// Prefer this over [loadItems] for any list UI.
  Stream<List<StudyItemEntity>> watchItems(String deckId) =>
      repository.watchItems(deckId);

  /// Live Firestore stream of due items today across ALL decks.
  Stream<List<StudyItemEntity>> watchDueItemsAcrossDecks() =>
      repository.watchDueItemsAcrossDecks();

  Future<void> createItem(StudyItemEntity item) async {
    _setState(StudyState.loading);
    final result = await addItemUseCase(item);
    result.fold(
      (failure) => _setError(failure),
      (newItem) {
        _currentDeckItems.add(newItem);
        _setState(StudyState.success);
      },
    );
  }

  /// Saves a new study item without touching the global [state].
  /// The sheet uses this so the deck list doesn't flash a loading spinner.
  /// Returns an [AddItemResult] with [AddItemResult.error] set on failure.
  Future<AddItemResult> addStudyItem(StudyItemEntity item) async {
    _isAddingItem = true;
    _addItemError = null;
    notifyListeners();

    final result = await addItemUseCase(item);

    return result.fold(
      (failure) {
        _isAddingItem = false;
        _addItemError = failure.message;
        notifyListeners();
        return AddItemResult(error: failure.message);
      },
      (newItem) {
        _currentDeckItems = [newItem, ..._currentDeckItems];
        _isAddingItem = false;
        _addItemError = null;
        notifyListeners();
        return const AddItemResult();
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _setError(Failure failure) {
    _errorMessage = failure.message;
    _setState(StudyState.error);
  }

  void _setState(StudyState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _setState(StudyState.idle);
  }
}
