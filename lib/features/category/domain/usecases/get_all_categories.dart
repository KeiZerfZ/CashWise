import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';

// Implementasi UseCase dengan Type 'List<Category>' dan Params 'NoParams'
class GetAllCategories implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;

  GetAllCategories(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, List<Category>>>
  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}

