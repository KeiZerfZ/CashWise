// HANYA GANTI BAGIAN CONSTRUCTOR DAN BUILD METHOD
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final IconData? prefixIcon;
  // BARU: Tambahkan parameter ini
  final ValueChanged<String>? onFieldSubmitted; 

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    required this.validator,
    this.prefixIcon,
    this.onFieldSubmitted, // <-- WAJIB DITAMBAHKAN DI CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey.shade600) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      // BARU: Meneruskan parameter ke TextFormField
      onFieldSubmitted: onFieldSubmitted, 
    );
  }
}