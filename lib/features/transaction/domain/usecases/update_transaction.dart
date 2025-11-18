// Import kerangka arsitektur dari folder core
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';

// Import entitas dan kontrak repository
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

// Usecase ini bertanggung jawab untuk memperbarui sebuah transaksi.
// Ia mendefinisikan bahwa ia akan mengembalikan void jika berhasil,
// dan membutuhkan seluruh objek 'Transaction' sebagai parameternya.
class UpdateTransaction implements UseCase<void, Transaction> {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  // Saat usecase ini dipanggil, ia akan meneruskan panggilan ke method updateTransaction di repository,
  // dengan membawa objek transaksi yang sudah diubah.
  @override
  Future<Either<Failure, void>> call(Transaction transaction) async {
    return await repository.updateTransaction(transaction);
  }
}
