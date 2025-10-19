import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// BARU: Import senjata baru kita
import 'package:table_calendar/table_calendar.dart';

// Import dari project lo (sesuaikan path jika perlu)
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  DateTime _selectedDate = DateTime.now();
  final _searchController = TextEditingController();
  // BARU: State untuk menyimpan semua transaksi yang akan di-pass ke kalender
  List<Transaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchAllTransactions());
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // FUNGSI INI KITA UPGRADE TOTAL
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        // Kita panggil widget kalender custom di dalam bottom sheet
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildMonthSelector(context),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const LoadingIndicator();
                } else if (state is TransactionLoaded) {
                  // SIMPAN SEMUA TRANSAKSI KE STATE
                  _allTransactions = state.transactions;
                  
                  final filteredTransactions = state.transactions.where((t) {
                    final isSameMonth = t.transactionDate.month == _selectedDate.month &&
                                        t.transactionDate.year == _selectedDate.year;
                    final matchesSearch = t.description
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                    return isSameMonth && matchesSearch;
                  }).toList();

                  return _buildTransactionList(filteredTransactions);
                } else if (state is TransactionError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('Tidak ada data.'));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
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

  // ... (sisa widget _buildMonthSelector, _buildSearchBar, dll. biarkan sama) ...
  // --- KODE DI BAWAH INI TIDAK BERUBAH, JADI GUE POTONG BIAR RINGKAS ---
  // --- CUKUP COPY-PASTE SEMUA KODE DARI ATAS SAMPAI BAWAH ---

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF3A86FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF005BD4),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF3A86FF)),
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
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi di bulan ini.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return GestureDetector(
          onTap: () => _showTransactionDetails(context, transaction),
          child: _TransactionListItem(transaction: transaction),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return _TransactionDetailSheet(transaction: transaction);
      },
    );
  }
}

// =========================================================================
// WIDGET BARU UNTUK KALENDER DI DALAM BOTTOM SHEET
// =========================================================================
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
  // Ini adalah "otak" untuk event marker (titik merah)
  late final Map<DateTime, List<dynamic>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;

    // Proses semua transaksi menjadi format yang dimengerti table_calendar
    _events = {};
    for (var transaction in widget.allTransactions) {
      // Kita hanya peduli tanggalnya, bukan jam/menit
      final dateKey = DateTime.utc(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );
      if (_events[dateKey] == null) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(1); // Isi list-nya bisa apa aja, yang penting ada
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Fungsi untuk mendapatkan event (titik merah) untuk tanggal tertentu
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            locale: 'id_ID',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            // Ini yang akan menampilkan titik merahnya
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              // Style untuk titik merahnya
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
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
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Kirim tanggal yang dipilih kembali ke halaman sebelumnya
                  Navigator.pop(context, _selectedDay);
                },
                child: const Text('OK'),
              ),
            ],
          )
        ],
      ),
    );
  }
}


// --- SISA KODE DI BAWAH INI TIDAK BERUBAH ---
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
                  Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd-MM-yyyy').format(transaction.transactionDate),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
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

class _TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  const _TransactionDetailSheet({required this.transaction});
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
          _buildDetailRow('Kategori', transaction.categoryId?.toString() ?? 'Tidak ada kategori'),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF3A86FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
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
