import 'package:equatable/equatable.dart';

// Ini adalah "Celengan"-nya
class SavingGoal extends Equatable {
  final int id;
  final String name;
  final double targetAmount;
  final DateTime? targetDate;

  const SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.targetDate,
  });

  @override
  List<Object?> get props => [id, name, targetAmount, targetDate];
}