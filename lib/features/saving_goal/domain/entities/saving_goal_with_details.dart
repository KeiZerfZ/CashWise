import 'package:equatable/equatable.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';

// Ini "paket gabungan" buat nampilin di UI Markas
// Isinya: Celengan + Total duit yang udah kekumpul
class SavingGoalWithDetails extends Equatable {
  final SavingGoal goal;
  final double totalContribution; // Total setoran yang udah masuk

  const SavingGoalWithDetails({
    required this.goal,
    required this.totalContribution,
  });

  // Helper biar gampang
  double get progress => (totalContribution / goal.targetAmount).clamp(0, 1);
  double get remainingAmount => (goal.targetAmount - totalContribution);
  bool get isAchieved => totalContribution >= goal.targetAmount;

  @override
  List<Object?> get props => [goal, totalContribution];
}