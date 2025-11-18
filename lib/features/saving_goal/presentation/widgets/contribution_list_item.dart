// lib/features/saving_goal/presentation/widgets/contribution_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';

class ContributionListItem extends StatelessWidget {
  final SavingContribution contribution;

  const ContributionListItem({super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    // --- REFAKTOR: Bikin warna semantik jadi theme-aware ---
    final Color contributionColor = isLightMode ? Colors.green.shade700 : Colors.green.shade300;
    final Color contributionBg = isLightMode ? Colors.green.shade50 : Colors.green.shade900.withOpacity(0.3);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      // --- REFAKTOR: Ganti warna hardcode ---
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // --- REFAKTOR: Ganti border hardcode ---
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          // --- REFAKTOR: Pake warna theme-aware ---
          backgroundColor: contributionBg,
          foregroundColor: contributionColor,
          child: const Icon(Icons.arrow_downward),
        ),
        title: Text(
          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
              .format(contribution.amount),
          // --- REFAKTOR: Ganti style hardcode ---
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          DateFormat('EEEE, d MMM yyyy - HH:mm', 'id_ID')
              .format(contribution.transactionDate),
          // --- REFAKTOR: Ganti style hardcode ---
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}