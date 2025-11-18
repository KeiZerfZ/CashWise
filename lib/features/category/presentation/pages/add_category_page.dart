// lib/features/category/presentation/pages/add_category_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart';

import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/presentation/widgets/common/custom_text_form_field.dart';
import 'package:cashwise/presentation/widgets/common/primary_button.dart';

class AddCategoryPage extends StatefulWidget {
  final Category? categoryToEdit;
  const AddCategoryPage({super.key, this.categoryToEdit});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late Color _selectedColor;
  late String _selectedIconName; // Ini nyimpen 'makanan', 'transportasi', dll.

  bool get _isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedColor = widget.categoryToEdit!.color;
      _selectedIconName = widget.categoryToEdit!.iconName;
    } else {
      _nameController.text = '';
      _selectedColor = Colors.blue; // Default color
      _selectedIconName = 'default'; // Ambil dari kamus iconMap
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditing) {
      final updatedCategory = Category(
        id: widget.categoryToEdit!.id,
        name: _nameController.text,
        color: _selectedColor,
        iconName: _selectedIconName,
      );
      context.read<CategoryBloc>().add(UpdateCategoryEvent(updatedCategory));
    } else {
      final newCategory = Category(
        id: 0,
        name: _nameController.text,
        color: _selectedColor,
        iconName: _selectedIconName,
      );
      context.read<CategoryBloc>().add(AddCategoryEvent(newCategory));
    }
    Navigator.pop(context);
  }

  void _pickColor() {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);
    Color tempColor = _selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // --- REFAKTOR: Styling dialog ---
        backgroundColor: theme.colorScheme.surface,
        title: Text('Pilih Warna', style: theme.textTheme.titleLarge),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            // --- REFAKTOR: Styling text di dalam picker ---
            labelTextStyle: theme.textTheme.bodyMedium,
          ),
        ),
        actions: <Widget>[
          // Tombol-tombol ini akan otomatis di-style oleh theme
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              setState(() => _selectedColor = tempColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _pickIcon() {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      // --- REFAKTOR: Styling modal ---
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- REFAKTOR: Styling judul modal ---
              Text('Pilih Ikon', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: iconMap.length,
                  itemBuilder: (context, index) {
                    final iconName = iconMap.keys.elementAt(index);
                    final iconData = iconMap.values.elementAt(index);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIconName = iconName;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          // --- REFAKTOR: Ganti border hardcode ---
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                          // (Ini SEMANTIK, biarin)
                          color: _selectedIconName == iconName
                              ? _selectedColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          iconData,
                          size: 32,
                          color: _selectedColor, // (Ini SEMANTIK, biarin)
                        ),
                      ),
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
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor' ---
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kategori' : 'Kategori Baru',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // --- REFAKTOR: Hapus 'foregroundColor' ---
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nama Kategori',
                prefixIcon: Icons.drive_file_rename_outline,
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickColor,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          // --- REFAKTOR: Ganti warna hardcode ---
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            // --- REFAKTOR: Ganti style hardcode ---
                            Text('Warna:', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _selectedColor, // (SEMANTIK, biarin)
                                shape: BoxShape.circle,
                                // --- REFAKTOR: Ganti border hardcode ---
                                border: Border.all(color: theme.dividerColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickIcon,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          // --- REFAKTOR: Ganti warna hardcode ---
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          // --- REFAKTOR: Ganti border hardcode ---
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            // --- REFAKTOR: Ganti style hardcode ---
                            Text('Ikon:', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Icon(
                              getIconDataFromString(_selectedIconName),
                              color: _selectedColor, // (SEMANTIK, biarin)
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                text: _isEditing ? 'Simpan Perubahan' : 'Simpan Kategori',
                onPressed: _saveCategory,
                backgroundColor: Colors.teal, // (SEMANTIK, biarin)
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}