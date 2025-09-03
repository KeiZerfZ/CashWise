// lib/features/transaction/data/models/transaction_model.dart

import 'package:drift/drift.dart' as drift;
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    int? id, // Ubah dari 'required int' jadi 'int?'
    required String description,
    required double amount,
    required bool isExpense,
    required DateTime transactionDate,
    int? categoryId,
  }) : super(
          id: id,
          description: description,
          amount: amount,
          isExpense: isExpense,
          transactionDate: transactionDate,
          categoryId: categoryId,
        );

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

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id, // Ini akan mengirim int?
      description: entity.description,
      amount: entity.amount,
      isExpense: entity.isExpense,
      transactionDate: entity.transactionDate,
      categoryId: entity.categoryId,
    );
  }

  // Bagian yang diperbaiki untuk menangani nullable ID
  TransactionsCompanion toDrift() {
    return TransactionsCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      description: drift.Value(description),
      amount: drift.Value(amount),
      isExpense: drift.Value(isExpense),
      transactionDate: drift.Value(transactionDate),
      categoryId: categoryId != null
          ? drift.Value(categoryId!)
          : const drift.Value.absent(),
    );
  }
}