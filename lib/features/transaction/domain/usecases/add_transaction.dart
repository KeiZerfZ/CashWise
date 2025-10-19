import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

// Implementasi UseCase dengan Type 'void' dan Params 'Transaction'
class AddTransaction implements UseCase<void, Transaction> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, void>>
  @override
  Future<Either<Failure, void>> call(Transaction params) async {
    return await repository.addTransaction(params);
  }
}
