import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/category/presentation/pages/category_management_page.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:cashwise/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:cashwise/features/transaction/presentation/widgets/transaction_summary_card.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchAllTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Warna background baru
      appBar: AppBar(
        title: const Text('CashWise', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0,
        foregroundColor: Colors.black87, // Warna teks & ikon di AppBar
        actions: [
          IconButton(
            tooltip: 'Manajemen Kategori',
            icon: const Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryManagementPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const LoadingIndicator();
          } else if (state is TransactionLoaded) {
            // Kita bungkus semuanya dengan Column
            return Column(
              children: [
                // Tampilkan Summary Card di atas
                TransactionSummaryCard(transactions: state.transactions),
                // Gunakan Expanded agar ListView mengisi sisa ruang
                Expanded(
                  child: state.transactions.isEmpty
                      ? const Center(child: Text('Belum ada transaksi.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = state.transactions[index];
                            return TransactionListItem(transaction: transaction);
                          },
                        ),
                ),
              ],
            );
          } else if (state is TransactionError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Selamat datang di CashWise!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}