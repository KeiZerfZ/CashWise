// lib/data/local/app_database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import semua file definisi tabel (nanti kita buat)
part 'app_database.g.dart'; // Ini adalah file yang akan di-generate oleh Drift

// Definisikan tabel-tabel di sini
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()(); // Simpan sebagai integer ARGB
  TextColumn get iconName => text()();
}

@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1)();
  RealColumn get amount => real()();
  BoolColumn get isExpense => boolean().withDefault(const Constant(true))();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get transactionDate => dateTime()();
}

@DataClassName('BudgetData')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    'UNIQUE(category_id, month, year)'
  ];
}

@DataClassName('SavingGoalData')
class SavingGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SavingContributionData')
class SavingContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(SavingGoals, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  DateTimeColumn get transactionDate => dateTime()();
}


// Ini adalah class database utama
@DriftDatabase(tables: [
  Categories,
  Transactions,
  Budgets,
  SavingGoals,
  SavingContributions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // Mulai dari versi 1
}

// Fungsi ini mengatur di mana file database akan disimpan
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cashwise.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}