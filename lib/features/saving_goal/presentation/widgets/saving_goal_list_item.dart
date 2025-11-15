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
    final formatCurrency = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp');
    final formatCurrencyFull = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final goal = goalWithDetails.goal;
    final double progress = goalWithDetails.progress;
    final Color progressColor = goalWithDetails.isAchieved ? Colors.green : Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // --- Progress Bar ---
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
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
                      text: formatCurrencyFull.format(goalWithDetails.totalContribution),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: progressColor,
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${formatCurrency.format(goal.targetAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade600,
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
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              if (goal.targetDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Target: ${DateFormat('d MMM yyyy', 'id_ID').format(goal.targetDate!)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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