import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        id: null, // Ganti ini jadi null
        name: _nameController.text,
        color: Colors.blueAccent.shade400,
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
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nama Kategori',
                prefixIcon: Icons.label_outline_rounded,
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Simpan Kategori',
                onPressed: _saveCategory,
                backgroundColor: Colors.indigo,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}