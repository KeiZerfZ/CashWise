// lib/features/budgeting/presentation/pages/add_edit_budget_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_event.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_state.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart'; // Import kamus ikon

class AddEditBudgetPage extends StatefulWidget {
  final Budget? budget;
  final DateTime selectedDate;

  const AddEditBudgetPage({
    super.key,
    this.budget,
    required this.selectedDate,
  });

  @override
  State<AddEditBudgetPage> createState() => _AddEditBudgetPageState();
}

class _AddEditBudgetPageState extends State<AddEditBudgetPage> {
  String _amountString = '0';
  Category? _selectedCategory;

  bool get isEditing => widget.budget != null;
  bool _isSaving = false;

  List<Category> _allCategories = [];

  @override
  void initState() {
    super.initState();

    // Ambil kategori dari state BLoC yang udah diload di main.dart
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      _allCategories = categoryState.categories;
    }

    if (isEditing) {
      _amountString = widget.budget!.amount.toStringAsFixed(0);
      final int initialCategoryId = widget.budget!.categoryId;
      try {
        _selectedCategory =
            _allCategories.firstWhere((c) => c.id == initialCategoryId);
      } catch (e) {
        _selectedCategory = null;
      }
    }
  }

  void _onSave() {
    if (_isSaving) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kategori harus dipilih!'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Jumlah anggaran harus lebih dari 0!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newBudget = Budget(
      id: isEditing ? widget.budget!.id : 0,
      categoryId: _selectedCategory!.id,
      amount: amount,
      month: widget.selectedDate.month,
      year: widget.selectedDate.year,
    );
    context.read<BudgetBloc>().add(SaveBudgetEvent(budget: newBudget));
  }

  void _onNumpadTapped(String value) {
    if (_isSaving) return;

    setState(() {
      if (value == 'backspace') {
        if (_amountString.length == 1) {
          _amountString = '0';
        } else {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        }
      } else if (_amountString == '0') {
        _amountString = value;
      } else {
        if (_amountString.length < 12) {
          _amountString += value;
        }
      }
    });
  }

  void _pickCategory() {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      // --- REFAKTOR: Biar modal-nya ngikut theme ---
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final categoryState = context.read<CategoryBloc>().state;
        if (categoryState is! CategoryLoaded) {
          return const Center(child: Text("Memuat kategori..."));
        }

        final allCategories = categoryState.categories;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- REFAKTOR: Styling judul modal ---
              Text('Pilih Kategori', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    return ListTile(
                      // (Warna circle avatar biarin, karena itu SEMANTIC
                      // berdasarkan warna kategori, bukan theme)
                      leading: CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.1),
                        foregroundColor: category.color,
                        child: Icon(getIconDataFromString(category.iconName)),
                      ),
                      // --- REFAKTOR: Styling text modal ---
                      title:
                          Text(category.name, style: theme.textTheme.bodyLarge),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);

    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is! BudgetLoading) {
          setState(() {
            _isSaving = false;
          });
        }
        if (state is BudgetLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Budget berhasil disimpan!'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
        if (state is BudgetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menyimpan: ${state.message}'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        // --- REFAKTOR: Hapus 'backgroundColor', biarin theme ---
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Budget' : 'Tambah Budget',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          // --- REFAKTOR: Biarin transparan, tapi hapus foregroundColor ---
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildAmountDisplay(currencyFormatter),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  // --- REFAKTOR: Ganti warna tombol ---
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Tetap teal, ini semantik
                    foregroundColor: Colors.white, // Tetap putih
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
                      : Text(isEditing ? 'Simpan Perubahan' : 'Simpan',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // --- REFAKTOR: Ganti warna hardcode ---
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            if (_selectedCategory == null)
              CircleAvatar(
                // --- REFAKTOR: Ganti warna hardcode ---
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                child: const Icon(Icons.question_mark),
              )
            else
              // (Ini biarin, semantik by category color)
              CircleAvatar(
                backgroundColor: _selectedCategory!.color.withOpacity(0.1),
                foregroundColor: _selectedCategory!.color,
                child: Icon(getIconDataFromString(_selectedCategory!.iconName)),
              ),
            const SizedBox(width: 16),
            if (_selectedCategory == null)
              // --- REFAKTOR: Ganti style hardcode ---
              Text('Pilih Kategori',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 18,
                  ))
            else
              // --- REFAKTOR: Ganti style hardcode ---
              Text(_selectedCategory!.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const Spacer(),
            // --- REFAKTOR: Ganti warna hardcode ---
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(NumberFormat formatter) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayAmount = formatter.format(double.tryParse(_amountString) ?? 0.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        displayAmount,
        // --- REFAKTOR: Ganti style & warna hardcode ---
        style: theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNumpad() {
    // --- REFAKTOR: Ambil theme & colorScheme ---
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
          _numpadButton('1'),
          _numpadButton('2'),
          _numpadButton('3'),
          _numpadButton('4'),
          _numpadButton('5'),
          _numpadButton('6'),
          _numpadButton('7'),
          _numpadButton('8'),
          _numpadButton('9'),
          _numpadButton(''),
          _numpadButton('0'),
          _numpadButton('backspace'),
        ],
      ),
    );
  }

  Widget _numpadButton(String value) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (value == '') return Container();
    return InkWell(
      onTap: () => _onNumpadTapped(value),
      child: Center(
        child: value == 'backspace'
            // --- REFAKTOR: Ganti warna hardcode ---
            ? Icon(Icons.backspace_outlined, color: colorScheme.onSurfaceVariant)
            // --- REFAKTOR: Ganti style hardcode ---
            : Text(
                value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}