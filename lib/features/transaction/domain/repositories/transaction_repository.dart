// lib/features/transaction/domain/repositories/transaction_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

abstract class TransactionRepository {
  // Mengambil semua transaksi, hasilnya bisa berupa Failure atau List<Transaction>
  Future<Either<Failure, List<Transaction>>> getAllTransactions();
  
  // Menambah transaksi baru, hasilnya bisa berupa Failure atau void (sukses)
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
  
  // Nanti bisa ditambahkan method lain di sini, seperti:
  // Future<Either<Failure, void>> updateTransaction(Transaction transaction);
  // Future<Either<Failure, void>> deleteTransaction(int id);
}