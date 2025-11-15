// lib/presentation/widgets/common/custom_calendar_picker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widget BottomSheet Kalender yang bisa dipakai ulang.
class CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
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
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay),
            // --- REFAKTOR: Ganti style hardcode ---
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            locale: 'id_ID',
            firstDay: widget.firstDay ?? DateTime.now(),
            lastDay: widget.lastDay ?? DateTime.utc(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            // --- REFAKTOR: Styling Header Kalender ---
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium!,
              leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
              rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
            ),
            // --- REFAKTOR: Styling Hari Kalender ---
            calendarStyle: CalendarStyle(
              // Dekorasi hari ini
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: colorScheme.primary),
              // Dekorasi hari terpilih
              selectedDecoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
              // Dekorasi hari biasa
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
              weekendTextStyle: TextStyle(color: colorScheme.error.withOpacity(0.7)),
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
              // (Tombol-tombol ini otomatis ngikut theme)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
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