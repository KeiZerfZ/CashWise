import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

// --- KONTRAK KERJA ---
abstract class DataBackupRepository {
  Future<void> exportData();
  Future<void> importData(File file);
}

// --- IMPLEMENTASI ---
class DataBackupRepositoryImpl implements DataBackupRepository {
  final AppDatabase database;
  
  DataBackupRepositoryImpl({required this.database});

  // =================================================================
  // FUNGSI EKSPOR (Ini udah bener)
  // =================================================================
  @override
  Future<void> exportData() async {
    // ... (KODE EXPORT LO DARI SEBELUMNYA ITU UDAH BENER 100%, GAK PERLU DIUBAH) ...
    // ... (Gue potong biar ringkas, pake aja kode lo yg lama)
    final transactions = await database.select(database.transactions).get();
    final categories = await database.select(database.categories).get();
    final budgets = await database.select(database.budgets).get();
    final savingGoals = await database.select(database.savingGoals).get();
    final contributions = await database.select(database.savingContributions).get();
    final allData = <List<dynamic>>[];
    allData.add(['# CASHWISE LOCAL BACKUP (CSV FORMAT V1.0)']);
    allData.add(['Generated On', DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())]);
    allData.add([]);
    allData.add(['TABLE: TRANSACTIONS']);
    allData.add(['id', 'description', 'amount', 'isExpense', 'categoryId', 'transactionDate']);
    for (var t in transactions) {
      allData.add([t.id, t.description, t.amount, t.isExpense, t.categoryId, t.transactionDate.toIso8601String()]);
    }
    allData.add([]); 
    allData.add(['TABLE: CATEGORIES']);
    allData.add(['id', 'name', 'color', 'iconName']);
    for (var c in categories) {
      allData.add([c.id, c.name, c.color, c.iconName]);
    }
    allData.add([]);
    allData.add(['TABLE: BUDGETS']);
    allData.add(['id', 'categoryId', 'amount', 'month', 'year']);
    for (var b in budgets) {
      allData.add([b.id, b.categoryId, b.amount, b.month, b.year]);
    }
    allData.add([]);
    allData.add(['TABLE: SAVING_GOALS']);
    allData.add(['id', 'name', 'targetAmount', 'targetDate']);
    for (var s in savingGoals) {
      allData.add([s.id, s.name, s.targetAmount, s.targetDate?.toIso8601String()]);
    }
    allData.add([]);
    allData.add(['TABLE: SAVING_CONTRIBUTIONS']);
    allData.add(['id', 'goalId', 'amount', 'transactionDate']);
    for (var c in contributions) {
      allData.add([c.id, c.goalId, c.amount, c.transactionDate.toIso8601String()]);
    }
    allData.add([]);
    final csvString = const ListToCsvConverter().convert(allData);
    final fileName = 'cashwise_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvString);
      await Share.shareXFiles([XFile(path, name: fileName)]);
    } 
    else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Backup Kamu',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(csvString);
      } else {
        throw Exception('Penyimpanan backup dibatalkan.');
      }
    }
  }

  // =================================================================
  // FUNGSI IMPOR (FIX TIPE DATA PARSING)
  // =================================================================
  @override
  Future<void> importData(File file) async {
    final fileContent = await file.readAsString();
    // Kita pake CsvToListConverter yang 'eol'-nya di-set '\n' biar aman
    // shouldParseNumbers: false -> Biar aman, kita parse manual semua
    final List<List<dynamic>> csvData = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(fileContent);

    if (csvData.isEmpty || !csvData[0][0].toString().startsWith('# CASHWISE LOCAL BACKUP')) {
      throw Exception('File backup tidak valid atau rusak.');
    }

    // Hapus semua data lama
    await database.customStatement('PRAGMA foreign_keys = OFF;');
    await database.delete(database.transactions).go();
    await database.delete(database.categories).go();
    await database.delete(database.budgets).go();
    await database.delete(database.savingGoals).go();
    await database.delete(database.savingContributions).go();
    
    // Parsing & Insert data baru
    String currentTable = "";
    for (var row in csvData) {
      if (row.isEmpty) continue;
      final cell1 = row[0].toString();
      if (cell1.startsWith('TABLE:')) {
        currentTable = cell1.split(': ')[1];
        continue;
      }
      if (cell1.startsWith('#') || cell1 == 'Generated On' || cell1 == 'id') {
        continue;
      }

      // Helper buat nge-parse data 'null'
      int? parseIntNullable(dynamic val) {
        if (val == null || val.toString().isEmpty || val.toString().toLowerCase() == 'null') return null;
        return int.parse(val.toString());
      }
      DateTime? parseDateNullable(dynamic val) {
        if (val == null || val.toString().isEmpty || val.toString().toLowerCase() == 'null') return null;
        return DateTime.parse(val.toString());
      }

      try {
        switch (currentTable) {
          case 'TRANSACTIONS':
            // =================================================================
            // INI DIA PERBAIKANNYA! (Parse manual semua)
            // =================================================================
            await database.into(database.transactions).insert(TransactionsCompanion(
              id: Value(int.parse(row[0].toString())), 
              description: Value(row[1].toString()),
              amount: Value(double.parse(row[2].toString())),
              isExpense: Value(row[3].toString().toLowerCase() == 'true'),
              categoryId: Value(parseIntNullable(row[4])),
              transactionDate: Value(DateTime.parse(row[5].toString())),
            ));
            break;
          case 'CATEGORIES':
            await database.into(database.categories).insert(CategoriesCompanion(
              id: Value(int.parse(row[0].toString())),
              name: Value(row[1].toString()),
              color: Value(int.parse(row[2].toString())),
              iconName: Value(row[3].toString()),
            ));
            break;
          case 'BUDGETS':
            await database.into(database.budgets).insert(BudgetsCompanion(
              id: Value(int.parse(row[0].toString())),
              categoryId: Value(int.parse(row[1].toString())),
              amount: Value(double.parse(row[2].toString())),
              month: Value(int.parse(row[3].toString())),
              year: Value(int.parse(row[4].toString())),
            ));
            break;
          case 'SAVING_GOALS':
            await database.into(database.savingGoals).insert(SavingGoalsCompanion(
              id: Value(int.parse(row[0].toString())),
              name: Value(row[1].toString()),
              targetAmount: Value(double.parse(row[2].toString())),
              targetDate: Value(parseDateNullable(row[3])),
            ));
            break;
          case 'SAVING_CONTRIBUTIONS':
            await database.into(database.savingContributions).insert(SavingContributionsCompanion(
              id: Value(int.parse(row[0].toString())),
              goalId: Value(int.parse(row[1].toString())),
              amount: Value(double.parse(row[2].toString())),
              transactionDate: Value(DateTime.parse(row[3].toString())),
            ));
            break;
        }
      } catch (e) {
        await database.customStatement('PRAGMA foreign_keys = ON;');
        throw Exception('Data di file rusak di tabel $currentTable (Baris: $row): ${e.toString()}');
      }
    }
    
    await database.customStatement('PRAGMA foreign_keys = ON;');
  }
}