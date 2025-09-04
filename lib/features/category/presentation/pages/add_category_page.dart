import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/category/presentation/widgets/color_selector.dart';
import 'package:cashwise/presentation/widgets/common/custom_text_form_field.dart';
import 'package:cashwise/presentation/widgets/common/primary_button.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  Color _selectedColor = Colors.red.shade300;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        id: 0, // <-- Pastiin ID-nya 0 untuk data baru
        name: _nameController.text,
        color: _selectedColor,
        iconName: 'default_icon',
      );
      context.read<CategoryBloc>().add(AddCategoryEvent(newCategory));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Kategori Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nama Kategori',
                prefixIcon: Icons.label_outline_rounded,
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Pilih Warna',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ColorSelector(
                onColorSelected: (color) {
                  // Gunakan setState untuk update warna tombol secara real-time
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Simpan Kategori',
                onPressed: _saveCategory,
                backgroundColor: _selectedColor,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}