import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/presentation/widgets/common/custom_text_form_field.dart';
import 'package:cashwise/presentation/widgets/common/primary_button.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchAllCategories());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: null, // Diperbaiki: Ubah 0 menjadi null
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        isExpense: true,
        transactionDate: DateTime.now(),
        categoryId: _selectedCategory?.id,
      );
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Transaksi Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                prefixIcon: Icons.description_outlined,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _amountController,
                labelText: 'Jumlah',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Jumlah tidak boleh kosong';
                  if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      hint: const Text('Pilih Kategori'),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade600),
                        border: InputBorder.none, // Diperbaiki: Hapus border
                        enabledBorder: InputBorder.none, // Diperbaiki: Hapus border saat aktif
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.teal.shade300, width: 1.5)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: state.categories.map((category) {
                        return DropdownMenuItem<Category>(value: category, child: Text(category.name));
                      }).toList(),
                      onChanged: (category) => setState(() => _selectedCategory = category),
                      validator: (value) => value == null ? 'Pilih kategori' : null,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Simpan Transaksi',
                onPressed: _saveTransaction,
                backgroundColor: Colors.teal,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}