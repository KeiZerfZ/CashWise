import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoryModel category);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase database;

  CategoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final results = await database.select(database.categories).get();
      return results.map((data) => CategoryModel.fromDrift(data)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    try {
      await database.into(database.categories).insert(category.toDrift());
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}