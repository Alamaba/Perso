import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/debt_credit_controller.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import '../services/export_service.dart';
import '../screens/pin_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  final DebtCreditController controller = Get.find();
  final AuthService authService = Get.find();
  final SecurityService securityService = Get.find();
  final ExportService exportService = Get.find();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Paramètres',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade800,
                      Colors.indigo.shade700,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: authService.currentUserPhoto != null
                              ? NetworkImage(authService.currentUserPhoto!)
                              : null,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: authService.currentUserPhoto == null
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 36)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          authService.currentUserName ?? 'Utilisateur',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          authService.currentUserEmail ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenu des paramètres
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Section Sécurité
                  _buildSectionTitle(
                      'Sécurité & Confidentialité', Icons.security),
                  const SizedBox(height: 16),
                  _buildSecurityCard(),
                  const SizedBox(height: 30),

                  // Section Export
                  _buildSectionTitle('Export des données', Icons.download),
                  const SizedBox(height: 16),
                  _buildExportCard(),
                  const SizedBox(height: 30),

                  // Section Notifications
                  _buildSectionTitle('Notifications', Icons.notifications),
                  const SizedBox(height: 16),
                  _buildNotificationCard(),
                  const SizedBox(height: 30),

                  // Section Données
                  _buildSectionTitle('Gestion des données', Icons.storage),
                  const SizedBox(height: 16),
                  _buildDataCard(),
                  const SizedBox(height: 30),

                  // Section Compte
                  _buildSectionTitle('Mon compte', Icons.account_circle),
                  const SizedBox(height: 16),
                  _buildAccountCard(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return _buildModernCard(
      children: [
        _buildModernListTile(
          icon: Icons.logout,
          title: 'Se déconnecter',
          onTap: () => _showLogoutDialog(),
          iconColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return _buildModernCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Authentification biométrique',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          securityService.isBiometricAvailable.value
                              ? 'Protéger l\'accès à l\'application'
                              : 'Non disponible sur cet appareil',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: securityService.isBiometricEnabled.value,
                    onChanged: securityService.isBiometricAvailable.value
                        ? (value) => _toggleBiometric(value)
                        : null,
                    activeColor: Colors.blue.shade600,
                  ),
                ],
              )),
        ),
        _buildModernListTile(
          icon:
              securityService.isPinEnabled.value ? Icons.lock : Icons.lock_open,
          title: securityService.isPinEnabled.value
              ? 'Modifier le code PIN'
              : 'Configurer un code PIN',
          subtitle: securityService.isPinEnabled.value
              ? 'Changer votre code de sécurité actuel'
              : 'Créer un code PIN pour sécuriser l\'application',
          trailing: Icon(
            securityService.isPinEnabled.value
                ? Icons.check_circle
                : Icons.add_circle_outline,
            color:
                securityService.isPinEnabled.value ? Colors.green : Colors.grey,
          ),
          onTap: () => _setupPIN(),
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
        if (securityService.isSecurityEnabled.value)
          _buildModernListTile(
            icon: Icons.security_update_warning,
            title: 'Désactiver la sécurité',
            subtitle: 'Supprimer toute protection',
            onTap: () => _disableSecurity(),
            iconColor: Colors.orange,
            backgroundColor: Colors.orange.withOpacity(0.1),
          ),
      ],
    );
  }

  Widget _buildExportCard() {
    return _buildModernCard(
      children: [
        _buildModernListTile(
          icon: Icons.picture_as_pdf,
          title: 'Exporter dettes en PDF',
          subtitle: 'Générer un rapport PDF des dettes',
          onTap: () => _exportDebtsToPDF(),
          iconColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.1),
        ),
        _buildModernListTile(
          icon: Icons.picture_as_pdf,
          title: 'Exporter crédits en PDF',
          subtitle: 'Générer un rapport PDF des crédits',
          onTap: () => _exportCreditsToPDF(),
          iconColor: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.1),
        ),
        _buildModernListTile(
          icon: Icons.table_chart,
          title: 'Exporter dettes en Excel',
          subtitle: 'Générer un fichier Excel des dettes',
          onTap: () => _exportDebtsToExcel(),
          iconColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.1),
        ),
        _buildModernListTile(
          icon: Icons.table_chart,
          title: 'Exporter crédits en Excel',
          subtitle: 'Générer un fichier Excel des crédits',
          onTap: () => _exportCreditsToExcel(),
          iconColor: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.1),
        ),
        _buildModernListTile(
          icon: Icons.assessment,
          title: 'Rapport complet',
          subtitle: 'Exporter tout en Excel',
          onTap: () => _exportCombined(),
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildNotificationCard() {
    return _buildModernCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications de rappel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Recevoir des rappels pour les échéances',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true, // Valeur par défaut
                onChanged: (value) => _toggleNotifications(value),
                activeColor: Colors.green.shade600,
              ),
            ],
          ),
        ),
        _buildModernListTile(
          icon: Icons.schedule,
          title: 'Fréquence des rappels',
          subtitle: 'Configurer la fréquence des notifications',
          onTap: () => _showReminderFrequencyDialog(),
          iconColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildDataCard() {
    return _buildModernCard(
      children: [
        _buildModernListTile(
          icon: Icons.sync,
          title: 'Synchroniser les données',
          subtitle: 'Synchroniser avec le cloud',
          onTap: () => _syncData(),
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
        _buildModernListTile(
          icon: Icons.backup,
          title: 'Sauvegarder',
          subtitle: 'Créer une sauvegarde locale',
          onTap: () => _createBackup(),
          iconColor: Colors.orange,
          backgroundColor: Colors.orange.withOpacity(0.1),
        ),
        _buildModernListTile(
          icon: Icons.delete_forever,
          title: 'Supprimer toutes les données',
          subtitle: 'Attention: action irréversible',
          onTap: () => _showDeleteAllDialog(),
          iconColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.1),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authService.signOutCompletely();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBiometric(bool value) {
    if (value) {
      securityService.enableSecurity();
    } else {
      securityService.disableSecurity();
    }
  }

  void _setupPIN() async {
    final isFirstSetup = !securityService.isPinEnabled.value;

    print(
        '📍 Settings: Lancement de ${isFirstSetup ? "configuration" : "modification"} PIN');

    // Fonction de callback pour la mise à jour
    void onPinSetupComplete() async {
      print('📍 Settings: Callback de mise à jour déclenché');
      await securityService.reloadSecuritySettings();

      Future.delayed(const Duration(milliseconds: 800), () {
        Get.snackbar(
          'Configuration terminée ✓',
          isFirstSetup
              ? 'Votre code PIN a été configuré avec succès. L\'application est maintenant sécurisée.'
              : 'Votre code PIN a été modifié avec succès.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.security, color: Colors.white),
        );
      });
    }

    // Naviguer vers l'écran de configuration PIN et attendre le résultat
    final result = await Get.to(
      () => PinSetupScreen(
        isFirstSetup: isFirstSetup,
        onPinSetupComplete: isFirstSetup ? null : onPinSetupComplete,
      ),
      // Retirer fullscreenDialog pour éviter les problèmes de résultat
    );

    print(
        '📍 Settings: Retour de PIN Setup avec résultat: $result (type: ${result.runtimeType})');

    // Vérifier si la configuration a réussi (ancien format true ou nouveau format Map)
    bool isSuccess = false;
    if (result == true) {
      isSuccess = true;
    } else if (result is Map && result['success'] == true) {
      isSuccess = true;
    }

    if (isSuccess && isFirstSetup) {
      // Seulement pour la première configuration, car la modification utilise le callback
      print(
          '📍 Settings: Mise à jour des paramètres de sécurité (première config)');
      await securityService.reloadSecuritySettings();
    } else if (!isSuccess) {
      print('📍 Settings: Configuration PIN annulée ou échouée');
    }
  }

  void _toggleNotifications(bool value) {
    Get.snackbar(
      value ? 'Notifications activées' : 'Notifications désactivées',
      'Les paramètres de notification ont été mis à jour',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _syncData() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Simuler la synchronisation
    Future.delayed(const Duration(seconds: 2), () {
      // Fermer le dialog seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      controller.reloadData();
      Get.snackbar(
        'Synchronisation terminée',
        'Vos données ont été synchronisées avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  void _exportDebtsToPDF() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Utiliser la liste des dettes du contrôleur
      await exportService.exportToPdf(controller.debts, 'debt');

      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les dettes en PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _exportCreditsToPDF() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Utiliser la liste des crédits du contrôleur
      await exportService.exportToPdf(controller.credits, 'credit');

      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les crédits en PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _exportDebtsToExcel() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Utiliser la liste des dettes du contrôleur
      await exportService.exportToExcel(controller.debts, 'debt');

      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les dettes en Excel: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _exportCreditsToExcel() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Utiliser la liste des crédits du contrôleur
      await exportService.exportToExcel(controller.credits, 'credit');

      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les crédits en Excel: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _exportCombined() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Utiliser les listes du contrôleur
      await exportService.exportCombined(controller.debts, controller.credits);

      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter le rapport complet: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showReminderFrequencyDialog() {
    int selectedFrequency = 7; // Valeur par défaut

    Get.dialog(
      AlertDialog(
        title: const Text('Fréquence des rappels'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Quotidien'),
                  leading: Radio<int>(
                    value: 1,
                    groupValue: selectedFrequency,
                    onChanged: (value) {
                      setState(() => selectedFrequency = value!);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Hebdomadaire'),
                  leading: Radio<int>(
                    value: 7,
                    groupValue: selectedFrequency,
                    onChanged: (value) {
                      setState(() => selectedFrequency = value!);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Mensuel'),
                  leading: Radio<int>(
                    value: 30,
                    groupValue: selectedFrequency,
                    onChanged: (value) {
                      setState(() => selectedFrequency = value!);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Fréquence mise à jour',
                'Les rappels seront envoyés tous les ${selectedFrequency == 1 ? 'jours' : selectedFrequency == 7 ? 'semaines' : 'mois'}',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _createBackup() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Simuler la création d'une sauvegarde
      await Future.delayed(const Duration(seconds: 2));

      // Fermer le dialog de chargement seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Sauvegarde créée',
        'Vos données ont été sauvegardées avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Fermer le dialog seulement s'il est ouvert
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Erreur',
        'Impossible de créer la sauvegarde: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteAllDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer toutes les données'),
        content: const Text(
          'Cette action supprimera définitivement toutes vos données. '
          'Cette action est irréversible. Êtes-vous sûr ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    // Vider les listes
    controller.debts.clear();
    controller.credits.clear();
    controller.filteredDebts.clear();
    controller.filteredCredits.clear();

    // Recalculer les totaux
    controller.totalDebts.value = 0.0;
    controller.totalCredits.value = 0.0;

    Get.snackbar(
      'Données supprimées',
      'Toutes les données ont été supprimées',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _disableSecurity() {
    securityService.disableSecurity();
  }
}
