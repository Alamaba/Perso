import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/debt_credit_item.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../services/security_service.dart';

class DebtCreditController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final ExportService _exportService = Get.find<ExportService>();
  final SecurityService _securityService = Get.find<SecurityService>();

  // Listes observables
  RxList<DebtCreditItem> debts = <DebtCreditItem>[].obs;
  RxList<DebtCreditItem> credits = <DebtCreditItem>[].obs;
  RxList<DebtCreditItem> filteredDebts = <DebtCreditItem>[].obs;
  RxList<DebtCreditItem> filteredCredits = <DebtCreditItem>[].obs;

  // État de l'interface
  RxString searchQuery = ''.obs;
  RxBool isLoading = false.obs;
  RxInt selectedTabIndex = 0.obs;

  // Totaux
  RxDouble totalDebts = 0.0.obs;
  RxDouble totalCredits = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();

    // Écouter les changements d'état d'authentification
    ever(_authService.user, (user) {
      if (user != null && _authService.currentUserId != null) {
        print('Utilisateur connecté détecté, chargement des données...');
        _loadData();
      } else {
        print('Utilisateur déconnecté, nettoyage des données...');
        _clearData();
      }
    });

    // Charger les données si un utilisateur est déjà connecté
    if (_authService.currentUserId != null) {
      print(
          'Utilisateur déjà connecté lors de l\'initialisation: ${_authService.currentUserId}');
      _loadData();
    } else {
      print('Aucun utilisateur connecté lors de l\'initialisation');
    }
  }

  void _setupSearchListener() {
    searchQuery.listen((query) {
      _filterItems();
    });
  }

  Future<void> _loadData() async {
    if (_authService.currentUserId == null) return;

    isLoading.value = true;
    update(); // Notifier du début du chargement

    try {
      // Charger d'abord depuis Firestore (priorité au cloud)
      final cloudItems = await _firestoreService.getUserItems(
        _authService.currentUserId!,
      );

      if (cloudItems.isNotEmpty) {
        // Séparer les dettes et crédits depuis le cloud
        final cloudDebts = cloudItems.where((item) => item.isDebt).toList();
        final cloudCredits = cloudItems.where((item) => !item.isDebt).toList();

        debts.assignAll(cloudDebts);
        credits.assignAll(cloudCredits);

        // Synchroniser vers le stockage local
        for (final item in cloudItems) {
          await _localStorage.addItem(item);
        }

        print('✅ ${cloudItems.length} elements chargés depuis Firestore');
      } else {
        // Si pas de données cloud, charger depuis le stockage local
        final localDebts = _localStorage.getDebts(_authService.currentUserId!);
        final localCredits = _localStorage.getCredits(
          _authService.currentUserId!,
        );

        debts.assignAll(localDebts);
        credits.assignAll(localCredits);

        print(
            '✅ ${localDebts.length + localCredits.length} elements chargés depuis le stockage local');
      }

      _calculateTotals();
      _filterItems();
    } catch (e) {
      print('❌ Erreur de chargement: $e');

      // En cas d'erreur Firestore, essayer le stockage local
      try {
        final localDebts = _localStorage.getDebts(_authService.currentUserId!);
        final localCredits = _localStorage.getCredits(
          _authService.currentUserId!,
        );

        debts.assignAll(localDebts);
        credits.assignAll(localCredits);

        _calculateTotals();
        _filterItems();

        print('✅ Données chargées depuis le stockage local après erreur cloud');
      } catch (localError) {
        Get.snackbar(
          'Erreur',
          'Impossible de charger les données: $localError',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      update(); // Notifier de la fin du chargement
    }
  }

  Future<void> _syncWithFirestore() async {
    try {
      if (_authService.currentUserId != null) {
        final cloudItems = await _firestoreService.getUserItems(
          _authService.currentUserId!,
        );

        // Fusionner les données locales et cloud (logique simplifiée)
        for (final cloudItem in cloudItems) {
          final localItem = _localStorage.getItem(cloudItem.id);
          if (localItem == null) {
            // Nouvel élément du cloud
            await _localStorage.addItem(cloudItem);
            if (cloudItem.isDebt) {
              debts.add(cloudItem);
            } else {
              credits.add(cloudItem);
            }
          }
        }

        _calculateTotals();
        _filterItems();
      }
    } catch (e) {
      print('Erreur de synchronisation: $e');
    }
  }

  void _calculateTotals() {
    totalDebts.value = debts
        .where((debt) => !debt.isRepaid)
        .fold(0.0, (sum, debt) => sum + debt.amount);

    totalCredits.value = credits
        .where((credit) => !credit.isRepaid)
        .fold(0.0, (sum, credit) => sum + credit.amount);

    update(); // Notifier GetBuilder des changements
  }

  void _filterItems() {
    if (searchQuery.value.isEmpty) {
      filteredDebts.assignAll(debts);
      filteredCredits.assignAll(credits);
    } else {
      final query = searchQuery.value.toLowerCase();

      filteredDebts.assignAll(
        debts.where(
          (debt) =>
              debt.personName.toLowerCase().contains(query) ||
              debt.amount.toString().contains(query) ||
              (debt.notes?.toLowerCase().contains(query) ?? false),
        ),
      );

      filteredCredits.assignAll(
        credits.where(
          (credit) =>
              credit.personName.toLowerCase().contains(query) ||
              credit.amount.toString().contains(query) ||
              (credit.notes?.toLowerCase().contains(query) ?? false),
        ),
      );
    }

    update(); // Notifier GetBuilder des changements
  }

  Future<void> addItem({
    required String personName,
    required double amount,
    required bool isDebt,
    DateTime? date,
    String? notes,
    DateTime? reminderDate,
  }) async {
    if (_authService.currentUserId == null) return;

    // Vérifier la sécurité si nécessaire
    final authenticated = await _securityService.requireAuthentication(
      reason: 'Authentifiez-vous pour ajouter un élément',
    );
    if (!authenticated) return;

    final item = DebtCreditItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      personName: personName,
      amount: amount,
      date: date ?? DateTime.now(),
      isDebt: isDebt,
      userId: _authService.currentUserId!,
      notes: notes,
      reminderDate: reminderDate,
      history: [
        HistoryEntry(
          date: DateTime.now(),
          action: 'Création',
          newValue: 'Montant: ${amount.toStringAsFixed(0)} FDJ',
        ),
      ],
    );

    try {
      // Sauvegarder localement
      await _localStorage.addItem(item);

      // Sauvegarder dans le cloud
      await _firestoreService.addItem(item);

      // Ajouter à la liste appropriée
      if (isDebt) {
        debts.add(item);
      } else {
        credits.add(item);
      }

      // Programmer un rappel si nécessaire
      if (reminderDate != null) {
        await _notificationService.scheduleReminder(item);
      }

      _calculateTotals();
      _filterItems();

      Get.snackbar(
        'Succès',
        '${isDebt ? 'Dette' : 'Crédit'} ajouté avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter l\'élément: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateItem(DebtCreditItem item) async {
    // Vérifier la sécurité si nécessaire
    final authenticated = await _securityService.requireAuthentication(
      reason: 'Authentifiez-vous pour modifier un élément',
    );
    if (!authenticated) return;

    try {
      // Ajouter à l'historique
      item.history.add(
        HistoryEntry(
          date: DateTime.now(),
          action: 'Modification',
          newValue: 'Montant: ${item.amount.toStringAsFixed(0)} FDJ',
        ),
      );

      // Sauvegarder localement
      await _localStorage.updateItem(item);

      // Sauvegarder dans le cloud
      await _firestoreService.updateItem(item);

      // Mettre à jour la liste
      final index = item.isDebt
          ? debts.indexWhere((d) => d.id == item.id)
          : credits.indexWhere((c) => c.id == item.id);

      if (index != -1) {
        if (item.isDebt) {
          debts[index] = item;
        } else {
          credits[index] = item;
        }
      }

      _calculateTotals();
      _filterItems();

      Get.snackbar(
        'Succès',
        'Élément mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour l\'élément: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteItem(DebtCreditItem item) async {
    // Vérifier la sécurité si nécessaire
    final authenticated = await _securityService.requireAuthentication(
      reason: 'Authentifiez-vous pour supprimer un élément',
    );
    if (!authenticated) return;

    try {
      // Supprimer localement
      await _localStorage.deleteItem(item.id);

      // Supprimer du cloud
      await _firestoreService.deleteItem(item.id);

      // Annuler le rappel si nécessaire
      if (item.reminderDate != null) {
        await _notificationService.cancelReminder(item.id);
      }

      // Supprimer de la liste
      if (item.isDebt) {
        debts.removeWhere((d) => d.id == item.id);
      } else {
        credits.removeWhere((c) => c.id == item.id);
      }

      _calculateTotals();
      _filterItems();

      Get.snackbar(
        'Succès',
        'Élément supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer l\'élément: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markAsRepaid(DebtCreditItem item) async {
    item.isRepaid = true;
    item.history.add(
      HistoryEntry(
        date: DateTime.now(),
        action: 'Marqué comme remboursé',
        newValue: 'Statut: Remboursé',
      ),
    );

    await updateItem(item);

    // Annuler le rappel
    if (item.reminderDate != null) {
      await _notificationService.cancelReminder(item.id);
    }

    // Notification de succès
    await _notificationService.showInstantNotification(
      'Remboursement confirmé',
      '${item.personName} - ${item.amount.toStringAsFixed(0)} FDJ',
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> exportToPDF() async {
    // Vérifier la sécurité si nécessaire
    final authenticated = await _securityService.requireAuthentication(
      reason: 'Authentifiez-vous pour exporter les données',
    );
    if (!authenticated) return;

    // Exporter les dettes et crédits séparément
    try {
      await _exportService.exportToPdf(debts, 'debt');
      await _exportService.exportToPdf(credits, 'credit');

      Get.snackbar(
        'Export réussi',
        'Les fichiers PDF ont été générés avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible d\'exporter en PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportToExcel() async {
    // Vérifier la sécurité si nécessaire
    final authenticated = await _securityService.requireAuthentication(
      reason: 'Authentifiez-vous pour exporter les données',
    );
    if (!authenticated) return;

    // Utiliser l'export combiné pour Excel
    try {
      await _exportService.exportCombined(debts, credits);

      Get.snackbar(
        'Export réussi',
        'Le fichier Excel a été généré avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible d\'exporter en Excel: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} FDJ';
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Méthode pour débugger l'état actuel
  void debugState() {
    print('=== DEBUG STATE ===');
    print('User ID: ${_authService.currentUserId}');
    print('Dettes: ${debts.length}');
    print('Credits: ${credits.length}');
    print('Dettes filtrees: ${filteredDebts.length}');
    print('Credits filtres: ${filteredCredits.length}');
    print('Total dettes: ${totalDebts.value}');
    print('Total credits: ${totalCredits.value}');
    print('Chargement: ${isLoading.value}');
    print('==================');
  }

  // Méthode publique pour recharger les données manuellement
  Future<void> reloadData() async {
    print('Rechargement manuel des donnees demande');
    await _loadData();
  }

  void _clearData() {
    debts.clear();
    credits.clear();
    filteredDebts.clear();
    filteredCredits.clear();
    totalDebts.value = 0.0;
    totalCredits.value = 0.0;
    searchQuery.value = '';
    update();
  }

  // Méthode publique pour forcer le rechargement (appelée après connexion)
  Future<void> forceReload() async {
    print('Rechargement forcé des données demandé');
    if (_authService.currentUserId != null) {
      await _loadData();
    }
  }
}
