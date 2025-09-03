// lib/features/transaction/data/repositories/transaction_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/core/error/failures.dart';
// IMPORT YANG HILANG ADA DI BAWAH INI
import 'package:cashwise/data/models/transaction_model.dart';
import 'package:cashwise/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      // Kita butuh ID baru untuk transaksi, tapi entity tidak punya.
      // Kita buat model dari entity, dengan ID di-handle oleh database.
      final transactionModel = TransactionModel.fromEntity(transaction);
      await localDataSource.addTransaction(transactionModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getAllTransactions() async {
    try {
      final transactionModels = await localDataSource.getAllTransactions();
      // Kita secara eksplisit membuat list baru bertipe List<Transaction>
      // dari list model yang kita dapat.
      return Right(List<Transaction>.from(transactionModels)); 
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}