import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

// Kita gak butuh import SettingsPage lagi di sini
// import 'package:cashwise/presentation/pages/settings_page.dart'; 

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
    // =================================================================
    // KEMBALI KE COLUMN YANG STABIL (TIDAK ADA SLIVERAPPBAR)
    // =================================================================
    return Scaffold(
      backgroundColor: const Color(0xFF3A86FF), // Latar biru di atas
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Baru (Simpel)
            _buildHeader(),
            
            // 2. BlocBuilder cuma ngebungkus konten yang butuh data
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoaded) {
                    return _buildLoadedUI(context, state.transactions);
                  } else if (state is TransactionError) {
                    return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
                  }
                  // Default (Loading)
                  return const LoadingIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BARU: Header yang jauh lebih simpel
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Halo, User 1', // Nanti bisa diganti data user
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Sesuai ide lo, tombol setting di sini dihapus.
          // Kita bisa ganti jadi profile pic di dalam "The Big Card"
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white30,
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // WIDGET BARU: UI yang nampilin data (Kartu + List)
  Widget _buildLoadedUI(BuildContext context, List<Transaction> transactions) {
    // --- Olah Data Dulu ---
    final double totalBalance = transactions.fold(
      0.0, (sum, item) => sum + (item.isExpense ? -item.amount : item.amount),
    );
    
    // Helper ngecek "hari ini"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Hitung Pemasukan Hari Ini
    final double todayIncome = transactions
        .where((t) => !t.isExpense &&
              t.transactionDate.year == today.year &&
              t.transactionDate.month == today.month &&
              t.transactionDate.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);

    // Hitung Pengeluaran Hari Ini
    final double todayExpense = transactions
        .where((t) => t.isExpense &&
              t.transactionDate.year == today.year &&
              t.transactionDate.month == today.month &&
              t.transactionDate.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);
    
    // --- Tampilan UI ---
    return Column(
      children: [
        // 2. "The Big Card" (Versi Baru)
        _buildBalanceCard(totalBalance, todayIncome, todayExpense),
        
        // 3. Daftar Transaksi Terakhir
        Expanded(
          child: _buildRecentTransactionsSection(transactions),
        ),
      ],
    );
  }

  // =================================================================
  // "THE BIG CARD" - SESUAI IDE LO
  // =================================================================
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
        color: Colors.white, // GANTI JADI PUTIH BIAR MINIMALIS
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
          const Text(
            'Total Saldo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey, // Warna teks jadi abu-abu
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(totalBalance),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.8), // Warna teks jadi hitam
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // --- Info Pemasukan & Pengeluaran Hari Ini ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pemasukan Hari Ini
              Flexible(
                child: _buildTodaySummary(
                  title: 'Pemasukan Hari Ini',
                  amount: todayIncome,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
              // Pengeluaran Hari Ini
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

  // Widget helper buat nampilin Pemasukan/Pengeluaran harian
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        )
      ],
    );
  }


  // =================================================================
  // TRANSAKSI TERAKHIR (CARD-NYA DIBUAT DARI SINI)
  // =================================================================
  Widget _buildRecentTransactionsSection(List<Transaction> transactions) {
    return Container(
      // Ini "sheet" putih di bawah kartu
      margin: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9), // Ganti background jadi abu-abu muda
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

// WIDGET LIST ITEM (TIDAK BERUBAH)
class _RecentTransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const _RecentTransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final amountString = (transaction.isExpense ? '-Rp ' : '+Rp ') + currencyFormatter.format(transaction.amount);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: Colors.white, // Ganti jadi putih bersih
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
                // Ganti warna background icon
                color: transaction.isExpense ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                // Ganti warna icon
                color: transaction.isExpense ? Colors.red.shade600 : Colors.green.shade600,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd-MM-yyyy').format(transaction.transactionDate),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amountString,
              style: TextStyle(
                color: transaction.isExpense ? Colors.red.shade600 : Colors.green.shade600,
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