import 'package:flutter/material.dart'; // <-- PERBAIKAN DI SINI
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:drift/drift.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';
import 'package:cashwise/features/category/domain/entities/category.dart' as category_entity;

abstract class BudgetLocalDataSource {
  Future<List<BudgetWithSpending>> getBudgetsWithSpending(int month, int year);
  Future<void> saveBudget(BudgetsCompanion budget);
  Future<void> deleteBudget(int budgetId);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final AppDatabase database;

  BudgetLocalDataSourceImpl({required this.database});

  @override
  Future<List<BudgetWithSpending>> getBudgetsWithSpending(int month, int year) async {
    try {
      // Langkah 1: Hitung total pengeluaran per kategori untuk bulan dan tahun tertentu.
      final spendingQuery = database.select(database.transactions)
        ..where((tbl) => tbl.isExpense.equals(true))
        ..where((tbl) => tbl.transactionDate.month.equals(month))
        ..where((tbl) => tbl.transactionDate.year.equals(year));

      final allSpendings = await spendingQuery.get();
      final Map<int, double> totalSpendingPerCategory = {};

      for (var transaction in allSpendings) {
        if (transaction.categoryId != null) {
          totalSpendingPerCategory.update(
            transaction.categoryId!,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }

      // Langkah 2: Ambil semua data budget untuk bulan ini, digabung dengan data kategorinya.
      final budgetQuery = database.select(database.budgets).join([
        innerJoin(database.categories, database.categories.id.equalsExp(database.budgets.categoryId)),
      ])
        ..where(database.budgets.month.equals(month))
        ..where(database.budgets.year.equals(year));

      final results = await budgetQuery.get();

      // Langkah 3: Gabungkan kedua data di Dart.
      return results.map((row) {
        final budgetData = row.readTable(database.budgets);
        final categoryData = row.readTable(database.categories);
        final spentAmount = totalSpendingPerCategory[budgetData.categoryId] ?? 0.0;

        return BudgetWithSpending(
          id: budgetData.id,
          amount: budgetData.amount,
          spentAmount: spentAmount,
          category: category_entity.Category(
            id: categoryData.id,
            name: categoryData.name,
            color: Color(categoryData.color), // Baris ini sekarang valid
            iconName: categoryData.iconName,
          ),
        );
      }).toList();

    } catch (e) {
      throw DatabaseException('Gagal mengambil data budget dengan pengeluaran.');
    }
  }
  
  @override
  Future<void> saveBudget(BudgetsCompanion budget) async {
    try {
      await database.into(database.budgets).insert(budget, mode: InsertMode.replace);
    } catch (e) {
      throw DatabaseException('Gagal menyimpan budget.');
    }
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    try {
      await (database.delete(database.budgets)..where((tbl) => tbl.id.equals(budgetId))).go();
    } catch (e) {
      throw DatabaseException('Gagal menghapus budget.');
    }
  }
}