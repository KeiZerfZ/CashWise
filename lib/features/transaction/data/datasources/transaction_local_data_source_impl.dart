import 'package:cashwise/data/local/app_database.dart'; // Sesuaikan import database lo
import 'package:cashwise/features/transaction/data/models/transaction_model.dart';
import 'package:cashwise/features/transaction/data/datasources/transaction_local_data_source.dart';

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase database;

  TransactionLocalDataSourceImpl({required this.database});

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    // ... logika lo untuk get data dari database ...
    throw UnimplementedError(); // Hapus ini kalau sudah ada
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // ... logika lo untuk insert data ke database ...
    throw UnimplementedError(); // Hapus ini kalau sudah ada
  }

  // ========================================================
  // BARU: Implementasi method yang dibutuhkan oleh Repository
  // ========================================================
  @override
  Future<void> deleteTransaction(int id) async {
    // TODO: Tambahkan logika untuk MENGHAPUS data dari database berdasarkan ID
    // Contoh: await database.transactionDao.deleteTransactionById(id);
    print('Menghapus transaksi dengan ID: $id');
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    // TODO: Tambahkan logika untuk MENGUPDATE data di database
    // Contoh: await database.transactionDao.updateTransaction(transaction.toCompanion(true));
    print('Memperbarui transaksi: ${transaction.description}');
  }
}
