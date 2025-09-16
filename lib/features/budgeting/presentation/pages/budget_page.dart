import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/presentation/pages/add_edit_budget_page.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_event.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_state.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';

IconData _getIconForName(String iconName) {
  final Map<String, IconData> iconMap = {'restaurant': Icons.restaurant, 'shopping_cart': Icons.shopping_cart, 'commute': Icons.commute, 'sports_esports': Icons.sports_esports};
  return iconMap[iconName] ?? Icons.help;
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _changeMonth(-1)),
            Text(DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)),
            IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _changeMonth(1)),
          ],
        ),
        centerTitle: true,
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: budgetState.budgets.length,
              itemBuilder: (context, index) {
                final budget = budgetState.budgets[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: budget.category.color,
                    child: Icon(_getIconForName(budget.category.iconName), color: Colors.white),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(budget.category.name),
                      Text(
                        '${NumberFormat.compactCurrency(locale: 'id_ID', symbol: '').format(budget.spentAmount)} / ${NumberFormat.compactCurrency(locale: 'id_ID', symbol: '').format(budget.amount)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(
                      value: budget.amount > 0 ? (budget.spentAmount / budget.amount).clamp(0, 1) : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.spentAmount > budget.amount ? Colors.red.shade400 : Colors.teal,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.grey.shade500),
                    onPressed: () {
                      context.read<BudgetBloc>().add(DeleteBudgetEvent(
                        budgetId: budget.id,
                        month: _selectedDate.month,
                        year: _selectedDate.year,
                      ));
                    },
                  ),
                  onTap: () {
                    final simpleBudget = Budget(
                      id: budget.id, 
                      categoryId: budget.category.id, 
                      amount: budget.amount, 
                      month: _selectedDate.month, 
                      year: _selectedDate.year
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<BudgetBloc>(),
                        child: AddEditBudgetPage(budget: simpleBudget, selectedDate: _selectedDate),
                      ),
                    ));
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<BudgetBloc>(),
              child: AddEditBudgetPage(selectedDate: _selectedDate),
            ),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}