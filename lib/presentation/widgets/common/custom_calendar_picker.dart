import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widget BottomSheet Kalender yang bisa dipakai ulang.
/// Dia GAK PEDULI soal event/transaksi. Dia cuma milih tanggal.
class CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  // Kita set 'firstDay' default-nya 'now'
  // karena "Goal" gak mungkin di masa lalu
  final DateTime? firstDay; 
  final DateTime? lastDay;

  const CustomCalendarPicker({
    super.key,
    required this.initialDate,
    this.firstDay,
    this.lastDay,
  });

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
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
            // Pake 'firstDay' dari parameter, kalo gak ada, pake hari ini
            firstDay: widget.firstDay ?? DateTime.now(),
            lastDay: widget.lastDay ?? DateTime.utc(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              // Kita gak butuh 'markerDecoration' di sini
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
                  // Kirim balik tanggal yang dipilih
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