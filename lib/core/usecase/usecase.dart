// lib/core/usecase/usecase.dart

import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:equatable/equatable.dart'; // <--- Impor ini

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Ubah class ini
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}