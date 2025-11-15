import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';

class ContributionListItem extends StatelessWidget {
  final SavingContribution contribution;

  const ContributionListItem({super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green.shade700,
          child: const Icon(Icons.arrow_downward),
        ),
        title: Text(
          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(contribution.amount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('EEEE, d MMM yyyy - HH:mm', 'id_ID').format(contribution.transactionDate),
        ),
      ),
    );
  }
}