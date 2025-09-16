import 'package:equatable/equatable.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

class BudgetWithSpending extends Equatable {
  final int id; // ID dari budget itu sendiri
  final double amount; // Jumlah budget yang ditetapkan
  final double spentAmount; // Total pengeluaran untuk kategori ini di bulan ini
  final Category category; // Detail lengkap kategori yang dianggarkan

  const BudgetWithSpending({
    required this.id,
    required this.amount,
    required this.spentAmount,
    required this.category,
  });

  @override
  List<Object?> get props => [id, amount, spentAmount, category];
}