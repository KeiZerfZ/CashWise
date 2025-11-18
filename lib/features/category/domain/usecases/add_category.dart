import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';

// INI DIA CLASS 'AddCategory' YANG DICARI-CARI!
class AddCategory implements UseCase<void, Category> {
  final CategoryRepository repository;

  AddCategory(this.repository);

  // Fungsi 'call' ini yang akan dipanggil oleh BLoC
  @override
  Future<Either<Failure, void>> call(Category category) async {
    return await repository.addCategory(category);
  }
}