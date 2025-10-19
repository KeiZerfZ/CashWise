import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';

// INI ADALAH KONTRAK UTAMA / CETAKAN
// Tipe kembaliannya adalah Future<Either<Failure, Type>>
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Digunakan jika use case tidak memerlukan parameter
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

