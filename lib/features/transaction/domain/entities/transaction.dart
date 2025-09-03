import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id; // Ubah ini jadi nullable
  final String description;
  final double amount;
  final bool isExpense;
  final DateTime transactionDate;
  final int? categoryId;

  const Transaction({
    this.id, // Hapus 'required'
    required this.description,
    required this.amount,
    required this.isExpense,
    required this.transactionDate,
    this.categoryId,
  });

  @override
  List<Object?> get props => [id, description, amount, isExpense, transactionDate, categoryId];
}