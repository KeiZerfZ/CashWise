// lib/features/transaction/data/datasources/transaction_local_data_source.dart

import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/data/models/transaction_model.dart';

// Kontrak untuk Data Source
abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
}


// Implementasi konkret dari kontrak di atas
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase database;

  TransactionLocalDataSourceImpl({required this.database});

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final transactionDataList = await database.select(database.transactions).get();
      // Ubah list of TransactionData (dari Drift) menjadi list of TransactionModel
      return transactionDataList
          .map((transactionData) => TransactionModel.fromDrift(transactionData))
          .toList();
    } catch (e) {
      // Kalau ada error dari database, bungkus jadi DatabaseException
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      // Ubah TransactionModel menjadi TransactionsCompanion (format Drift) untuk disimpan
      final transactionCompanion = transaction.toDrift();
      await database.into(database.transactions).insert(transactionCompanion);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}