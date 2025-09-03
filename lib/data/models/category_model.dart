// lib/features/category/data/models/category_model.dart

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    int? id, // Ubah ke int?
    required String name,
    required Color color,
    required String iconName,
  }) : super(id: id, name: name, color: color, iconName: iconName);

  factory CategoryModel.fromDrift(CategoryData driftData) {
    return CategoryModel(
      id: driftData.id,
      name: driftData.name,
      color: Color(driftData.color),
      iconName: driftData.iconName,
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    // Karena entity.id bisa null, langsung kirim aja
    return CategoryModel(
      id: entity.id, 
      name: entity.name,
      color: entity.color,
      iconName: entity.iconName,
    );
  }

  CategoriesCompanion toDrift() {
    return CategoriesCompanion(
      // Kondisional untuk ID
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      name: drift.Value(name),
      color: drift.Value(color.value),
      iconName: drift.Value(iconName),
    );
  }
}