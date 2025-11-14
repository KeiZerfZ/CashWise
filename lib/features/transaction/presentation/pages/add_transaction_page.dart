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
  // BARU: Tambahkan parameter opsional ini.
  // Jika ini diisi, halaman akan masuk ke mode "Edit".
  final Transaction? transactionToEdit;

  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State untuk menyimpan kategori yang dipilih (sebagai objek)
  Category? _selectedCategory;
  // State untuk menyimpan ID kategori awal saat mode edit
  int? _initialCategoryId;
  
  // BARU: State untuk tipe transaksi (true = Pengeluaran, false = Pemasukan)
  bool _isExpense = true; 

  // BARU: Cek apakah kita dalam mode edit
  bool get _isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    // Panggil BLoC untuk ngambil data kategori
    context.read<CategoryBloc>().add(FetchAllCategories());

    // BARU: Logika untuk mode Edit
    if (_isEditing) {
      // Isi form dengan data yang mau diedit
      _descriptionController.text = widget.transactionToEdit!.description;
      _amountController.text = widget.transactionToEdit!.amount.toStringAsFixed(0); // Hapus desimal
      _isExpense = widget.transactionToEdit!.isExpense;
      // Simpan ID kategori awalnya. Kita akan set objeknya nanti pas BLoC loaded.
      _initialCategoryId = widget.transactionToEdit!.categoryId;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      
      if (_isEditing) {
        // =================================================================
        // LOGIKA UPDATE (EDIT)
        // =================================================================
        final updatedTransaction = Transaction(
          // Pakai ID dan tanggal asli dari data lama
          id: widget.transactionToEdit!.id,
          transactionDate: widget.transactionToEdit!.transactionDate,
          // Ambil data baru dari form
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          isExpense: _isExpense,
          categoryId: _selectedCategory?.id,
        );
        // Tembak event UPDATE
        context.read<TransactionBloc>().add(UpdateTransactionEvent(updatedTransaction));
        
      } else {
        // =================================================================
        // LOGIKA ADD (BARU) - (Ini kode lama lo)
        // =================================================================
        final transaction = Transaction(
          id: 0, // ID akan di-generate oleh database
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          isExpense: _isExpense, // <-- Gunakan state _isExpense
          transactionDate: DateTime.now(),
          categoryId: _selectedCategory?.id,
        );
        // Tembak event ADD
        context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
      }
      
      // Setelah simpan, kembali ke halaman sebelumnya
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        // BARU: Judul ganti sesuai mode
        title: Text(_isEditing ? 'Edit Transaksi' : 'Transaksi Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              // =================================================================
              // BARU: TOGGLE PEMASUKAN / PENGELUARAN
              // =================================================================
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_upward, color: Colors.red),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_downward, color: Colors.green),
                  ),
                ],
                selected: {_isExpense},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _isExpense = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                  selectedBackgroundColor: _isExpense ? Colors.red.shade50 : Colors.green.shade50,
                  selectedForegroundColor: _isExpense ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              // Field Deskripsi (Tidak berubah)
              CustomTextFormField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                prefixIcon: Icons.description_outlined,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              // Field Jumlah (Tidak berubah)
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
              // Dropdown Kategori
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    
                    // =================================================================
                    // BARU: Logika untuk set kategori awal saat mode Edit
                    // =================================================================
                    if (_initialCategoryId != null && state.categories.isNotEmpty) {
                      try {
                        _selectedCategory = state.categories.firstWhere((c) => c.id == _initialCategoryId);
                        _initialCategoryId = null; // Hentikan pengecekan
                      } catch (e) {
                        _initialCategoryId = null; // Kategori tidak ditemukan
                      }
                    }

                    return DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      hint: const Text('Pilih Kategori'),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      items: state.categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (category) => setState(() => _selectedCategory = category),
                      validator: (value) => value == null ? 'Pilih kategori' : null,
                    );
                  }
                  // Tampilan saat loading
                  return TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Memuat kategori...',
                      prefixIcon: const Icon(Icons.hourglass_top_rounded),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  );
                },
              ),
              const Spacer(), // Mendorong tombol ke bawah
              PrimaryButton(
                // BARU: Teks tombol ganti sesuai mode
                text: _isEditing ? 'Simpan Perubahan' : 'Simpan Transaksi',
                onPressed: _saveTransaction,
                backgroundColor: _isEditing ? Colors.blue.shade700 : Colors.teal,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}