import 'package:drift/drift.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';

// "Penerjemah" untuk SavingContribution
class SavingContributionModel extends SavingContribution {
  const SavingContributionModel({
    required super.id,
    required super.goalId,
    required super.amount,
    required super.transactionDate,
  });

  factory SavingContributionModel.fromEntity(SavingContribution entity) {
    return SavingContributionModel(
      id: entity.id,
      goalId: entity.goalId,
      amount: entity.amount,
      transactionDate: entity.transactionDate,
    );
  }

  factory SavingContributionModel.fromDrift(SavingContributionData driftData) {
    return SavingContributionModel(
      id: driftData.id,
      goalId: driftData.goalId,
      amount: driftData.amount,
      transactionDate: driftData.transactionDate,
    );
  }

  SavingContributionsCompanion toCompanion() {
    return SavingContributionsCompanion(
      id: (id == 0) ? const Value.absent() : Value(id),
      goalId: Value(goalId),
      amount: Value(amount),
      transactionDate: Value(transactionDate),
    );
  }
}