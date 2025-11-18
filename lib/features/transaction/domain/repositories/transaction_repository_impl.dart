import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/transaction/data/datasources/transaction_local_data_source.dart';
// BARU: Import TransactionModel
import 'package:cashwise/features/transaction/data/models/transaction_model.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getAllTransactions() async {
    try {
      // DataSource mengembalikan List<TransactionModel>, Repository mengembalikan List<Transaction> (entity)
      final transactionModels = await localDataSource.getAllTransactions();
      return Right(transactionModels); // Dart bisa otomatis konversi karena TransactionModel extends Transaction
    } catch (e) {
      return Left(DatabaseFailure('Gagal mengambil data transaksi: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      // =================================================================
      // FIX DI SINI: Konversi dari Transaction (Entity) ke TransactionModel
      // =================================================================
      final transactionModel = TransactionModel.fromEntity(transaction);
      await localDataSource.addTransaction(transactionModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Gagal menambah transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Gagal menghapus transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(Transaction transaction) async {
    try {
      // =================================================================
      // FIX DI SINI: Konversi dari Transaction (Entity) ke TransactionModel
      // =================================================================
      final transactionModel = TransactionModel.fromEntity(transaction);
      await localDataSource.updateTransaction(transactionModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Gagal memperbarui transaksi: $e'));
    }
  }
}

