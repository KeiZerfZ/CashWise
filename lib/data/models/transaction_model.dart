import 'package:drift/drift.dart' as drift;
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required int id, // <-- Balikin jadi required int
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
      id: entity.id,
      description: entity.description,
      amount: entity.amount,
      isExpense: entity.isExpense,
      transactionDate: entity.transactionDate,
      categoryId: entity.categoryId,
    );
  }

  // Ajarin lagi cara yang bener
  TransactionsCompanion toDrift() {
    return TransactionsCompanion(
      id: id == 0 ? const drift.Value.absent() : drift.Value(id),
      description: drift.Value(description),
      amount: drift.Value(amount),
      isExpense: drift.Value(isExpense),
      transactionDate: drift.Value(transactionDate),
      categoryId: drift.Value(categoryId),
    );
  }
}