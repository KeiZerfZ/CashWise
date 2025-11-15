import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/pages/add_edit_budget_page.dart';
import 'package:cashwise/features/budgeting/presentation/pages/budget_page.dart';
import 'package:cashwise/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:cashwise/features/transaction/presentation/pages/transaction_history_page.dart';
import 'package:cashwise/features/saving_goal/presentation/pages/add_edit_goal_page.dart';
import 'package:cashwise/features/saving_goal/presentation/pages/saving_goal_page.dart';
import 'package:cashwise/presentation/pages/home_page.dart';
import 'package:cashwise/presentation/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Halaman-halaman ini sekarang bakal "tetap hidup"
  // berkat IndexedStack di bawah
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const TransactionHistoryPage(),
    const BudgetPage(),
    const SavingGoalPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
  }

  void _navigateToAddBudget() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetBloc>(),
        child: AddEditBudgetPage(selectedDate: DateTime.now()),
      ),
    ));
  }

  void _navigateToAddGoal() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<SavingGoalBloc>(),
        child: const AddEditGoalPage(),
      ),
    ));
  }

  Widget? _buildFab() {
    final bool isVisible =
        (_selectedIndex == 0 || _selectedIndex == 2 || _selectedIndex == 3);
    Color fabColor = const Color(0xFF3A86FF);
    if (_selectedIndex == 2) fabColor = Colors.teal;
    if (_selectedIndex == 3) fabColor = Colors.green;

    return Visibility(
      visible: isVisible,
      child: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            _navigateToAddTransaction();
          } else if (_selectedIndex == 2) {
            _navigateToAddBudget();
          } else if (_selectedIndex == 3) {
            _navigateToAddGoal();
          }
        },
        backgroundColor: fabColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // =================================================================
      // INI DIA PERBAIKAN STUTTER-NYA!
      // =================================================================
      // Kita ganti 'body: _widgetOptions.elementAt(_selectedIndex)'
      // jadi 'IndexedStack'
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // =================================================================

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Celengan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3A86FF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),

      floatingActionButton: _buildFab(),
      // (Komentar lu soal ganti ke centerFloat udah bener, gua biarin)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}