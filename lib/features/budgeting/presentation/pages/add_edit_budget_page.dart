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
        _selectedCategory = _allCategories.firstWhere((c) => c.id == initialCategoryId);
      } catch (e) {
        _selectedCategory = null;
      }
    }
  }

  void _onSave() {
    if (_isSaving) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori harus dipilih!'), backgroundColor: Colors.red),
      );
      return;
    }
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah anggaran harus lebih dari 0!'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() { _isSaving = true; });
    
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final categoryState = context.read<CategoryBloc>().state;
        if (categoryState is! CategoryLoaded) {
          return const Center(child: Text("Memuat kategori..."));
        }
        
        // =================================================================
        // INI DIA FIX-NYA: Kita GAK PAKE FILTER 'isExpense'
        // Kita tampilkan SEMUA kategori, sesuai "Aturan Emas" kita
        // =================================================================
        final allCategories = categoryState.categories; 
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCategories.length, // <-- Ganti ke allCategories
                  itemBuilder: (context, index) {
                    final category = allCategories[index]; // <-- Ganti ke allCategories
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.1),
                        foregroundColor: category.color,
                        child: Icon(getIconDataFromString(category.iconName)),
                      ),
                      title: Text(category.name),
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
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is! BudgetLoading) {
          setState(() { _isSaving = false; });
        }
        if (state is BudgetLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget berhasil disimpan!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
        if (state is BudgetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Budget' : 'Tambah Budget', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Simpan Perubahan' : 'Simpan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)
        ),
        child: Row(
          children: [
            if (_selectedCategory == null)
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade600,
                child: const Icon(Icons.question_mark),
              )
            else
              CircleAvatar(
                backgroundColor: _selectedCategory!.color.withOpacity(0.1),
                foregroundColor: _selectedCategory!.color,
                child: Icon(getIconDataFromString(_selectedCategory!.iconName)),
              ),
            const SizedBox(width: 16),
            if (_selectedCategory == null)
              const Text('Pilih Kategori', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500))
            else
              Text(_selectedCategory!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(NumberFormat formatter) {
    final displayAmount = formatter.format(double.tryParse(_amountString) ?? 0.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        displayAmount,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.8),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      color: Colors.white,
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
    if (value == '') return Container();
    return InkWell(
      onTap: () => _onNumpadTapped(value),
      child: Center(
        child: value == 'backspace'
            ? const Icon(Icons.backspace_outlined, color: Colors.grey)
            : Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}