import 'package:flutter/material.dart';
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
  // State untuk nyimpen tab mana yang lagi aktif
  int _selectedIndex = 0;

  // Daftar semua halaman utama kita
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // Tab 0
    const TransactionHistoryPage(), // Tab 1
    const BudgetPage(), // Tab 2
    const SettingsPage(), // Tab 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-nya ganti-ganti sesuai tab yang dipilih
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // =================================================================
      // TOMBOL NAVIGASI UTAMA (PENGGANTI 4 TOMBOL)
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
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3A86FF), // Warna biru tema kita
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Biar labelnya selalu keliatan
      ),
      
      // =================================================================
      // TOMBOL AKSI UTAMA (PENGGANTI 2 TOMBOL)
      // =================================================================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        backgroundColor: const Color(0xFF3A86FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // Bikin FAB-nya nempel di tengah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}