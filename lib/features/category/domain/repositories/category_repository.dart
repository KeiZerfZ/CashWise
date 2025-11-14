import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

// Ini adalah kontrak kerja untuk Category
abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, void>> addCategory(Category category);
  
  // BARU: Tambahkan "tugas" baru di kontrak
  Future<Either<Failure, void>> deleteCategory(int categoryId);
  Future<Either<Failure, void>> updateCategory(Category category);
}