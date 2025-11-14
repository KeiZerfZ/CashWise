import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/presentation/widgets/transaction_pie_chart.dart';

class TransactionGraphPage extends StatelessWidget {
  // BARU: Constructor-nya berubah
  final String graphTitle; // Terima judul yang sudah jadi
  final List<Transaction> transactionsForGraph; // Terima data yang sudah di-filter
  final List<Category> allCategories;

  const TransactionGraphPage({
    super.key,
    required this.graphTitle,
    required this.transactionsForGraph,
    required this.allCategories,
  });

  @override
  Widget build(BuildContext context) {
    
    // =================================================================
    // LOGIKA FILTER BULANAN DIHAPUS. KITA LANGSUNG OLAH DATA
    // =================================================================
    
    // 1a. Filter transaksi PENGELUARAN dari data yang sudah di-filter
    final monthlyExpenses = transactionsForGraph.where((t) => t.isExpense).toList();

    // 1b. Kelompokkan total pengeluaran berdasarkan categoryId
    final Map<int, double> spendingByCategory = {};
    for (var expense in monthlyExpenses) {
      if (expense.categoryId != null) {
        spendingByCategory.update(
          expense.categoryId!,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    // 1c. Hitung total semua pengeluaran
    final double totalSpending = spendingByCategory.values.fold(0, (sum, amount) => sum + amount);

    // =================================================================
    // LANGKAH 2: OLAH DATA PEMASUKAN
    // =================================================================
    
    // 2a. Filter transaksi PEMASUKAN dari data yang sudah di-filter
    final monthlyIncome = transactionsForGraph.where((t) => !t.isExpense).toList();

    // 2b. Hitung total semua pemasukan
    final double totalIncome = monthlyIncome.fold(0, (sum, transaction) => sum + transaction.amount);
    
    // =================================================================
    // LANGKAH 3: SIAPKAN DATA PIE CHART
    // =================================================================
    final pieChartData = spendingByCategory.entries.map((entry) {
      final categoryId = entry.key;
      final amount = entry.value;
      Category category;
      try {
        category = allCategories.firstWhere((c) => c.id == categoryId);
      } catch (e) {
        category = Category(id: 0, name: 'Lainnya', color: Colors.grey, iconName: 'help');
      }
      final percentage = (totalSpending > 0) ? (amount / totalSpending) * 100 : 0.0;

      return PieChartSectionData(
        value: amount,
        title: '${percentage.toStringAsFixed(0)}%',
        color: category.color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();

    // Hitung sisa saldo
    final double netBalance = totalIncome - totalSpending;

    return Scaffold(
      appBar: AppBar(
        // BARU: Gunakan judul yang dikirim
        title: Text(graphTitle),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: (monthlyExpenses.isEmpty && monthlyIncome.isEmpty)
          ? const Center(child: Text('Tidak ada data untuk ditampilkan.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // BARU: Judul di-generalisasi
                    'Ringkasan',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    'Sisa Saldo',
                    netBalance,
                    netBalance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  const SizedBox(height: 60), // Jarak aman
                  SizedBox(
                    height: 250,
                    child: _buildIncomeExpenseChart(totalIncome, totalSpending),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Rincian Pengeluaran',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  if (monthlyExpenses.isEmpty)
                    const Center(
                      heightFactor: 5,
                      child: Text('Tidak ada pengeluaran.')
                    )
                  else ...[ 
                    SizedBox(
                      height: 300,
                      child: TransactionPieChart(sections: pieChartData),
                    ),
                    const SizedBox(height: 24),
                    const Text('Legenda:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ...spendingByCategory.entries.map((entry) {
                      Category category;
                      try {
                        category = allCategories.firstWhere((c) => c.id == entry.key);
                      } catch (e) {
                        category = Category(id: 0, name: 'Lainnya', color: Colors.grey, iconName: 'help');
                      }
                      
                      return _LegendItem(
                        color: category.color,
                        text: category.name,
                        amount: entry.value,
                      );
                    }).toList(),
                  ]
                ],
              ),
            ),
    );
  }

  // --- SISA WIDGET DI BAWAH INI TIDAK ADA PERUBAHAN ---

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 1.5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart(double income, double expense) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                String text = '';
                if (value == 0) text = 'Pemasukan';
                if (value == 1) text = 'Pengeluaran';
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: income,
                color: Colors.green,
                width: 40,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 40,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Rp. ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(rod.toY)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final double amount;

  const _LegendItem({required this.color, required this.text, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}