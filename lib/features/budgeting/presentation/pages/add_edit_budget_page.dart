import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_event.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_state.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';

class AddEditBudgetPage extends StatefulWidget {
  final Budget? budget; // Jika null, berarti mode 'Tambah'. Jika ada isinya, mode 'Edit'
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  int? _selectedCategoryId;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: isEditing ? widget.budget!.amount.toStringAsFixed(0) : '',
    );
    _selectedCategoryId = isEditing ? widget.budget!.categoryId : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final newBudget = Budget(
        id: isEditing ? widget.budget!.id : 0, // ID 0 untuk budget baru
        categoryId: _selectedCategoryId!,
        amount: amount,
        month: widget.selectedDate.month,
        year: widget.selectedDate.year,
      );

      context.read<BudgetBloc>().add(SaveBudgetEvent(budget: newBudget));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetLoaded) {
          // Jika state kembali ke Loaded setelah menyimpan, berarti sukses.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Budget berhasil disimpan!')),
          );
          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        }
        if (state is BudgetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Budget' : 'Tambah Budget'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Dropdown untuk Kategori
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      hint: const Text('Pilih Kategori'),
                      items: state.categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Kategori harus dipilih' : null,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 16),
              // Input untuk Jumlah
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Anggaran',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Format angka tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}