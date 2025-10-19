import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/category/data/datasources/category_local_data_source.dart';
import 'package:cashwise/features/category/data/models/category_model.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final categoryModels = await localDataSource.getAllCategories();
      return Right(categoryModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final companion = categoryModel.toCompanion();
      await localDataSource.addCategory(companion);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}