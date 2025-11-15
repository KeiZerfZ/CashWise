// lib/features/category/presentation/widgets/category_list_item.dart

import 'package:flutter/material.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/presentation/utils/icon_helper.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryListItem({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // --- REFAKTOR: Hapus 'elevation', biarin CardTheme ---
      margin: const EdgeInsets.all(0),
      // shape: RoundedRectangleBorder( // Biarin CardTheme yang urus
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // (Samain sama CardTheme)
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // (CircleAvatar ini SEMANTIK, jadi biarin.
              // Warnanya sesuai pilihan user, bukan theme)
              CircleAvatar(
                radius: 20,
                backgroundColor: category.color,
                child: Icon(
                  getIconDataFromString(category.iconName),
                  color: Colors.white, // Asumsi user pilih warna yg kontras
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.name,
                  // --- REFAKTOR: Ganti style hardcode ---
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (onTap != null)
                // --- REFAKTOR: Ganti warna hardcode ---
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}