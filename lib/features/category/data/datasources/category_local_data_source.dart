import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/category/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoriesCompanion category);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase database;

  CategoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final categoriesData = await database.select(database.categories).get();
    return categoriesData.map((data) => CategoryModel.fromDrift(data)).toList();
  }

  @override
  Future<void> addCategory(CategoriesCompanion category) async {
    await database.into(database.categories).insert(category);
  }
}