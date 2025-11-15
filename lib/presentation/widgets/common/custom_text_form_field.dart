// lib/presentation/widgets/common/custom_text_form_field.dart

import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final IconData? prefixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    required this.validator,
    this.prefixIcon,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        // --- REFAKTOR: Ganti warna hardcode ---
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant)
            : null,
        filled: true,
        // --- REFAKTOR: Ganti warna hardcode ---
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // (Pilihan desain lu kita hargai)
        ),
        // (Warna label/text otomatis ngikut theme)
      ),
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}