// lib/presentation/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Import BLoC-BLoC
import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_state.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';

// Import Entitas
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

// Import Widget
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Panggil event di BLoC.
    // Kita gak perlu 'addPostFrameCallback' di sini karena BLoC-nya
    // udah di-provide di atas MaterialApp (atau di main_page)
    context.read<TransactionBloc>().add(FetchAllTransactions());
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // --- REFAKTOR: Ganti warna hardcode ---
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Ngedengerin BLoC Profil)
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                String name = 'User 1';
                String? imagePath;
                if (state is ProfileLoaded) {
                  name = state.profile.name;
                  imagePath = state.profile.imagePath;
                }
                
                // --- REFAKTOR: Pass 'colorScheme' ke header ---
                return _buildHeader(name, imagePath, colorScheme);
              },
            ),

            // 2. Konten (Ngedengerin BLoC Transaksi)
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoaded) {
                    return _buildLoadedUI(context, state.transactions);
                  } else if (state is TransactionError) {
                    return Center(
                        child: Text('Error: ${state.message}',
                            // --- REFAKTOR: Ganti warna hardcode ---
                            style: TextStyle(color: colorScheme.onError)));
                  }
                  return const LoadingIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HEADER (Nampilin Nama & Foto)
  // --- REFAKTOR: Terima 'colorScheme' ---
  Widget _buildHeader(String name, String? imagePath, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halo, $name',
            // --- REFAKTOR: Ganti style & warna hardcode ---
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary, // Teks di atas warna primer
            ),
          ),
          CircleAvatar(
            radius: 20,
            // --- REFAKTOR: Ganti warna hardcode ---
            backgroundColor: colorScheme.onPrimary.withOpacity(0.2), // Latar transparan
            backgroundImage:
                imagePath != null ? FileImage(File(imagePath)) : null,
            child: imagePath == null
                // --- REFAKTOR: Ganti warna hardcode ---
                ? Icon(Icons.person, color: colorScheme.onPrimary, size: 24)
                : null,
          ),
        ],
      ),
    );
  }

  // WIDGET KONTEN UTAMA (Kartu Saldo + List)
  Widget _buildLoadedUI(BuildContext context, List<Transaction> transactions) {
    // --- Olah Data ---
    // (Ini masih di-looping di build method, tapi kita biarin dulu
    // fokus di refactor warna)
    final double totalBalance = transactions.fold(
      0.0,
      (sum, item) => sum + (item.isExpense ? -item.amount : item.amount),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final double todayIncome = transactions
        .where((t) =>
            !t.isExpense &&
            t.transactionDate.year == today.year &&
            t.transactionDate.month == today.month &&
            t.transactionDate.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);
    final double todayExpense = transactions
        .where((t) =>
            t.isExpense &&
            t.transactionDate.year == today.year &&
            t.transactionDate.month == today.month &&
            t.transactionDate.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);

    // --- Tampilan UI ---
    return Column(
      children: [
        _buildBalanceCard(totalBalance, todayIncome, todayExpense),
        Expanded(
          child: _buildRecentTransactionsSection(transactions),
        ),
      ],
    );
  }

  // "THE BIG CARD"
  Widget _buildBalanceCard(
      double totalBalance, double todayIncome, double todayExpense) {
    
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        // --- REFAKTOR: Ganti warna hardcode ---
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // --- REFAKTOR: Ganti warna hardcode ---
            color: Colors.black.withOpacity(0.1), // Biarin shadow,
                                                  // atau ganti theme.shadowColor
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- REFAKTOR: Ganti style hardcode ---
          Text('Total Saldo', style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.grey, // Grey di sini spesifik, kita biarin
            fontSize: 16
          )),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(totalBalance),
            // --- REFAKTOR: Ganti style & warna hardcode ---
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, // Teks utama di atas card
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _buildTodaySummary(
                  title: 'Pemasukan Hari Ini',
                  amount: todayIncome,
                  color: Colors.green, // Biarin, ini warna semantik
                  icon: Icons.arrow_downward,
                ),
              ),
              Flexible(
                child: _buildTodaySummary(
                  title: 'Pengeluaran Hari Ini',
                  amount: todayExpense,
                  color: Colors.red, // Biarin, ini warna semantik
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Helper Pemasukan/Pengeluaran Harian
  Widget _buildTodaySummary({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18), // Warna semantik (merah/hijau)
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- REFAKTOR: Ganti style hardcode ---
            Text(title, style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.grey,
              fontSize: 13
            )),
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(amount),
              // --- REFAKTOR: Ganti style & warna hardcode ---
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface, // Teks utama di atas card
                fontSize: 15
              ),
            ),
          ],
        )
      ],
    );
  }

  // List Transaksi Terakhir
  Widget _buildRecentTransactionsSection(List<Transaction> transactions) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        // --- REFAKTOR: Ganti warna hardcode ---
        color: theme.scaffoldBackgroundColor, // Warna background utama
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 24.0, left: 24.0, right: 24.0, bottom: 10.0),
            child: Text(
              'Transaksi Terakhir',
              // --- REFAKTOR: Ganti style & warna hardcode ---
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
              ), // Otomatis ambil warna Teks Judul dari theme
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('Belum ada transaksi.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _RecentTransactionListItem(transaction: transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget Item Transaksi
class _RecentTransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const _RecentTransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final amountString = (transaction.isExpense ? '-Rp ' : '+Rp ') +
        currencyFormatter.format(transaction.amount);

    // --- REFAKTOR: Bikin warna dinamis ---
    // Ini warna semantik (merah/hijau), tapi kita buat
    // dia adaptasi sama light/dark mode
    final bool isLightMode = theme.brightness == Brightness.light;

    final Color expenseColor = isLightMode ? Colors.red.shade600 : Colors.red.shade300;
    final Color incomeColor = isLightMode ? Colors.green.shade600 : Colors.green.shade300;
    
    final Color expenseBg = isLightMode ? Colors.red.shade50 : Colors.red.shade900.withOpacity(0.3);
    final Color incomeBg = isLightMode ? Colors.green.shade50 : Colors.green.shade900.withOpacity(0.3);
    
    final Color itemColor = transaction.isExpense ? expenseColor : incomeColor;
    final Color itemBg = transaction.isExpense ? expenseBg : incomeBg;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      // --- REFAKTOR: Ganti warna hardcode ---
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // --- REFAKTOR: Pake warna dinamis ---
                color: itemBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transaction.isExpense
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                // --- REFAKTOR: Pake warna dinamis ---
                color: itemColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    // --- REFAKTOR: Ganti style & warna hardcode ---
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // --- REFAKTOR: Ganti style & warna hardcode ---
                  Text(
                    DateFormat('dd-MM-yyyy').format(transaction.transactionDate),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amountString,
              // --- REFAKTOR: Pake warna dinamis ---
              style: TextStyle(
                color: itemColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}