// lib/features/transaction/domain/usecases/add_transaction.dart

import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

// Di sini, parameternya adalah object Transaction itu sendiri
class AddTransaction implements UseCase<void, Transaction> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(Transaction params) async {
    // Teruskan transaksi ke repository
    return await repository.addTransaction(params);
  }
}