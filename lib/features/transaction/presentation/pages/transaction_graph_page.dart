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
  // State untuk filter kategori
  List<Category> _selectedCategories = [];

  // State untuk toggle pie chart
  bool _showExpenseChart = true; // True untuk pengeluaran, false untuk pemasukan

  @override
  void initState() {
    super.initState();
    // Defaultnya, semua kategori terpilih
    _selectedCategories = List.from(widget.allCategories);
  }

  // Helper untuk menghitung total berdasarkan filter
  double _calculateTotal(bool isExpense) {
    return widget.transactionsForGraph
        .where((t) {
          final bool matchesType = t.isExpense == isExpense;
          // Cek apakah kategori transaksi ini ada di dalam list yang kita pilih
          final bool matchesCategory = _selectedCategories.any((c) => c.id == t.categoryId);
          return matchesType && matchesCategory;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Helper untuk mendapatkan data Pie Chart
  List<PieChartSectionData> _getPieChartSections(bool isExpense) {
    final Map<int, double> categoryAmounts = {};

    // 1. Ambil transaksi yang tipenya sesuai (Pemasukan/Pengeluaran)
    final filteredTransactions = widget.transactionsForGraph.where((t) => t.isExpense == isExpense);

    // 2. Olah datanya
    for (var transaction in filteredTransactions) {
      // FIX 2: Cek kalo categoryId-nya gak null
      if (transaction.categoryId != null) {
        // Cek apakah kategori ini lagi kita filter (ada di _selectedCategories)
        final bool isCategorySelected = _selectedCategories.any((c) => c.id == transaction.categoryId);
        
        if (isCategorySelected) {
          categoryAmounts.update(transaction.categoryId!, (value) => value + transaction.amount,
              ifAbsent: () => transaction.amount);
        }
      }
    }

    final List<PieChartSectionData> sections = [];
    final totalAmount = categoryAmounts.values.fold(0.0, (sum, item) => sum + item); // Total dari yang terfilter aja

    if (totalAmount == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        )
      ];
    }

    for (var entry in categoryAmounts.entries) {
      final category = widget.allCategories.firstWhere((c) => c.id == entry.key);
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
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Hitung total (tanpa filter kategori) untuk ringkasan di atas
    final totalExpense = widget.transactionsForGraph
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = widget.transactionsForGraph
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Analisis Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.graphTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildBalanceSummary(totalIncome, totalExpense, netBalance, currencyFormatter),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildChartTypeToggle(
                    title: 'Pengeluaran',
                    isSelected: _showExpenseChart,
                    onTap: () => setState(() => _showExpenseChart = true),
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChartTypeToggle(
                    title: 'Pemasukan',
                    isSelected: !_showExpenseChart,
                    onTap: () => setState(() => _showExpenseChart = false),
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.3,
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
                    // Panggil helper yang sekarang MENGGUNAKAN _selectedCategories
                    sections: _getPieChartSections(_showExpenseChart),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Filter Kategori', // Judulnya kita buat generik
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildCategoryFilterList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSummary(
      double totalIncome, double totalExpense, double netBalance, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pemasukan', style: TextStyle(color: Colors.grey.shade600)),
              Text(
                formatter.format(totalIncome),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pengeluaran', style: TextStyle(color: Colors.grey.shade600)),
              Text(
                formatter.format(totalExpense),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saldo Bersih', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                formatter.format(netBalance),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: netBalance >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER BARU: List Filter Kategori
  Widget _buildCategoryFilterList() {
    // =================================================================
    // FIX 1: Kita tampilkan SEMUA kategori, gak pake filter isExpense
    // =================================================================
    final filteredCategories = widget.allCategories;

    if (filteredCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'Tidak ada kategori.',
            style: TextStyle(color: Colors.grey),
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
        final isCategorySelected = _selectedCategories.any((c) => c.id == category.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCategorySelected ? category.color : Colors.grey.shade200,
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
                        fontWeight: isCategorySelected ? FontWeight.bold : FontWeight.normal,
                        color: isCategorySelected ? category.color : Colors.black87,
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
                          _selectedCategories.removeWhere((c) => c.id == category.id);
                        }
                      });
                    },
                    activeColor: category.color,
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