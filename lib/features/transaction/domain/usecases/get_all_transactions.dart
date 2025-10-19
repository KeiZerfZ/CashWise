import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

// Implementasi UseCase dengan Type 'List<Transaction>' dan Params 'NoParams'
class GetAllTransactions implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;

  GetAllTransactions(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, List<Transaction>>>
  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) async {
    // Repository tidak butuh params untuk getAll, jadi kita panggil langsung
    return await repository.getAllTransactions();
  }
}
