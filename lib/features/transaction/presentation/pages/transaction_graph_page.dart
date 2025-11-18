// lib/features/transaction/presentation/pages/transaction_graph_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart';

class TransactionGraphPage extends StatefulWidget {
  final String graphTitle;
  final List<Transaction> transactionsForGraph;
  final List<Category> allCategories;

  const TransactionGraphPage({
    super.key,
    required this.graphTitle,
    required this.transactionsForGraph,
    required this.allCategories,
  });

  @override
  State<TransactionGraphPage> createState() => _TransactionGraphPageState();
}

class _TransactionGraphPageState extends State<TransactionGraphPage> {
  List<Category> _selectedCategories = [];
  bool _showExpenseChart = true;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.allCategories);
  }

  double _calculateTotal(bool isExpense) {
    return widget.transactionsForGraph
        .where((t) {
          final bool matchesType = t.isExpense == isExpense;
          final bool matchesCategory =
              _selectedCategories.any((c) => c.id == t.categoryId);
          return matchesType && matchesCategory;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<PieChartSectionData> _getPieChartSections(bool isExpense) {
    final theme = Theme.of(context);

    final Map<int, double> categoryAmounts = {};
    final filteredTransactions =
        widget.transactionsForGraph.where((t) => t.isExpense == isExpense);

    for (var transaction in filteredTransactions) {
      if (transaction.categoryId != null) {
        final bool isCategorySelected =
            _selectedCategories.any((c) => c.id == transaction.categoryId);
        if (isCategorySelected) {
          categoryAmounts.update(
              transaction.categoryId!, (value) => value + transaction.amount,
              ifAbsent: () => transaction.amount);
        }
      }
    }

    final List<PieChartSectionData> sections = [];
    final totalAmount =
        categoryAmounts.values.fold(0.0, (sum, item) => sum + item);

    if (totalAmount == 0) {
      return [
        PieChartSectionData(
          color: theme.dividerColor,
          value: 100,
          title: '0%',
          radius: 60,
          titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant),
        )
      ];
    }

    for (var entry in categoryAmounts.entries) {
      final category =
          widget.allCategories.firstWhere((c) => c.id == entry.key);
      final percentage = (entry.value / totalAmount) * 100;
      if (percentage < 3 && categoryAmounts.length > 5) continue;

      sections.add(
        PieChartSectionData(
          color: category.color,
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _buildCategoryBadge(category),
          badgePositionPercentageOffset: 1.2,
        ),
      );
    }
    sections.sort((a, b) => b.value.compareTo(a.value));
    return sections;
  }

  Widget _buildCategoryBadge(Category category) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Icon(
        getIconDataFromString(category.iconName),
        color: Colors.white,
        size: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalExpense = widget.transactionsForGraph
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = widget.transactionsForGraph
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.graphTitle,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildBalanceSummary(
                totalIncome, totalExpense, netBalance, currencyFormatter),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildChartTypeToggle(
                    title: 'Pengeluaran',
                    isSelected: _showExpenseChart,
                    onTap: () => setState(() => _showExpenseChart = true),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChartTypeToggle(
                    title: 'Pemasukan',
                    isSelected: !_showExpenseChart,
                    onTap: () => setState(() => _showExpenseChart = false),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1.3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              return;
                            }
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: _getPieChartSections(_showExpenseChart),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter Kategori',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildCategoryFilterList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSummary(double totalIncome, double totalExpense,
      double netBalance, NumberFormat formatter) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final Color incomeColor =
        isLightMode ? Colors.green.shade700 : Colors.green.shade300;
    final Color expenseColor =
        isLightMode ? Colors.red.shade700 : Colors.red.shade300;
    final Color netColor = netBalance >= 0
        ? (isLightMode ? Colors.green.shade800 : Colors.green.shade300)
        : (isLightMode ? Colors.red.shade800 : Colors.red.shade300);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pemasukan',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(
                  formatter.format(totalIncome),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: incomeColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pengeluaran',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(
                  formatter.format(totalExpense),
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: expenseColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo Bersih',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  formatter.format(netBalance),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: netColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeToggle({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    // --- FIX DI SINI: Ganti 'Color' jadi 'MaterialColor' ---
    required MaterialColor color,
  }) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    // (Kode di bawah ini sekarang aman karena 'color' adalah MaterialColor)
    final Color semanticColor = isLightMode ? color.shade700 : color.shade300;
    final Color semanticBg =
        isLightMode ? color.shade50 : color.shade900.withOpacity(0.3);
    final Color borderColor =
        isLightMode ? Colors.grey.shade300 : theme.dividerColor;
    final Color textColor =
        isLightMode ? Colors.grey.shade700 : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? semanticBg : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? semanticColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? semanticColor : textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredCategories = widget.allCategories;

    if (filteredCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'Tidak ada kategori.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final isCategorySelected =
            _selectedCategories.any((c) => c.id == category.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCategorySelected ? category.color : theme.dividerColor,
              width: isCategorySelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isCategorySelected) {
                  _selectedCategories.removeWhere((c) => c.id == category.id);
                } else {
                  _selectedCategories.add(category);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: category.color.withOpacity(0.1),
                    foregroundColor: category.color,
                    child: Icon(getIconDataFromString(category.iconName)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: isCategorySelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCategorySelected
                            ? category.color
                            : colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: isCategorySelected,
                    onChanged: (bool? newValue) {
                      setState(() {
                        if (newValue == true) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories
                              .removeWhere((c) => c.id == category.id);
                        }
                      });
                    },
                    activeColor: category.color,
                    checkColor: Colors.white,
                    side: BorderSide(color: theme.dividerColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}