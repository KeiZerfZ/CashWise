// lib/features/transaction/presentation/pages/transaction_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';
import 'package:cashwise/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:cashwise/features/transaction/presentation/pages/transaction_graph_page.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart';

enum FilterMode { bulanan, mingguan, harian, tahunan }

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  DateTime _selectedDate = DateTime.now();
  final _searchController = TextEditingController();
  List<Transaction> _allTransactions = [];

  FilterMode _currentMode = FilterMode.bulanan;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchAllTransactions());
    context.read<CategoryBloc>().add(FetchAllCategories());
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime _getMonday(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek - 1;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

  DateTime _getSunday(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToAdd = 7 - dayOfWeek;
    final sunday = date.add(Duration(days: daysToAdd));
    return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  }

  Future<void> _selectDateByCalendar(BuildContext context) async {
    final theme = Theme.of(context);

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return _CalendarSheet(
          initialDate: _selectedDate,
          allTransactions: _allTransactions,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectDateByYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
          final List<Category> allCategories =
              categoryState is CategoryLoaded ? categoryState.categories : [];

          return Column(
            children: [
              const SizedBox(height: 16),
              if (_currentMode == FilterMode.tahunan)
                _buildYearSelector(context)
              else
                _buildMonthSelector(context),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildTypeToggle(
                      title: 'Bulanan',
                      icon: Icons.calendar_month_outlined,
                      isSelected: _currentMode == FilterMode.bulanan,
                      onTap: () =>
                          setState(() => _currentMode = FilterMode.bulanan),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeToggle(
                      title: 'Mingguan',
                      icon: Icons.calendar_view_week_outlined,
                      isSelected: _currentMode == FilterMode.mingguan,
                      onTap: () =>
                          setState(() => _currentMode = FilterMode.mingguan),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeToggle(
                      title: 'Harian',
                      icon: Icons.calendar_today_outlined,
                      isSelected: _currentMode == FilterMode.harian,
                      onTap: () =>
                          setState(() => _currentMode = FilterMode.harian),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeToggle(
                      title: 'Tahunan',
                      icon: Icons.calendar_view_day_outlined,
                      isSelected: _currentMode == FilterMode.tahunan,
                      onTap: () =>
                          setState(() => _currentMode = FilterMode.tahunan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, transactionState) {
                    if (transactionState is TransactionLoading) {
                      return const LoadingIndicator();
                    } else if (transactionState is TransactionLoaded) {
                      _allTransactions = transactionState.transactions;

                      final filteredTransactions =
                          transactionState.transactions.where((t) {
                        final matchesSearch = t.description
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                        if (!matchesSearch) return false;

                        switch (_currentMode) {
                          case FilterMode.bulanan:
                            return t.transactionDate.month ==
                                    _selectedDate.month &&
                                t.transactionDate.year == _selectedDate.year;
                          case FilterMode.mingguan:
                            final DateTime startOfWeek =
                                _getMonday(_selectedDate);
                            final DateTime endOfWeek = _getSunday(_selectedDate);
                            return !t.transactionDate.isBefore(startOfWeek) &&
                                !t.transactionDate.isAfter(endOfWeek);
                          case FilterMode.harian:
                            return t.transactionDate.day == _selectedDate.day &&
                                t.transactionDate.month ==
                                    _selectedDate.month &&
                                t.transactionDate.year == _selectedDate.year;
                          case FilterMode.tahunan:
                            return t.transactionDate.year == _selectedDate.year;
                        }
                      }).toList();

                      return _buildTransactionList(
                          filteredTransactions, allCategories);
                    } else if (transactionState is TransactionError) {
                      return Center(
                          child: Text('Error: ${transactionState.message}'));
                    }
                    return const Center(child: Text('Tidak ada data.'));
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            final categoriesState = context.read<CategoryBloc>().state;
            final categories = (categoriesState is CategoryLoaded)
                ? categoriesState.categories
                : <Category>[];

            String graphTitle;
            List<Transaction> transactionsForGraph;

            switch (_currentMode) {
              case FilterMode.bulanan:
                graphTitle =
                    'Grafik ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)}';
                transactionsForGraph = _allTransactions.where((t) {
                  return t.transactionDate.month == _selectedDate.month &&
                      t.transactionDate.year == _selectedDate.year;
                }).toList();
                break;
              case FilterMode.mingguan:
                final DateTime startOfWeek = _getMonday(_selectedDate);
                final DateTime endOfWeek = _getSunday(_selectedDate);
                graphTitle =
                    'Grafik (${DateFormat('d MMM', 'id_ID').format(startOfWeek)} - ${DateFormat('d MMM yyyy', 'id_ID').format(endOfWeek)})';
                transactionsForGraph = _allTransactions.where((t) {
                  return !t.transactionDate.isBefore(startOfWeek) &&
                      !t.transactionDate.isAfter(endOfWeek);
                }).toList();
                break;
              case FilterMode.harian:
                graphTitle =
                    'Grafik ${DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate)}';
                transactionsForGraph = _allTransactions.where((t) {
                  return t.transactionDate.day == _selectedDate.day &&
                      t.transactionDate.month == _selectedDate.month &&
                      t.transactionDate.year == _selectedDate.year;
                }).toList();
                break;
              case FilterMode.tahunan:
                graphTitle =
                    'Grafik Tahun ${DateFormat('yyyy', 'id_ID').format(_selectedDate)}';
                transactionsForGraph = _allTransactions.where((t) {
                  return t.transactionDate.year == _selectedDate.year;
                }).toList();
                break;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => TransactionGraphPage(
                  graphTitle: graphTitle,
                  transactionsForGraph: transactionsForGraph,
                  allCategories: categories,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Lihat Grafik',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final Color color = theme.primaryColor;
    final Color semanticBg =
        isLightMode ? color.withOpacity(0.1) : color.withOpacity(0.2);
    final Color borderColor =
        isLightMode ? Colors.grey.shade300 : theme.dividerColor;
    final Color textColor =
        isLightMode ? Colors.grey.shade700 : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? semanticBg : theme.cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _selectDateByCalendar(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: theme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentMode == FilterMode.bulanan
                      ? DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)
                      : DateFormat('d MMMM yyyy', 'id_ID')
                          .format(_selectedDate),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _selectDateByYear(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: theme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tahun ${DateFormat('yyyy', 'id_ID').format(_selectedDate)}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari Transaksi',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon:
              Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      List<Transaction> transactions, List<Category> allCategories) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (transactions.isEmpty) {
      String message = 'Tidak ada transaksi.';
      switch (_currentMode) {
        case FilterMode.bulanan:
          message = 'Tidak ada transaksi di bulan ini.';
          break;
        case FilterMode.mingguan:
          message = 'Tidak ada transaksi di minggu ini.';
          break;
        case FilterMode.harian:
          message = 'Tidak ada transaksi di tanggal ini.';
          break;
        case FilterMode.tahunan:
          message = 'Tidak ada transaksi di tahun ini.';
          break;
      }
      return Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return GestureDetector(
          onTap: () =>
              _showTransactionDetails(context, transaction, allCategories),
          child: _TransactionListItem(transaction: transaction),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction,
      List<Category> allCategories) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return _TransactionDetailSheet(
            transaction: transaction, allCategories: allCategories);
      },
    );
  }
}

// =================================================================
// SUB-WIDGET: KALENDER DI DALAM MODAL
// =================================================================
class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final List<Transaction> allTransactions;
  const _CalendarSheet({
    required this.initialDate,
    required this.allTransactions,
  });
  @override
  State<_CalendarSheet> createState() => __CalendarSheetState();
}

class __CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late final Map<DateTime, List<dynamic>> _events;
  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
    _events = {};
    for (var transaction in widget.allTransactions) {
      final dateKey = DateTime.utc(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );
      if (_events[dateKey] == null) _events[dateKey] = [];
      _events[dateKey]!.add(1);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final Color eventMarkerColor =
        isLightMode ? Colors.red.shade400 : Colors.red.shade300;
        
    // =================================================================
    // INI DIA FIX-NYA! (Sama kayak yang di kalender celengan)
    // =================================================================
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay),
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          TableCalendar(
            locale: 'id_ID',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium!,
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: colorScheme.onSurface),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: colorScheme.onSurface),
            ),
            calendarStyle: CalendarStyle(
              markerDecoration:
                  BoxDecoration(color: eventMarkerColor, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: colorScheme.primary),
              selectedDecoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
              weekendTextStyle:
                  TextStyle(color: colorScheme.error.withOpacity(0.7)),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal')),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedDay);
                  },
                  child: const Text('OK')),
            ],
          )
        ],
      ),
    );
  }
}

// =================================================================
// SUB-WIDGET: ITEM DI LIST TRANSAKSI
// =================================================================
class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const _TransactionListItem({required this.transaction});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final amountString = (transaction.isExpense ? '-Rp. ' : '+Rp. ') +
        currencyFormatter.format(transaction.amount);

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
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
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
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd-MM-yyyy')
                        .format(transaction.transactionDate),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
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

// =================================================================
// SUB-WIDGET: MODAL DETAIL TRANSAKSI
// =================================================================
class _TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final List<Category> allCategories;
  const _TransactionDetailSheet({
    required this.transaction,
    required this.allCategories,
  });
  String get categoryName {
    try {
      return allCategories
          .firstWhere((category) => category.id == transaction.categoryId)
          .name;
    } catch (e) {
      return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final Color deleteColor = isLightMode ? Colors.red : Colors.red.shade300;

    return Padding(
      // --- INI DIA FIX-NYA! (Sama kayak kalender) ---
      padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Transaksi', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 20),
          _buildDetailRow('Tipe', transaction.isExpense ? 'Pengeluaran' : 'Pemasukan'),
          const Divider(),
          _buildDetailRow('Judul', transaction.description),
          const Divider(),
          _buildDetailRow(
              'Jumlah',
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
                  .format(transaction.amount)),
          const Divider(),
          _buildDetailRow('Kategori', categoryName),
          const Divider(),
          _buildDetailRow('Keterangan', '-'),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  onPressed: () {
                    context
                        .read<TransactionBloc>()
                        .add(DeleteTransactionEvent(transaction.id));
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: deleteColor,
                      side: BorderSide(color: deleteColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTransactionPage(
                          transactionToEdit: transaction,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            Text(value,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    });
  }
}