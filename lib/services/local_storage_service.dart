import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../models/debt_credit_item.dart';

class LocalStorageService extends GetxService {
  static const String _boxName = 'debt_credit_box';
  late Box<DebtCreditItem> _box;

  Future<LocalStorageService> init() async {
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DebtCreditItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }

    _box = await Hive.openBox<DebtCreditItem>(_boxName);
    return this;
  }

  // Ajouter un élément
  Future<void> addItem(DebtCreditItem item) async {
    await _box.put(item.id, item);
  }

  // Obtenir tous les éléments
  List<DebtCreditItem> getAllItems() {
    return _box.values.toList();
  }

  // Obtenir les dettes (je dois)
  List<DebtCreditItem> getDebts(String userId) {
    return _box.values
        .where((item) => item.isDebt && item.userId == userId)
        .toList();
  }

  // Obtenir les crédits (j'ai prêté)
  List<DebtCreditItem> getCredits(String userId) {
    return _box.values
        .where((item) => !item.isDebt && item.userId == userId)
        .toList();
  }

  // Mettre à jour un élément
  Future<void> updateItem(DebtCreditItem item) async {
    await _box.put(item.id, item);
  }

  // Supprimer un élément
  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  // Obtenir un élément par ID
  DebtCreditItem? getItem(String id) {
    return _box.get(id);
  }

  // Rechercher des éléments
  List<DebtCreditItem> searchItems(String query, String userId) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where(
          (item) =>
              item.userId == userId &&
              (item.personName.toLowerCase().contains(lowerQuery) ||
                  item.amount.toString().contains(lowerQuery) ||
                  item.notes?.toLowerCase().contains(lowerQuery) == true),
        )
        .toList();
  }

  // Vider la base locale
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Obtenir les éléments avec rappel
  List<DebtCreditItem> getItemsWithReminders(String userId) {
    return _box.values
        .where(
          (item) =>
              item.userId == userId &&
              item.reminderDate != null &&
              !item.isRepaid,
        )
        .toList();
  }
}
