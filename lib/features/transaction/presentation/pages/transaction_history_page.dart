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
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade100,
        foregroundColor: Colors.black87,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
          final List<Category> allCategories = categoryState is CategoryLoaded
              ? categoryState.categories
              : [];

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
              
              // =================================================================
              // REFACTOR: GANTI TOGGLE JADI LEBIH KEREN
              // =================================================================
              SizedBox(
                height: 45, // Kasih tinggi yang pas
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildTypeToggle(
                      title: 'Bulanan',
                      icon: Icons.calendar_month_outlined,
                      isSelected: _currentMode == FilterMode.bulanan,
                      onTap: () => setState(() => _currentMode = FilterMode.bulanan),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeToggle(
                      title: 'Mingguan',
                      icon: Icons.calendar_view_week_outlined,
                      isSelected: _currentMode == FilterMode.mingguan,
                      onTap: () => setState(() => _currentMode = FilterMode.mingguan),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeToggle(
                      title: 'Harian',
                      icon: Icons.calendar_today_outlined,
                      isSelected: _currentMode == FilterMode.harian,
                      onTap: () => setState(() => _currentMode = FilterMode.harian),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeToggle(
                      title: 'Tahunan',
                      icon: Icons.calendar_view_day_outlined,
                      isSelected: _currentMode == FilterMode.tahunan,
                      onTap: () => setState(() => _currentMode = FilterMode.tahunan),
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
                      
                      final filteredTransactions = transactionState.transactions.where((t) {
                        final matchesSearch = t.description
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                        
                        if (!matchesSearch) return false;

                        switch (_currentMode) {
                          case FilterMode.bulanan:
                            final isSameMonth = t.transactionDate.month == _selectedDate.month &&
                                                t.transactionDate.year == _selectedDate.year;
                            return isSameMonth;
                          
                          case FilterMode.mingguan:
                            final DateTime startOfWeek = _getMonday(_selectedDate);
                            final DateTime endOfWeek = _getSunday(_selectedDate);
                            return !t.transactionDate.isBefore(startOfWeek) &&
                                   !t.transactionDate.isAfter(endOfWeek);

                          case FilterMode.harian:
                            final isSameDay = t.transactionDate.day == _selectedDate.day &&
                                              t.transactionDate.month == _selectedDate.month &&
                                              t.transactionDate.year == _selectedDate.year;
                            return isSameDay;
                          
                          case FilterMode.tahunan:
                            final isSameYear = t.transactionDate.year == _selectedDate.year;
                            return isSameYear;
                        }

                      }).toList();

                      return _buildTransactionList(filteredTransactions, allCategories);
                    } else if (transactionState is TransactionError) {
                      return Center(child: Text('Error: ${transactionState.message}'));
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
            final categories = (categoriesState is CategoryLoaded) ? categoriesState.categories : <Category>[];
            
            String graphTitle;
            List<Transaction> transactionsForGraph;

            switch (_currentMode) {
              case FilterMode.bulanan:
                graphTitle = 'Grafik ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)}';
                transactionsForGraph = _allTransactions.where((t) {
                  return t.transactionDate.month == _selectedDate.month &&
                         t.transactionDate.year == _selectedDate.year;
                }).toList();
                break;
              
              case FilterMode.mingguan:
                final DateTime startOfWeek = _getMonday(_selectedDate);
                final DateTime endOfWeek = _getSunday(_selectedDate);
                graphTitle = 'Grafik (${DateFormat('d MMM', 'id_ID').format(startOfWeek)} - ${DateFormat('d MMM yyyy', 'id_ID').format(endOfWeek)})';
                transactionsForGraph = _allTransactions.where((t) {
                  return !t.transactionDate.isBefore(startOfWeek) &&
                         !t.transactionDate.isAfter(endOfWeek);
                }).toList();
                break;

              case FilterMode.harian:
                graphTitle = 'Grafik ${DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate)}';
                transactionsForGraph = _allTransactions.where((t) {
                  return t.transactionDate.day == _selectedDate.day &&
                         t.transactionDate.month == _selectedDate.month &&
                         t.transactionDate.year == _selectedDate.year;
                }).toList();
                break;
              
              case FilterMode.tahunan:
                graphTitle = 'Grafik Tahun ${DateFormat('yyyy', 'id_ID').format(_selectedDate)}';
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
            backgroundColor: const Color(0xFF3A86FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Lihat Grafik',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // =================================================================
  // BARU: WIDGET HELPER UNTUK TOGGLE KUSTOM
  // =================================================================
  Widget _buildTypeToggle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color color = Theme.of(context).primaryColor; // Pake warna biru utama
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30), // Bikin lebih bulet
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(30), // Bikin lebih bulet
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _selectDateByCalendar(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF3A86FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentMode == FilterMode.bulanan 
                    ? DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)
                    : DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _selectDateByYear(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF3A86FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tahun ${DateFormat('yyyy', 'id_ID').format(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari Transaksi',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100, // Background abu-abu
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --- SISA KODE (WIDGET HELPER) DI BAWAH INI TIDAK ADA PERUBAHAN ---
  // ( ... _buildTransactionList, _showTransactionDetails, _CalendarSheet, _TransactionListItem, _TransactionDetailSheet ... )
  
  Widget _buildTransactionList(List<Transaction> transactions, List<Category> allCategories) {
    if (transactions.isEmpty) {
      String message = 'Tidak ada transaksi.';
      switch (_currentMode) {
        case FilterMode.bulanan: message = 'Tidak ada transaksi di bulan ini.'; break;
        case FilterMode.mingguan: message = 'Tidak ada transaksi di minggu ini.'; break;
        case FilterMode.harian: message = 'Tidak ada transaksi di tanggal ini.'; break;
        case FilterMode.tahunan: message = 'Tidak ada transaksi di tahun ini.'; break;
      }
      return Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return GestureDetector(
          onTap: () => _showTransactionDetails(context, transaction, allCategories),
          child: _TransactionListItem(transaction: transaction),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction, List<Category> allCategories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return _TransactionDetailSheet(transaction: transaction, allCategories: allCategories);
      },
    );
  }
}

class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final List<Transaction> allTransactions;
  const _CalendarSheet({ required this.initialDate, required this.allTransactions, });
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
  List<dynamic> _getEventsForDay(DateTime day) { return _events[day] ?? []; }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text( DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
          const SizedBox(height: 16),
          TableCalendar(
            locale: 'id_ID',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle( formatButtonVisible: false, titleCentered: true, ),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration( color: Colors.red, shape: BoxShape.circle, ),
              todayDecoration: BoxDecoration( color: Colors.blue.shade100, shape: BoxShape.circle, ),
              selectedDecoration: BoxDecoration( color: Theme.of(context).primaryColor, shape: BoxShape.circle, ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) { _focusedDay = focusedDay; },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton( onPressed: () => Navigator.pop(context), child: const Text('Batal'), ),
              const SizedBox(width: 8),
              ElevatedButton( onPressed: () { Navigator.pop(context, _selectedDay); }, child: const Text('OK'), ),
            ],
          )
        ],
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const _TransactionListItem({required this.transaction});
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final amountString = (transaction.isExpense ? '-Rp. ' : '+Rp. ') + currencyFormatter.format(transaction.amount);
     return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200), ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration( color: transaction.isExpense ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(10), ),
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
                  Text( transaction.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                  const SizedBox(height: 2),
                  Text( DateFormat('dd-MM-yyyy').format(transaction.transactionDate), style: TextStyle(color: Colors.grey.shade600, fontSize: 13), ),
                ],
              ),
            ),
            Text( amountString, style: TextStyle( color: transaction.isExpense ? Colors.red.shade600 : Colors.green.shade600, fontWeight: FontWeight.bold, fontSize: 15, ), ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final List<Category> allCategories;
  const _TransactionDetailSheet({ required this.transaction, required this.allCategories, });
  String get categoryName {
    try {
      return allCategories.firstWhere((category) => category.id == transaction.categoryId).name;
    } catch (e) {
      return 'Tidak Diketahui';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Transaksi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildDetailRow('Tipe', transaction.isExpense ? 'Pengeluaran' : 'Pemasukan'),
          const Divider(),
          _buildDetailRow('Judul', transaction.description),
           const Divider(),
          _buildDetailRow('Jumlah', NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(transaction.amount)),
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
                    context.read<TransactionBloc>().add(DeleteTransactionEvent(transaction.id));
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom( foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) ),
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
                  style: ElevatedButton.styleFrom( foregroundColor: Colors.white, backgroundColor: const Color(0xFF3A86FF), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}