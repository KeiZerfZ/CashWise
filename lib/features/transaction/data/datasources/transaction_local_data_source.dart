import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/data/local/app_database.dart';
// Ganti import ini ke path model yang baru
import 'package:cashwise/features/transaction/data/models/transaction_model.dart';
import 'package:drift/drift.dart'; // Import Drift untuk akses 'Value()'

// =======================================================================
// KONTRAK UNTUK DATA SOURCE (SUDAH DIUPDATE)
// =======================================================================
abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  // BARU: Tambahkan tugas hapus dan update di kontrak
  Future<void> deleteTransaction(int id);
  Future<void> updateTransaction(TransactionModel transaction);
}


// =======================================================================
// IMPLEMENTASI KONKRET DARI KONTRAK (SUDAH DIUPDATE)
// =======================================================================
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase database;

  TransactionLocalDataSourceImpl({required this.database});

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final transactionDataList = await database.select(database.transactions).get();
      return transactionDataList
          .map((transactionData) => TransactionModel.fromDrift(transactionData))
          .toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final transactionCompanion = transaction.toDrift();
      await database.into(database.transactions).insert(transactionCompanion);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  // -----------------------------------------------------------------------
  // BARU: IMPLEMENTASI FUNGSI HAPUS MENGGUNAKAN DRIFT
  // -----------------------------------------------------------------------
  @override
  Future<void> deleteTransaction(int id) async {
    try {
      // Menggunakan statement delete dari Drift dengan where clause untuk mencocokkan ID
      await (database.delete(database.transactions)..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  // -----------------------------------------------------------------------
  // BARU: IMPLEMENTASI FUNGSI UPDATE MENGGUNAKAN DRIFT
  // -----------------------------------------------------------------------
  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      // Menggunakan statement update dari Drift dengan method 'replace'
      // 'replace' akan mengupdate semua kolom berdasarkan primary key (ID)
      final transactionCompanion = transaction.toDrift().copyWith(id: Value(transaction.id));
      await database.update(database.transactions).replace(transactionCompanion);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}

