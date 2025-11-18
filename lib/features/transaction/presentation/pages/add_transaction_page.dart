// lib/features/transaction/presentation/pages/add_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart';
import 'package:cashwise/presentation/widgets/common/custom_text_form_field.dart';
// --- BARU: Import halaman add category ---
import 'package:cashwise/features/category/presentation/pages/add_category_page.dart';


class AddTransactionPage extends StatefulWidget {
  final Transaction? transactionToEdit;

  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late TextEditingController _descriptionController;
  String _amountString = '0';
  Category? _selectedCategory;
  bool _isExpense = true;

  bool get _isEditing => widget.transactionToEdit != null;
  bool _isSaving = false;
  List<Category> _allCategories = [];

  @override
  void initState() {
    super.initState();

    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      _allCategories = categoryState.categories;
    }

    if (_isEditing) {
      final transaction = widget.transactionToEdit!;
      _descriptionController =
          TextEditingController(text: transaction.description);
      _amountString = transaction.amount.toStringAsFixed(0);
      _isExpense = transaction.isExpense;
      try {
        _selectedCategory =
            _allCategories.firstWhere((c) => c.id == transaction.categoryId);
      } catch (e) {
        _selectedCategory = null;
      }
    } else {
      _descriptionController = TextEditingController();
      _amountString = '0';
      _isExpense = true;
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_isSaving) return;

    final description = _descriptionController.text;
    final amount = double.tryParse(_amountString) ?? 0.0;

    if (description.isEmpty) {
      _showErrorSnackBar('Deskripsi tidak boleh kosong');
      return;
    }
    if (_selectedCategory == null) {
      _showErrorSnackBar('Kategori harus dipilih!');
      return;
    }
    if (amount <= 0) {
      _showErrorSnackBar('Jumlah transaksi harus lebih dari 0!');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (_isEditing) {
      final updatedTransaction = Transaction(
        id: widget.transactionToEdit!.id,
        description: description,
        amount: amount,
        isExpense: _isExpense,
        categoryId: _selectedCategory!.id,
        transactionDate: widget.transactionToEdit!.transactionDate,
      );
      context
          .read<TransactionBloc>()
          .add(UpdateTransactionEvent(updatedTransaction));
    } else {
      final newTransaction = Transaction(
        id: 0,
        description: description,
        amount: amount,
        isExpense: _isExpense,
        categoryId: _selectedCategory!.id,
        transactionDate: DateTime.now(),
      );
      context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));
    }
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

  void _pickCategory() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) { // Ganti nama context jadi modalContext
        final categoryState = modalContext.read<CategoryBloc>().state;
        if (categoryState is! CategoryLoaded) {
          return const Center(child: Text("Memuat kategori..."));
        }

        final allCategories = categoryState.categories;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Kategori', style: theme.textTheme.titleLarge),

              // =================================================================
              // INI DIA IDE-NYA! (Tombol Jalan Pintas)
              // =================================================================
              TextButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Buat Kategori Baru'),
                onPressed: () {
                  // 1. Tutup modal 'Pilih Kategori'
                  Navigator.pop(modalContext); 
                  
                  // 2. Buka halaman 'AddCategoryPage'
                  // Kita pake 'context' dari widget utama, bukan 'modalContext'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCategoryPage(),
                    ),
                  );
                },
              ),
              // =================================================================

              const Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.1),
                        foregroundColor: category.color,
                        child: Icon(getIconDataFromString(category.iconName)),
                      ),
                      title: Text(category.name,
                          style: theme.textTheme.bodyLarge),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(modalContext); // Tutup modal
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

  // ... (Sisa kode build() dan helper widget lainnya gak ada perubahan)
  // ... (Gua salin aja ya)

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final theme = Theme.of(context);

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is! TransactionLoading) {
          setState(() {
            _isSaving = false;
          });
        }
        if (state is TransactionLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Transaksi berhasil disimpan!'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
        if (state is TransactionError) {
          _showErrorSnackBar('Gagal menyimpan: ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Transaksi' : 'Transaksi Baru',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeToggle(
                          title: 'Pengeluaran',
                          icon: Icons.arrow_upward,
                          isSelected: _isExpense,
                          onTap: () {
                            setState(() {
                              _isExpense = true;
                              _selectedCategory = null; // Reset kategori
                            });
                          },
                          color: Colors.red, // (Warna SEMANTIK)
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTypeToggle(
                          title: 'Pemasukan',
                          icon: Icons.arrow_downward,
                          isSelected: !_isExpense,
                          onTap: () {
                            setState(() {
                              _isExpense = false;
                              _selectedCategory = null; // Reset kategori
                            });
                          },
                          color: Colors.green, // (Warna SEMANTIK)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _descriptionController,
                    labelText: 'Deskripsi',
                    prefixIcon: Icons.drive_file_rename_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(),
                ],
              ),
            ),
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
                    backgroundColor: theme.primaryColor,
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
                          _isEditing ? 'Simpan Perubahan' : 'Simpan',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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

  Widget _buildTypeToggle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required MaterialColor color,
  }) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final Color semanticColor = isLightMode ? color.shade700 : color.shade300;
    final Color semanticBg =
        isLightMode ? color.shade50 : color.shade900.withOpacity(0.3);
    final Color borderColor =
        isLightMode ? Colors.grey.shade300 : theme.dividerColor;
    final Color textColor =
        isLightMode ? Colors.grey.shade700 : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? semanticBg : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? semanticColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? semanticColor : textColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? semanticColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            if (_selectedCategory == null)
              CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
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
              Text('Pilih Kategori',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ))
            else
              Text(_selectedCategory!.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(NumberFormat formatter) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final Color amountColor = _isExpense
        ? (isLightMode ? Colors.red.shade700 : Colors.red.shade300)
        : (isLightMode ? Colors.green.shade700 : Colors.green.shade300);

    final displayAmount =
        formatter.format(double.tryParse(_amountString) ?? 0.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        displayAmount,
        style: theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: amountColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNumpad() {
    final theme = Theme.of(context);

    return Container(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (value == '') return Container();
    return InkWell(
      onTap: () => _onNumpadTapped(value),
      child: Center(
        child: value == 'backspace'
            ? Icon(Icons.backspace_outlined,
                color: colorScheme.onSurfaceVariant)
            : Text(
                value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}