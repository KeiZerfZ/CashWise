import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';

// Implementasi UseCase dengan Type 'void' dan Params 'Category'
class AddCategory implements UseCase<void, Category> {
  final CategoryRepository repository;

  AddCategory(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, void>>
  @override
  Future<Either<Failure, void>> call(Category params) async {
    return await repository.addCategory(params);
  }
}

