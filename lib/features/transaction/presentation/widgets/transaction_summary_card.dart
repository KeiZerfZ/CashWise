import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionSummaryCard extends StatelessWidget {
  final List<dynamic> transactions; // Kita buat dynamic dulu biar gampang

  const TransactionSummaryCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Hitung total pemasukan dan pengeluaran
    double totalIncome = 0;
    double totalExpense = 0;

    for (var trx in transactions) {
      if (trx.isExpense) {
        totalExpense += trx.amount;
      } else {
        totalIncome += trx.amount;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sisa Saldo',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(totalIncome - totalExpense),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpense('Pemasukan', totalIncome, Icons.arrow_upward_rounded, Colors.greenAccent.shade100),
              _buildIncomeExpense('Pengeluaran', totalExpense, Icons.arrow_downward_rounded, Colors.redAccent.shade100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpense(String title, double amount, IconData icon, Color color) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(formatter.format(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}