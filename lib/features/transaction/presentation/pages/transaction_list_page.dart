import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Import dari project lo
import 'package:cashwise/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

// BARU: Import halaman riwayat transaksi yang udah kita buat
import 'package:cashwise/features/transaction/presentation/pages/transaction_history_page.dart';


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
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const LoadingIndicator();
            } else if (state is TransactionLoaded) {
              return _buildLoadedUI(context, state.transactions);
            } else if (state is TransactionError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return const Center(
              child: Text(
                'Selamat datang!',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadedUI(BuildContext context, List<Transaction> transactions) {
    final double totalBalance = transactions.fold(
      0.0,
      (sum, item) => sum + (item.isExpense ? -item.amount : item.amount),
    );

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildBalanceCard(totalBalance),
        const SizedBox(height: 30),
        _buildActionButtons(),
        const SizedBox(height: 30),
        Expanded(
          child: _buildRecentTransactionsSection(transactions),
        ),
      ],
    );
  }

  Widget _buildHeader() {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Halo, User 1',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.8)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Catat aktivitas keuangan\ndengan mudah',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () { 
                  // TODO: Navigasi ke Halaman Pengaturan
                },
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white30,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
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
        color: const Color(0xFF005BD4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(balance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.add, 'Pemasukkan', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionPage()));
          }),
          _buildActionButton(Icons.remove, 'Pengeluaran', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionPage()));
          }),
          // --- FIX DI SINI ---
          _buildActionButton(Icons.list_alt_outlined, 'Transaksi', () {
            //  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementPage()));
             Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryPage()));
          }),
          // --- DAN FIX DI SINI ---
          _buildActionButton(Icons.download_outlined, 'Rekap', () {
            //  Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetPage()));
             Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF3A86FF)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(List<Transaction> transactions) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Transaksi Terakhir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
      color: Colors.grey.shade50,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                 border: Border.all(color: Colors.grey.shade200)
              ),
              child: Icon(
                transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: transaction.isExpense ? Colors.red.shade600 : const Color(0xFF3A86FF),
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