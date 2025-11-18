// lib/features/saving_goal/presentation/pages/add_edit_goal_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_event.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_state.dart';
import 'package:cashwise/presentation/widgets/common/custom_calendar_picker.dart';

class AddEditGoalPage extends StatefulWidget {
  final SavingGoal? goalToEdit;
  const AddEditGoalPage({super.key, this.goalToEdit});

  @override
  State<AddEditGoalPage> createState() => _AddEditGoalPageState();
}

class _AddEditGoalPageState extends State<AddEditGoalPage> {
  late TextEditingController _nameController;
  String _amountString = '0';
  DateTime? _selectedTargetDate;

  bool get isEditing => widget.goalToEdit != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController = TextEditingController(text: widget.goalToEdit!.name);
      _amountString = widget.goalToEdit!.targetAmount.toStringAsFixed(0);
      _selectedTargetDate = widget.goalToEdit!.targetDate;
    } else {
      _nameController = TextEditingController();
      _amountString = '0';
      _selectedTargetDate = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_isSaving) return;
    final name = _nameController.text;
    final amount = double.tryParse(_amountString) ?? 0.0;

    if (name.isEmpty) {
      _showErrorSnackBar('Nama celengan tidak boleh kosong!');
      return;
    }
    if (amount <= 0) {
      _showErrorSnackBar('Target uang harus lebih dari 0!');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newGoal = SavingGoal(
      id: isEditing ? widget.goalToEdit!.id : 0,
      name: name,
      targetAmount: amount,
      targetDate: _selectedTargetDate,
    );
    context.read<SavingGoalBloc>().add(SaveSavingGoalEvent(goal: newGoal));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onNumpadTapped(String value) {
    if (_isSaving) return;
    setState(() {
      if (value == 'backspace') {
        _amountString = (_amountString.length == 1)
            ? '0'
            : _amountString.substring(0, _amountString.length - 1);
      } else if (_amountString == '0') {
        _amountString = value;
      } else if (_amountString.length < 12) {
        _amountString += value;
      }
    });
  }

  Future<void> _pickTargetDate() async {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      // --- REFAKTOR: Styling modal ---
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CustomCalendarPicker(
          initialDate: _selectedTargetDate ?? DateTime.now(),
          firstDay: DateTime.now(), // Target gak boleh di masa lalu
        );
      },
    );

    if (picked != null && picked != _selectedTargetDate) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return BlocListener<SavingGoalBloc, SavingGoalState>(
      listener: (context, state) {
        if (state is! SavingGoalLoading) {
          setState(() {
            _isSaving = false;
          });
        }
        if (state is SavingGoalLoaded) {
          Navigator.of(context).pop();
        }
        if (state is SavingGoalError) {
          _showErrorSnackBar('Gagal menyimpan: ${state.message}');
        }
      },
      child: Scaffold(
        // --- REFAKTOR: Hapus 'backgroundColor' ---
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Celengan' : 'Celengan Baru',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          // --- REFAKTOR: Hapus styling, biarin AppBarTheme ---
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // --- REFAKTOR: Ganti TextFormField hardcode ---
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Celengan (Contoh: PS5)',
                      prefixIcon: Icon(Icons.drive_file_rename_outline,
                          color: colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- REFAKTOR: Ganti InkWell/Container hardcode ---
                  InkWell(
                    onTap: _pickTargetDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: theme.dividerColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 16),
                          Text(
                            _selectedTargetDate == null
                                ? 'Pilih Target Tanggal (Opsional)'
                                : DateFormat('d MMMM yyyy', 'id_ID')
                                    .format(_selectedTargetDate!),
                            // --- REFAKTOR: Ganti style/warna hardcode ---
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: _selectedTargetDate == null
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                              fontWeight: _selectedTargetDate == null
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currencyFormatter
                  .format(double.tryParse(_amountString) ?? 0.0),
              // --- REFAKTOR: Ganti warna hardcode (SEMANTIK) ---
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor, // (Biru = warna primer app)
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  // (Warna SEMANTIK, biarin)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEditing ? 'Simpan Perubahan' : 'Simpan',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // --- REFAKTOR: Panggil _buildNumpad ---
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  // --- REFAKTOR: Pindahin Numpad ke method baru biar rapi ---
  Widget _buildNumpad() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      // --- REFAKTOR: Ganti warna hardcode ---
      color: theme.cardColor,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.0,
        children: [
          _numpadButton('1'), _numpadButton('2'), _numpadButton('3'),
          _numpadButton('4'), _numpadButton('5'), _numpadButton('6'),
          _numpadButton('7'), _numpadButton('8'), _numpadButton('9'),
          _numpadButton(''), _numpadButton('0'), _numpadButton('backspace'),
        ],
      ),
    );
  }

  // --- REFAKTOR: Bikin numpad button-nya theme-aware ---
  Widget _numpadButton(String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (value == '') return Container();
    return InkWell(
      onTap: () => _onNumpadTapped(value),
      child: Center(
        child: value == 'backspace'
            ? Icon(Icons.backspace_outlined, color: colorScheme.onSurfaceVariant)
            : Text(
                value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}