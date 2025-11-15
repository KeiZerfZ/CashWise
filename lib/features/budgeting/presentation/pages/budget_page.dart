// lib/features/budgeting/presentation/pages/budget_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/presentation/pages/add_edit_budget_page.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_event.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_state.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    context.read<BudgetBloc>().add(
        LoadBudgetsEvent(month: _selectedDate.month, year: _selectedDate.year));
  }

  void _changeMonth(int monthOffset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthOffset);
    });
    context.read<BudgetBloc>().add(
        LoadBudgetsEvent(month: _selectedDate.month, year: _selectedDate.year));
  }

  void _navigateToAddEditPage({Budget? budget}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetBloc>(),
        child: AddEditBudgetPage(
          budget: budget,
          selectedDate: _selectedDate,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor', biarin theme ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => _changeMonth(-1)),
            Text(
              DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: () => _changeMonth(1)),
          ],
        ),
        centerTitle: true,
        // --- REFAKTOR: Hapus semua styling, biarin 'AppBarTheme' ---
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, budgetState) {
          if (budgetState is BudgetLoading || budgetState is BudgetInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (budgetState is BudgetError) {
            return Center(
                child: Text('Terjadi Kesalahan: ${budgetState.message}'));
          }
          if (budgetState is BudgetLoaded) {
            if (budgetState.budgets.isEmpty) {
              return const Center(
                  child: Text('Belum ada budget untuk bulan ini.'));
            }
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: budgetState.budgets.length,
              itemBuilder: (context, index) {
                final budget = budgetState.budgets[index];
                return _BudgetCard(
                  budget: budget,
                  onTap: () {
                    final simpleBudget = Budget(
                        id: budget.id,
                        categoryId: budget.category.id,
                        amount: budget.amount,
                        month: _selectedDate.month,
                        year: _selectedDate.year);
                    _navigateToAddEditPage(budget: simpleBudget);
                  },
                  onDelete: () {
                    context.read<BudgetBloc>().add(DeleteBudgetEvent(
                          budgetId: budget.id,
                          month: _selectedDate.month,
                          year: _selectedDate.year,
                        ));
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// =================================================================
// WIDGET KARTU BUDGET (INI KITA REFAKTOR WARNA-NYA)
// =================================================================
class _BudgetCard extends StatelessWidget {
  final BudgetWithSpending budget;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.onTap,
    required this.onDelete,
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

    final double amount = budget.amount;
    final double spent = budget.spentAmount;
    final double remaining = amount - spent;
    final double progress = amount > 0 ? (spent / amount).clamp(0, 1) : 0;

    final bool isOverBudget = spent > amount;

    // --- REFAKTOR: Bikin warna semantik jadi theme-aware ---
    final Color progressColor = isOverBudget
        ? (isLightMode ? Colors.red.shade400 : Colors.red.shade300)
        : Colors.teal; // Teal itu semantik budget, biarin
    
    final Color overBudgetTextColor = isLightMode ? Colors.red.shade700 : Colors.red.shade400;

    return Card(
      // --- REFAKTOR: Hapus 'elevation' & 'shadowColor', biarin CardTheme ---
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15), // (Sesuaiin sama shape card)
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // (Warna circle avatar biarin, semantik by category color)
                  CircleAvatar(
                    backgroundColor: budget.category.color.withOpacity(0.1),
                    foregroundColor: budget.category.color,
                    child: Icon(getIconDataFromString(budget.category.iconName)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category.name,
                          // --- REFAKTOR: Ganti style hardcode ---
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            text: formatCurrencyFull.format(spent),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: progressColor, // Warna semantik
                            ),
                            children: [
                              TextSpan(
                                text: ' / ${formatCurrency.format(amount)}',
                                // --- REFAKTOR: Ganti style & warna hardcode ---
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    // --- REFAKTOR: Ganti warna hardcode ---
                    icon: Icon(Icons.delete_outline,
                        color: colorScheme.onSurfaceVariant),
                    onPressed: onDelete,
                    tooltip: 'Hapus Budget',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              if (isOverBudget)
                Text(
                  '${formatCurrencyFull.format(remaining.abs())} Melebihi Budget!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: overBudgetTextColor, // Warna semantik
                  ),
                )
              else
                Text(
                  '${formatCurrencyFull.format(remaining)} Tersisa',
                  // --- REFAKTOR: Ganti style & warna hardcode ---
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}