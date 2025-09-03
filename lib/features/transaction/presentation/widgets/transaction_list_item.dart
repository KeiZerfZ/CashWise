import 'package:flutter/material.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Palet warna baru yang lebih soft
    final color = transaction.isExpense ? const Color(0xFFE57373) : const Color(0xFF81C784); // Merah & Hijau pastel
    final icon = transaction.isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final amountString = (transaction.isExpense ? '- Rp' : '+ Rp') + formatter.format(transaction.amount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Rounded corner lebih besar
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMM yyyy').format(transaction.transactionDate), // Format tanggal lebih deskriptif
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amountString,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900, // Font lebih tebal
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}