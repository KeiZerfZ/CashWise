import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.color,
    required super.iconName,
  });

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      iconName: entity.iconName,
    );
  }

  // =======================================================================
  // BAGIAN PALING KRUSIAL ADA DI SINI
  // =======================================================================
  // Menerjemahkan dari format database (CategoryData) ke format yang bisa dipakai (CategoryModel)
  factory CategoryModel.fromDrift(CategoryData driftData) {
    return CategoryModel(
      id: driftData.id,
      name: driftData.name,
      // FIX: Ubah integer dari database menjadi objek Color
      color: Color(driftData.color),
      iconName: driftData.iconName,
    );
  }

  // Menerjemahkan dari format yang bisa dipakai ke format database (CategoriesCompanion)
  CategoriesCompanion toCompanion() {
    return CategoriesCompanion(
      // id tidak perlu saat insert baru
      name: Value(name),
      // FIX: Ubah objek Color menjadi integer untuk disimpan di database
      color: Value(color.value), 
      iconName: Value(iconName),
    );
  }
}