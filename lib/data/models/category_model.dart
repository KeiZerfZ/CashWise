import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required int id, // <-- Balikin jadi required int
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
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      iconName: entity.iconName,
    );
  }

  // Ajarin lagi cara yang bener
  CategoriesCompanion toDrift() {
    return CategoriesCompanion(
      id: id == 0 ? const drift.Value.absent() : drift.Value(id),
      name: drift.Value(name),
      color: drift.Value(color.value),
      iconName: drift.Value(iconName),
    );
  }
}