import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

// Kontrak kerja untuk Category
abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, void>> addCategory(Category category);
}
