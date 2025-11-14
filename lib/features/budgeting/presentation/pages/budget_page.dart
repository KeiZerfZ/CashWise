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
    context.read<BudgetBloc>().add(LoadBudgetsEvent(month: _selectedDate.month, year: _selectedDate.year));
  }

  void _changeMonth(int monthOffset) {
    setState(() { _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthOffset); });
    context.read<BudgetBloc>().add(LoadBudgetsEvent(month: _selectedDate.month, year: _selectedDate.year));
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => _changeMonth(-1)),
            Text(
              DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 20), onPressed: () => _changeMonth(1)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        // =================================================================
        // TOMBOL "ACTIONS" DIHAPUS DARI SINI
        // =================================================================
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, budgetState) {
          if (budgetState is BudgetLoading || budgetState is BudgetInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (budgetState is BudgetError) {
            return Center(child: Text('Terjadi Kesalahan: ${budgetState.message}'));
          }
          if (budgetState is BudgetLoaded) {
            if (budgetState.budgets.isEmpty) {
              return const Center(child: Text('Belum ada budget untuk bulan ini.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      year: _selectedDate.year
                    );
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
      // =================================================================
      // FLOATING ACTION BUTTON DIHAPUS DARI SINI
      // =================================================================
    );
  }
}

// =================================================================
// WIDGET KARTU BUDGET (TIDAK BERUBAH)
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
    final formatCurrency = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp');
    final formatCurrencyFull = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final double amount = budget.amount;
    final double spent = budget.spentAmount;
    final double remaining = amount - spent;
    final double progress = amount > 0 ? (spent / amount).clamp(0, 1) : 0;
    
    final bool isOverBudget = spent > amount;
    final Color progressColor = isOverBudget ? Colors.red.shade400 : Colors.teal;

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            text: formatCurrencyFull.format(spent),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: progressColor,
                            ),
                            children: [
                              TextSpan(
                                text: ' / ${formatCurrency.format(amount)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.grey.shade500),
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
                  backgroundColor: Colors.grey.shade300,
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
                    color: Colors.red.shade700,
                  ),
                )
              else
                Text(
                  '${formatCurrencyFull.format(remaining)} Tersisa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}