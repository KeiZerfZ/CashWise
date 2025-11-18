// BARU: Import library Drift biar kenal sama 'Value()'
import 'package:drift/drift.dart';

import 'package:cashwise/data/local/app_database.dart'; // Import class TransactionData dari Drift
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

// TransactionModel adalah representasi data transaksi yang spesifik untuk lapisan data.
// Ia 'extends' Transaction agar mewarisi semua properti dasarnya, sehingga konversi ke entity jadi mudah.
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.isExpense,
    required super.transactionDate,
    super.categoryId,
  });

  // =======================================================================
  // JEMBATAN ANTARA DOMAIN LAYER DAN DATA LAYER
  // =======================================================================
  // Factory constructor untuk membuat TransactionModel dari objek Transaction (entity).
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      description: transaction.description,
      amount: transaction.amount,
      isExpense: transaction.isExpense,
      transactionDate: transaction.transactionDate,
      categoryId: transaction.categoryId,
    );
  }

  // =======================================================================
  // JEMBATAN ANTARA DATABASE (DRIFT) DAN DATA LAYER
  // =======================================================================
  // Factory constructor untuk membuat TransactionModel dari objek TransactionData (hasil query Drift).
  factory TransactionModel.fromDrift(TransactionData driftData) {
    return TransactionModel(
      id: driftData.id,
      description: driftData.description,
      amount: driftData.amount,
      isExpense: driftData.isExpense,
      transactionDate: driftData.transactionDate,
      categoryId: driftData.categoryId,
    );
  }

  // Method untuk mengubah TransactionModel menjadi TransactionsCompanion (format untuk insert/update ke Drift).
  TransactionsCompanion toDrift() {
    return TransactionsCompanion(
      // id tidak diikutsertakan karena biasanya auto-increment saat insert
      description: Value(description),
      amount: Value(amount),
      isExpense: Value(isExpense),
      transactionDate: Value(transactionDate),
      categoryId: Value(categoryId),
    );
  }
}

