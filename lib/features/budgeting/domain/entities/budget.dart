import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int id;
  final int categoryId;
  final double amount;
  final int month;
  final int year;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [id, categoryId, amount, month, year];
}