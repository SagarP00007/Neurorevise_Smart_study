import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_smart/features/study_items/data/models/deck_model.dart';
import 'package:study_smart/features/study_items/data/models/study_item_model.dart';

abstract class StudyLocalDataSource {
  Future<List<DeckModel>> getDecks();
  Future<void> saveDecks(List<DeckModel> decks);
  Future<void> saveDeck(DeckModel deck);
  Future<void> deleteDeck(String deckId);

  Future<List<StudyItemModel>> getItems(String deckId);
  Future<void> saveItems(String deckId, List<StudyItemModel> items);
  Future<void> saveItem(StudyItemModel item);
  Future<void> deleteItem(String itemId);
}

class HiveStudyLocalDataSource implements StudyLocalDataSource {
  static const String decksBoxName = 'decks_box';
  static const String itemsBoxName = 'items_box';

  // ── Decks ──────────────────────────────────────────────────────────────────

  @override
  Future<List<DeckModel>> getDecks() async {
    final box = await Hive.openBox(decksBoxName);
    return box.values
        .map((d) => DeckModel.fromMap(Map<String, dynamic>.from(d), d['id'] ?? ''))
        .toList();
  }

  @override
  Future<void> saveDecks(List<DeckModel> decks) async {
    final box = await Hive.openBox(decksBoxName);
    final updates = {for (var d in decks) d.id: d.toMap()};
    await box.putAll(updates);
  }

  @override
  Future<void> saveDeck(DeckModel deck) async {
    final box = await Hive.openBox(decksBoxName);
    await box.put(deck.id, deck.toMap());
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    final box = await Hive.openBox(decksBoxName);
    await box.delete(deckId);
    
    // Also clean up items for this deck
    final itemsBox = await Hive.openBox(itemsBoxName);
    final keysToDelete = itemsBox.keys.where((k) {
      final item = itemsBox.get(k);
      return item['deckId'] == deckId;
    });
    await itemsBox.deleteAll(keysToDelete);
  }

  // ── Study Items ────────────────────────────────────────────────────────────

  @override
  Future<List<StudyItemModel>> getItems(String deckId) async {
    final box = await Hive.openBox(itemsBoxName);
    return box.values
        .where((i) => i['deckId'] == deckId)
        .map((i) => StudyItemModel.fromMap(Map<String, dynamic>.from(i), i['id'] ?? ''))
        .toList();
  }

  @override
  Future<void> saveItems(String deckId, List<StudyItemModel> items) async {
    final box = await Hive.openBox(itemsBoxName);
    final updates = {for (var i in items) i.id: i.toMap()};
    await box.putAll(updates);
  }

  @override
  Future<void> saveItem(StudyItemModel item) async {
    final box = await Hive.openBox(itemsBoxName);
    await box.put(item.id, item.toMap());
  }

  @override
  Future<void> deleteItem(String itemId) async {
    final box = await Hive.openBox(itemsBoxName);
    await box.delete(itemId);
  }
}
