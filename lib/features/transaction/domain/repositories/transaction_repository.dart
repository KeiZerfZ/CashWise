import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

// Ini adalah kontrak yang mendefinisikan SEMUA kemampuan yang harus dimiliki oleh sebuah TransactionRepository.
abstract class TransactionRepository {
  // Mengambil semua transaksi
  Future<Either<Failure, List<Transaction>>> getAllTransactions();

  // Menambahkan sebuah transaksi
  Future<Either<Failure, void>> addTransaction(Transaction transaction);

  // BARU: Menghapus sebuah transaksi berdasarkan ID
  Future<Either<Failure, void>> deleteTransaction(int id);

  // BARU: Memperbarui sebuah transaksi
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);
}
