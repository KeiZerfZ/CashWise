import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart'; // Import BudgetBloc
import 'package:cashwise/features/budgeting/presentation/pages/add_edit_budget_page.dart';
import 'package:cashwise/features/budgeting/presentation/pages/budget_page.dart';
import 'package:cashwise/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:cashwise/features/transaction/presentation/pages/transaction_history_page.dart';
import 'package:cashwise/presentation/pages/home_page.dart';
import 'package:cashwise/presentation/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const TransactionHistoryPage(),
    const BudgetPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // =================================================================
  // BAGIAN "OTAK" BARU-NYA
  // =================================================================

  // Fungsi untuk tombol + di Beranda
  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
  }

  // Fungsi untuk tombol + di Budget
  void _navigateToAddBudget() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        // Kirim BudgetBloc yang udah ada ke halaman baru
        value: context.read<BudgetBloc>(),
        child: AddEditBudgetPage(selectedDate: DateTime.now()), // Kirim tanggal hari ini
      ),
    ));
  }

  // Helper pintar untuk nentuin FAB
  Widget? _buildFab() {
    // Tampilkan FAB hanya di tab Beranda (0) dan Budget (2)
    final bool isVisible = (_selectedIndex == 0 || _selectedIndex == 2);

    return Visibility(
      visible: isVisible,
      child: FloatingActionButton(
        onPressed: () {
          // Arahkan ke fungsi yang bener berdasarkan tab
          if (_selectedIndex == 0) {
            _navigateToAddTransaction();
          } else if (_selectedIndex == 2) {
            _navigateToAddBudget();
          }
        },
        backgroundColor: const Color(0xFF3A86FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  // =================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      
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
      
      // Panggil helper pintar kita
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}