// lib/features/transaction/domain/usecases/get_all_transactions.dart

import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

class GetAllTransactions implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;

  GetAllTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) async {
    return await repository.getAllTransactions();
  }
}