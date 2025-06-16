import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../controllers/debt_credit_controller.dart';
import '../models/debt_credit_item.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DebtCreditController controller = Get.find();
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('fr_FR', null);
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
      }
    } catch (e) {
      print('Erreur d\'initialisation de la locale fr_FR: $e');
      // Essayer avec 'fr' seulement
      try {
        await initializeDateFormatting('fr', null);
        if (mounted) {
          setState(() {
            _isLocaleInitialized = true;
          });
        }
      } catch (e2) {
        print('Erreur d\'initialisation de la locale fr: $e2');
        if (mounted) {
          setState(() {
            _isLocaleInitialized = false;
          });
        }
      }
    }
  }

  String _formatDate(DateTime date, {String? locale}) {
    try {
      if (_isLocaleInitialized) {
        // Essayer d'abord avec fr_FR, puis fr
        try {
          return DateFormat('MMM', locale ?? 'fr_FR').format(date);
        } catch (e) {
          return DateFormat('MMM', 'fr').format(date);
        }
      } else {
        return DateFormat('MMM').format(date);
      }
    } catch (e) {
      return DateFormat('MMM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Statistiques',
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
                      Colors.purple.shade600,
                      Colors.purple.shade800,
                      Colors.indigo.shade700,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Analyse de vos finances',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenu des statistiques
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Résumé rapide
                    _buildQuickSummary(),
                    const SizedBox(height: 30),

                    // Graphique de contributions (style GitHub)
                    _buildContributionGraph(),
                    const SizedBox(height: 30),

                    // Graphiques en secteurs
                    _buildPieCharts(),
                    const SizedBox(height: 30),

                    // Statistiques détaillées
                    _buildDetailedStats(),
                    const SizedBox(height: 30),

                    // Tendances mensuelles
                    _buildMonthlyTrends(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    return Obx(() {
      final totalDebts = controller.totalDebts.value;
      final totalCredits = controller.totalCredits.value;
      final balance = totalCredits - totalDebts;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé financier',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Dettes',
                  '${NumberFormat('#,###').format(totalDebts)} FDJ',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Crédits',
                  '${NumberFormat('#,###').format(totalCredits)} FDJ',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Balance',
            '${NumberFormat('#,###').format(balance.abs())} FDJ',
            balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
            balance >= 0 ? Colors.blue : Colors.orange,
            subtitle:
                balance >= 0 ? 'Vous êtes créditeur' : 'Vous êtes débiteur',
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContributionGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité financière (12 derniers mois)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildContributionCalendar(),
              const SizedBox(height: 16),
              _buildContributionLegend(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContributionCalendar() {
    return Obx(() {
      final now = DateTime.now();
      final startDate = DateTime(now.year - 1, now.month, now.day);
      final contributions = _getContributionData(startDate, now);

      return Column(
        children: [
          // En-têtes des mois
          _buildMonthHeaders(startDate),
          const SizedBox(height: 8),
          // Grille de contributions
          _buildContributionGrid(contributions, startDate),
        ],
      );
    });
  }

  Widget _buildMonthHeaders(DateTime startDate) {
    final months = <String>[];
    var current = DateTime(startDate.year, startDate.month, 1);
    final end = DateTime.now();

    while (current.isBefore(end) || current.month == end.month) {
      months.add(_formatDate(current));
      current = DateTime(current.year, current.month + 1, 1);
    }

    return Row(
      children: [
        const SizedBox(width: 20), // Espace pour les jours de la semaine
        ...months.map((month) => Expanded(
              child: Text(
                month,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            )),
      ],
    );
  }

  Widget _buildContributionGrid(
      Map<String, ContributionData> contributions, DateTime startDate) {
    final weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final weeks = <List<DateTime>>[];

    // Générer les semaines
    var current = startDate;
    final end = DateTime.now();

    while (current.isBefore(end) || current.day == end.day) {
      final week = <DateTime>[];
      final startOfWeek = current.subtract(Duration(days: current.weekday - 1));

      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        if (day.isAfter(startDate.subtract(const Duration(days: 1))) &&
            day.isBefore(end.add(const Duration(days: 1)))) {
          week.add(day);
        }
      }

      if (week.isNotEmpty) {
        weeks.add(week);
      }

      current = current.add(const Duration(days: 7));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jours de la semaine
        Column(
          children: weekDays
              .map((day) => Container(
                    width: 20,
                    height: 12,
                    margin: const EdgeInsets.all(1),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
        // Grille des contributions
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weeks
                  .map((week) => Column(
                        children: week.map((day) {
                          final key = DateFormat('yyyy-MM-dd').format(day);
                          final contribution = contributions[key];
                          return _buildContributionSquare(contribution);
                        }).toList(),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContributionSquare(ContributionData? contribution) {
    Color color = Colors.grey.shade200;

    if (contribution != null) {
      if (contribution.debts > 0 && contribution.credits > 0) {
        // Mixte - couleur orange
        color = Colors.orange.shade300;
      } else if (contribution.debts > 0) {
        // Seulement des dettes - rouge
        final intensity = (contribution.debts / 50000).clamp(0.2, 1.0);
        color = Colors.red.withOpacity(intensity);
      } else if (contribution.credits > 0) {
        // Seulement des crédits - vert
        final intensity = (contribution.credits / 50000).clamp(0.2, 1.0);
        color = Colors.green.withOpacity(intensity);
      }
    }

    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContributionLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Moins',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final opacity = (index + 1) * 0.2;
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: index == 0
                  ? Colors.grey.shade200
                  : Colors.green.withOpacity(opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'Plus',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 16),
        // Légende des couleurs
        Row(
          children: [
            _buildLegendItem('Dettes', Colors.red),
            const SizedBox(width: 12),
            _buildLegendItem('Crédits', Colors.green),
            const SizedBox(width: 12),
            _buildLegendItem('Mixte', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPieCharts() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition par personne',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDebtsPieChart()),
              const SizedBox(width: 20),
              Expanded(child: _buildCreditsPieChart()),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildDebtsPieChart() {
    final debtsMap = <String, double>{};
    for (final debt in controller.debts) {
      debtsMap[debt.personName] =
          (debtsMap[debt.personName] ?? 0) + debt.amount;
    }

    return _buildPieChartWidget(
      'Dettes par personne',
      debtsMap,
      Colors.red,
    );
  }

  Widget _buildCreditsPieChart() {
    final creditsMap = <String, double>{};
    for (final credit in controller.credits) {
      creditsMap[credit.personName] =
          (creditsMap[credit.personName] ?? 0) + credit.amount;
    }

    return _buildPieChartWidget(
      'Crédits par personne',
      creditsMap,
      Colors.green,
    );
  }

  Widget _buildPieChartWidget(
      String title, Map<String, double> data, Color baseColor) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline,
                  color: Colors.grey.shade400, size: 48),
              const SizedBox(height: 8),
              Text(
                'Aucune donnée',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Graphique simplifié
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                '${NumberFormat('#,###').format(total)}\nFDJ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Légende
          ...sortedEntries.take(3).map((entry) {
            final percentage = (entry.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Obx(() {
      final allItems = [...controller.debts, ...controller.credits];
      final peopleCount =
          allItems.map((item) => item.personName).toSet().length;
      final avgDebt = controller.debts.isEmpty
          ? 0.0
          : controller.totalDebts.value / controller.debts.length;
      final avgCredit = controller.credits.isEmpty
          ? 0.0
          : controller.totalCredits.value / controller.credits.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques détaillées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Personnes',
                  peopleCount.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Transactions',
                  allItems.length.toString(),
                  Icons.receipt_long,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Dette moyenne',
                  '${NumberFormat('#,###').format(avgDebt)} FDJ',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Crédit moyen',
                  '${NumberFormat('#,###').format(avgCredit)} FDJ',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tendances mensuelles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Text(
                'Évolution sur les 6 derniers mois',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              _buildSimpleBarChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleBarChart() {
    final monthlyData = _getMonthlyData();
    final maxValue =
        monthlyData.values.fold(0.0, (max, value) => value > max ? value : max);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthlyData.entries.map((entry) {
          final height = maxValue > 0 ? (entry.value / maxValue) * 120 : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, ContributionData> _getContributionData(
      DateTime startDate, DateTime endDate) {
    final contributions = <String, ContributionData>{};
    final allItems = [...controller.debts, ...controller.credits];

    for (final item in allItems) {
      if (item.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          item.date.isBefore(endDate.add(const Duration(days: 1)))) {
        final key = DateFormat('yyyy-MM-dd').format(item.date);
        contributions[key] ??= ContributionData();

        if (item.isDebt) {
          contributions[key]!.debts += item.amount;
        } else {
          contributions[key]!.credits += item.amount;
        }
      }
    }

    return contributions;
  }

  Map<String, double> _getMonthlyData() {
    final monthlyData = <String, double>{};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = _formatDate(month);
      monthlyData[monthKey] = 0.0;
    }

    final allItems = [...controller.debts, ...controller.credits];
    for (final item in allItems) {
      final monthKey = _formatDate(item.date);
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = monthlyData[monthKey]! + item.amount;
      }
    }

    return monthlyData;
  }
}

class ContributionData {
  double debts = 0.0;
  double credits = 0.0;
}
