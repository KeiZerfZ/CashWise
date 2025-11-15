import 'package:equatable/equatable.dart';

// Ini adalah "Riwayat Setoran"-nya
class SavingContribution extends Equatable {
  final int id;
  final int goalId; // <-- Nyambung ke 'SavingGoal'
  final double amount;
  final DateTime transactionDate;

  const SavingContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.transactionDate,
  });

  @override
  List<Object?> get props => [id, goalId, amount, transactionDate];
}