// lib/features/saving_goal/presentation/widgets/saving_goal_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal_with_details.dart';

class SavingGoalListItem extends StatelessWidget {
  final SavingGoalWithDetails goalWithDetails;
  final VoidCallback onTap;

  const SavingGoalListItem({
    super.key,
    required this.goalWithDetails,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final formatCurrency =
        NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp');
    final formatCurrencyFull =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final goal = goalWithDetails.goal;
    final double progress = goalWithDetails.progress;
    
    // --- REFAKTOR: Bikin warna semantik jadi theme-aware ---
    final Color progressColor = goalWithDetails.isAchieved
        ? (isLightMode ? Colors.green.shade600 : Colors.green.shade300)
        : theme.primaryColor;

    return Card(
      // --- REFAKTOR: Hapus elevation/shadow, biarin CardTheme ---
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15), // (Samain sama CardTheme)
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                // --- REFAKTOR: Ganti style hardcode ---
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              // --- Progress Bar ---
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  // --- REFAKTOR: Ganti warna hardcode ---
                  backgroundColor: theme.dividerColor.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 12),
              // --- Info Teks: Terkumpul / Target ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      text: formatCurrencyFull
                          .format(goalWithDetails.totalContribution),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: progressColor, // (Ini SEMANTIK, udah bener)
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${formatCurrency.format(goal.targetAmount)}',
                          // --- REFAKTOR: Ganti style/warna hardcode ---
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor, // (Ini SEMANTIK, udah bener)
                    ),
                  ),
                ],
              ),
              if (goal.targetDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // --- REFAKTOR: Ganti warna hardcode ---
                    Icon(Icons.calendar_today,
                        size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Target: ${DateFormat('d MMM yyyy', 'id_ID').format(goal.targetDate!)}',
                      // --- REFAKTOR: Ganti style/warna hardcode ---
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}