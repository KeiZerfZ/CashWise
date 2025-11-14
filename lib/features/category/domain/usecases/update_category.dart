import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';

// Usecase ini juga ngikutin kontrak UseCase<Type, Params>
// Type-nya 'void'
// Params-nya 'Category' (dia bawa 1 objek kategori utuh yang mau di-update)
class UpdateCategory implements UseCase<void, Category> {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  // Pas BLoC manggil 'call', dia nerusin 1 objek Category utuh ke repository
  @override
  Future<Either<Failure, void>> call(Category category) async {
    return await repository.updateCategory(category);
  }
}