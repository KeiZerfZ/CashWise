// lib/presentation/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_state.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';
import 'package:cashwise/features/profile/domain/entities/user_profile.dart';
// =================================================================
// --- BARU: Import halaman profile settings ---
import 'package:cashwise/features/profile/presentation/pages/profile_settings_page.dart';
// =================================================================

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String? bgImagePath;
        int? bgColorValue;
        UserProfile currentProfile = UserProfile.empty();

        if (profileState is ProfileLoaded) {
          currentProfile = profileState.profile;
          bgImagePath = currentProfile.backgroundImagePath;
          bgColorValue = currentProfile.backgroundColorValue;
        }

        final BoxDecoration backgroundDecoration;

        if (bgImagePath != null && bgImagePath.isNotEmpty) {
          backgroundDecoration = BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(bgImagePath)),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          );
        } else if (bgColorValue != null) {
          backgroundDecoration = BoxDecoration(color: Color(bgColorValue));
        } else {
          backgroundDecoration = BoxDecoration(color: theme.primaryColor);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: backgroundDecoration,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- REFAKTOR: Kirim 'context' ke header ---
                  _buildHeader(
                    context, // <-- BARU
                    currentProfile.name,
                    currentProfile.imagePath,
                    colorScheme,
                  ),
                  Expanded(
                    child: BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoaded) {
                          return _buildLoadedUI(context, state.transactions);
                        } else if (state is TransactionError) {
                          return Center(
                              child: Text('Error: ${state.message}',
                                  style:
                                      TextStyle(color: colorScheme.onError)));
                        }
                        return const LoadingIndicator();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- REFAKTOR: 'context' ditambahin di parameter ---
  Widget _buildHeader(BuildContext context, String name, String? imagePath,
      ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halo, $name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          // =================================================================
          // --- INI DIA FITURNYA ---
          // =================================================================
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileSettingsPage()),
              );
            },
            borderRadius: BorderRadius.circular(20), // Samain kayak radius avatar
            child: CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
              backgroundImage:
                  imagePath != null ? FileImage(File(imagePath)) : null,
              child: imagePath == null
                  ? Icon(Icons.person, color: colorScheme.onPrimary, size: 24)
                  : null,
            ),
          ),
          // =================================================================
        ],
      ),
    );
  }

  // (Sisa kode di bawah ini gak ada perubahan sama sekali)

  Widget _buildLoadedUI(BuildContext context, List<Transaction> transactions) {
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

    return Column(
      children: [
        _buildBalanceCard(totalBalance, todayIncome, todayExpense),
        Expanded(
          child: _buildRecentTransactionsSection(transactions),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
      double totalBalance, double todayIncome, double todayExpense) {
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
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Saldo',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(totalBalance),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
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

  Widget _buildTodaySummary({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
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
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(amount),
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: colorScheme.onSurface, fontSize: 15),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRecentTransactionsSection(List<Transaction> transactions) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
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
                      return _RecentTransactionListItem(
                          transaction: transaction);
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
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final amountString = (transaction.isExpense ? '-Rp ' : '+Rp ') +
        currencyFormatter.format(transaction.amount);
    final bool isLightMode = theme.brightness == Brightness.light;
    final Color expenseColor =
        isLightMode ? Colors.red.shade600 : Colors.red.shade300;
    final Color incomeColor =
        isLightMode ? Colors.green.shade600 : Colors.green.shade300;
    final Color expenseBg =
        isLightMode ? Colors.red.shade50 : Colors.red.shade900.withOpacity(0.3);
    final Color incomeBg = isLightMode
        ? Colors.green.shade50
        : Colors.green.shade900.withOpacity(0.3);
    final Color itemColor = transaction.isExpense ? expenseColor : incomeColor;
    final Color itemBg = transaction.isExpense ? expenseBg : incomeBg;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                color: itemBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transaction.isExpense
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
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
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd-MM-yyyy')
                        .format(transaction.transactionDate),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amountString,
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