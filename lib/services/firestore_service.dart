import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/debt_credit_item.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'debt_credit_items';

  // Ajouter un élément dans Firestore
  Future<void> addItem(DebtCreditItem item) async {
    try {
      await _firestore.collection(_collection).doc(item.id).set(item.toMap());
    } catch (e) {
      Get.snackbar(
        'Erreur de synchronisation',
        'Impossible de sauvegarder dans le cloud: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mettre à jour un élément dans Firestore
  Future<void> updateItem(DebtCreditItem item) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(item.id)
          .update(item.toMap());
    } catch (e) {
      Get.snackbar(
        'Erreur de synchronisation',
        'Impossible de mettre à jour dans le cloud: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Supprimer un élément de Firestore
  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      Get.snackbar(
        'Erreur de synchronisation',
        'Impossible de supprimer du cloud: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Obtenir tous les éléments d'un utilisateur
  Future<List<DebtCreditItem>> getUserItems(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .get();

      return querySnapshot.docs
          .map((doc) => DebtCreditItem.fromMap(doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Erreur de synchronisation',
        'Impossible de récupérer les données du cloud: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // Stream pour écouter les changements en temps réel
  Stream<List<DebtCreditItem>> getUserItemsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DebtCreditItem.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Synchroniser les données locales vers le cloud
  Future<void> syncToCloud(List<DebtCreditItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final docRef = _firestore.collection(_collection).doc(item.id);
        batch.set(docRef, item.toMap());
      }

      await batch.commit();
    } catch (e) {
      Get.snackbar(
        'Erreur de synchronisation',
        'Impossible de synchroniser vers le cloud: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
