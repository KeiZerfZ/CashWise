import 'package:drift/drift.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/category/data/models/category_model.dart';
import 'package:cashwise/core/error/exceptions.dart'; // Pastikan lo punya file ini

// =================================================================
// KONTRAK (SUDAH LENGKAP)
// =================================================================
abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoriesCompanion category);
  // BARU: Tambahkan tugas hapus dan update di kontrak
  Future<void> deleteCategory(int id);
  Future<void> updateCategory(CategoriesCompanion category);
}

// =================================================================
// IMPLEMENTASI (SUDAH LENGKAP)
// =================================================================
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase database;

  CategoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final categoriesData = await database.select(database.categories).get();
      return categoriesData.map((data) => CategoryModel.fromDrift(data)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addCategory(CategoriesCompanion category) async {
    try {
      await database.into(database.categories).insert(category);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  // BARU: Implementasi fungsi hapus
  @override
  Future<void> deleteCategory(int id) async {
    try {
      await (database.delete(database.categories)..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  // BARU: Implementasi fungsi update
  @override
  Future<void> updateCategory(CategoriesCompanion category) async {
    try {
      // 'replace' akan mengupdate semua kolom berdasarkan primary key (ID)
      await database.update(database.categories).replace(category);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}