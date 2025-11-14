import 'package:flutter/material.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
// BARU: Impor "kamus" ikon kita
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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // =================================================================
              // INI DIA PERBAIKANNYA!
              // =================================================================
              CircleAvatar(
                radius: 20,
                backgroundColor: category.color,
                // Ganti dari 'Icons.category' jadi 'getIconDataFromString'
                child: Icon(
                  getIconDataFromString(category.iconName), // <-- UDAH PINTER
                  color: Colors.white,
                  size: 20
                ),
              ),
              // =================================================================
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}