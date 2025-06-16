import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/debt_credit_controller.dart';
import '../services/auth_service.dart';
import '../widgets/debt_credit_list.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/add_item_dialog.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DebtCreditController controller;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialiser les services avec Get.find ou Get.put si nécessaire
    try {
      controller = Get.find<DebtCreditController>();
    } catch (e) {
      controller = Get.put(DebtCreditController());
    }

    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      authService = Get.put(AuthService());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 340,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header avec profil et actions
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      authService.currentUserPhoto != null
                                          ? NetworkImage(
                                              authService.currentUserPhoto!)
                                          : null,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  child: authService.currentUserPhoto == null
                                      ? const Icon(Icons.person,
                                          color: Colors.white, size: 30)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bonjour,',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        authService.currentUserName
                                                ?.split(' ')
                                                .first ??
                                            'Utilisateur',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.reloadData(),
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: _handleMenuSelection,
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.white),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'export_pdf',
                                      child: Row(
                                        children: [
                                          Icon(Icons.picture_as_pdf,
                                              color: Colors.red),
                                          SizedBox(width: 12),
                                          Text('Exporter PDF'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'export_excel',
                                      child: Row(
                                        children: [
                                          Icon(Icons.table_chart,
                                              color: Colors.green),
                                          SizedBox(width: 12),
                                          Text('Exporter Excel'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'settings',
                                      child: Row(
                                        children: [
                                          Icon(Icons.settings,
                                              color: Colors.grey),
                                          SizedBox(width: 12),
                                          Text('Paramètres'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout,
                                              color: Colors.orange),
                                          SizedBox(width: 12),
                                          Text('Déconnexion'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Résumé financier
                            GetBuilder<DebtCreditController>(
                              builder: (ctrl) => Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Dettes',
                                      ctrl.formatCurrency(
                                          ctrl.totalDebts.value),
                                      Icons.trending_down,
                                      Colors.red.shade400,
                                      Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Crédits',
                                      ctrl.formatCurrency(
                                          ctrl.totalCredits.value),
                                      Icons.trending_up,
                                      Colors.green.shade400,
                                      Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Barre de recherche
                            SearchBarWidget(
                              onSearchChanged: controller.updateSearchQuery,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.blue.shade600,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.blue.shade600,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Je dois'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('J\'ai prêté'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Stats'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtTab(),
                _buildCreditTab(),
                _buildStatsTab(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddItemDialog,
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.add),
          label: const Text(
            'Ajouter',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon,
      Color iconColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtTab() {
    return Column(
      children: [
        // Liste des dettes
        Expanded(
          child: GetBuilder<DebtCreditController>(
            builder: (ctrl) => DebtCreditList(
              items: ctrl.filteredDebts,
              isDebtList: true,
              onItemTap: _showItemDetails,
              onMarkAsRepaid: ctrl.markAsRepaid,
              onEdit: _showEditItemDialog,
              onDelete: _confirmDelete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditTab() {
    return Column(
      children: [
        // Liste des crédits
        Expanded(
          child: GetBuilder<DebtCreditController>(
            builder: (ctrl) => DebtCreditList(
              items: ctrl.filteredCredits,
              isDebtList: false,
              onItemTap: _showItemDetails,
              onMarkAsRepaid: ctrl.markAsRepaid,
              onEdit: _showEditItemDialog,
              onDelete: _confirmDelete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return const StatisticsScreen();
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export_pdf':
        controller.exportToPDF();
        break;
      case 'export_excel':
        controller.exportToExcel();
        break;
      case 'settings':
        Get.to(() => SettingsScreen());
        break;
      case 'logout':
        _confirmLogout();
        break;
    }
  }

  void _showAddItemDialog() {
    Get.dialog(
      AddItemDialog(
        onAdd: (personName, amount, isDebt, date, notes, reminderDate) {
          controller.addItem(
            personName: personName,
            amount: amount,
            isDebt: isDebt,
            date: date,
            notes: notes,
            reminderDate: reminderDate,
          );
        },
      ),
    );
  }

  void _showEditItemDialog(item) {
    Get.dialog(
      AddItemDialog(
        item: item,
        onAdd: (personName, amount, isDebt, date, notes, reminderDate) {
          item.personName = personName;
          item.amount = amount;
          item.date = date;
          item.notes = notes;
          item.reminderDate = reminderDate;
          controller.updateItem(item);
        },
      ),
    );
  }

  void _showItemDetails(item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.isDebt ? Icons.trending_down : Icons.trending_up,
                  color: item.isDebt ? Colors.red : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  item.personName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (item.isRepaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Remboursé',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Montant', controller.formatCurrency(item.amount)),
            _buildDetailRow('Date', controller.formatDate(item.date)),
            if (item.notes?.isNotEmpty == true)
              _buildDetailRow('Notes', item.notes!),
            if (item.reminderDate != null)
              _buildDetailRow(
                'Rappel',
                controller.formatDate(item.reminderDate!),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showEditItemDialog(item);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: item.isRepaid
                        ? null
                        : () {
                            Get.back();
                            controller.markAsRepaid(item);
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Remboursé'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(item) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cet élément de ${item.personName} ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteItem(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              authService.signOutCompletely();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
