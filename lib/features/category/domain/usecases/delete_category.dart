import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';

// Usecase ini ngikutin kontrak UseCase<Type, Params>
// Type-nya 'void' (karena gak ngembaliin data, cuma status sukses/gagal)
// Params-nya 'Params' (kelas kecil di bawah yang bawa ID)
class DeleteCategory implements UseCase<void, Params> {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  // Ini "tombol"-nya. Pas BLoC manggil 'call', dia bakal nerusin ke repository
  @override
  Future<Either<Failure, void>> call(Params params) async {
    return await repository.deleteCategory(params.id);
  }
}

// Ini "kurir" yang ngebawa ID dari BLoC ke UseCase
class Params extends Equatable {
  final int id;

  const Params({required this.id});

  @override
  List<Object> get props => [id];
}