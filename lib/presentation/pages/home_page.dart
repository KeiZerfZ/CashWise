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
    context.read<TransactionBloc>().add(FetchAllTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A86FF),
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
                return _buildHeader(name, imagePath);
              },
            ),
            
            // 2. Konten (Ngedengerin BLoC Transaksi)
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoaded) {
                    return _buildLoadedUI(context, state.transactions);
                  } else if (state is TransactionError) {
                    return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
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
  Widget _buildHeader(String name, String? imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halo, $name',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white30,
            backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
            child: imagePath == null
                ? const Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
        ],
      ),
    );
  }

  // WIDGET KONTEN UTAMA (Kartu Saldo + List)
  Widget _buildLoadedUI(BuildContext context, List<Transaction> transactions) {
    // --- Olah Data ---
    final double totalBalance = transactions.fold(
      0.0, (sum, item) => sum + (item.isExpense ? -item.amount : item.amount),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final double todayIncome = transactions
        .where((t) => !t.isExpense &&
              t.transactionDate.year == today.year &&
              t.transactionDate.month == today.month &&
              t.transactionDate.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);
    final double todayExpense = transactions
        .where((t) => t.isExpense &&
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
  Widget _buildBalanceCard(double totalBalance, double todayIncome, double todayExpense) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text( 'Total Saldo', style: TextStyle( fontSize: 16, color: Colors.grey, ), ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(totalBalance),
            style: TextStyle( fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8), ),
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
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
              Flexible(
                child: _buildTodaySummary(
                  title: 'Pengeluaran Hari Ini',
                  amount: todayExpense,
                  color: Colors.red,
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( title, style: const TextStyle( fontSize: 13, color: Colors.grey, ), ),
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(amount),
              style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8), ),
            ),
          ],
        )
      ],
    );
  }

  // List Transaksi Terakhir
  Widget _buildRecentTransactionsSection(List<Transaction> transactions) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 10.0),
            child: Text(
              'Transaksi Terakhir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
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
    final currencyFormatter = NumberFormat.currency( locale: 'id_ID', symbol: '', decimalDigits: 0, );
    final amountString = (transaction.isExpense ? '-Rp ' : '+Rp ') + currencyFormatter.format(transaction.amount);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: Colors.white,
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
                color: transaction.isExpense ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: transaction.isExpense ? Colors.red.shade600 : Colors.green.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( transaction.description, style: const TextStyle( fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333), ), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                  const SizedBox(height: 2),
                  Text( DateFormat('dd-MM-yyyy').format(transaction.transactionDate), style: TextStyle( color: Colors.grey.shade600, fontSize: 13, ), ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text( amountString, style: TextStyle( color: transaction.isExpense ? Colors.red.shade600 : Colors.green.shade600, fontWeight: FontWeight.bold, fontSize: 15, ), ),
          ],
        ),
      ),
    );
  }
}