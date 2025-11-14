import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// BARU: Import Color Picker
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// BARU: Import Kamus Ikon kita
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

  // =================================================================
  // FUNGSI PICK COLOR (SUDAH DIISI)
  // =================================================================
  void _pickColor() {
    // Bikin variabel sementara buat nyimpen warna
    Color tempColor = _selectedColor;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor, // Tampilin warna yang lagi kepilih
            onColorChanged: (color) {
              tempColor = color; // Update warna sementara
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              // Baru kita setState pas user neken OK
              setState(() => _selectedColor = tempColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // =================================================================
  // FUNGSI PICK ICON (SUDAH DIISI)
  // =================================================================
  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Ikon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Kita pake ConstrainedBox biar GridView-nya gak error
              ConstrainedBox(
                constraints: BoxConstraints(
                  // Set tinggi maksimal 50% layar
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 5 ikon per baris
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: iconMap.length, // Ambil jumlah ikon dari "kamus"
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
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          // Kasih highlight kalo ikonnya lagi dipilih
                          color: _selectedIconName == iconName ? _selectedColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Icon(
                          iconData,
                          size: 32,
                          color: _selectedColor, // Pake warna yang lagi dipilih
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kategori' : 'Kategori Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
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
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickColor, // <-- UDAH NYAMBUNG
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Text('Warna:', style: TextStyle(fontSize: 16)),
                            const Spacer(),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300)
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
                      onTap: _pickIcon, // <-- UDAH NYAMBUNG
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Text('Ikon:', style: TextStyle(fontSize: 16)),
                            const Spacer(),
                            // =================================================================
                            // BARU: TAMPILKAN IKON YANG DIPILIH SECARA DINAMIS
                            // =================================================================
                            Icon(
                              getIconDataFromString(_selectedIconName), // Pake "kamus"
                              color: _selectedColor,
                              size: 32
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