import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:cashwise/features/transaction/data/models/transaction_model.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

// Ini adalah kelas PEKERJA yang menjalankan semua tugas di dalam KONTRAK
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  // TUGAS #1: MENGAMBIL SEMUA TRANSAKSI
  @override
  Future<Either<Failure, List<Transaction>>> getAllTransactions() async {
    try {
      final transactionModels = await localDataSource.getAllTransactions();
      // DataSource mengembalikan List<TransactionModel>, tapi UseCase butuh List<Transaction>.
      // Karena TransactionModel extends Transaction, kita bisa langsung return.
      return Right(transactionModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  // TUGAS #2: MENAMBAH TRANSAKSI
  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      // Konversi dari Entity (Transaction) ke Model sebelum dikirim ke DataSource
      final transactionModel = TransactionModel.fromEntity(transaction);
      await localDataSource.addTransaction(transactionModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  // ===================================================================
  // BARU: TUGAS #3 YANG KEMARIN KETINGGALAN
  // ===================================================================
  @override
  Future<Either<Failure, void>> deleteTransaction(int id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  // ===================================================================
  // BARU: TUGAS #4 YANG KEMARIN KETINGGALAN
  // ===================================================================
  @override
  Future<Either<Failure, void>> updateTransaction(Transaction transaction) async {
    try {
      // Konversi juga dari Entity ke Model
      final transactionModel = TransactionModel.fromEntity(transaction);
      await localDataSource.updateTransaction(transactionModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}

