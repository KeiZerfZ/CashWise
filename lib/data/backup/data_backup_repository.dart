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
    final transactions = await database.select(database.transactions).get();
    final categories = await database.select(database.categories).get();
    final budgets = await database.select(database.budgets).get();
    final savingGoals = await database.select(database.savingGoals).get();
    final contributions =
        await database.select(database.savingContributions).get();
    final allData = <List<dynamic>>[];
    allData.add(['# CASHWISE LOCAL BACKUP (CSV FORMAT V1.0)']);
    allData.add(
        ['Generated On', DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())]);
    allData.add([]);
    allData.add(['TABLE: TRANSACTIONS']);
    allData.add([
      'id',
      'description',
      'amount',
      'isExpense',
      'categoryId',
      'transactionDate'
    ]);
    for (var t in transactions) {
      allData.add([
        t.id,
        t.description,
        t.amount,
        t.isExpense,
        t.categoryId,
        t.transactionDate.toIso8601String()
      ]);
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
      allData.add(
          [c.id, c.goalId, c.amount, c.transactionDate.toIso8601String()]);
    }
    allData.add([]);
    final csvString = const ListToCsvConverter().convert(allData);
    final fileName =
        'cashwise_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvString);
      await Share.shareXFiles([XFile(path, name: fileName)]);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
  // FUNGSI IMPOR (FINAL FIX)
  // =================================================================
  @override
  Future<void> importData(File file) async {
    final fileContent = await file.readAsString();
    
    // [FIX 1]
    // Hapus 'eol: \n' biar parser otomatis deteksi \n atau \r\n
    final List<List<dynamic>> csvData =
        const CsvToListConverter(shouldParseNumbers: false).convert(fileContent);

    if (csvData.isEmpty ||
        !csvData[0][0].toString().startsWith('# CASHWISE LOCAL BACKUP')) {
      throw Exception('File backup tidak valid atau rusak.');
    }

    // Hapus semua data lama
    await database.customStatement('PRAGMA foreign_keys = OFF;');
    await database.delete(database.transactions).go();
    await database.delete(database.categories).go();
    await database.delete(database.budgets).go();
    await database.delete(database.savingGoals).go();
    await database.delete(database.savingContributions).go();

    // Reset "counter" ID (AutoIncrement)
    await database.customStatement(
        "DELETE FROM sqlite_sequence WHERE name IN ('transactions', 'categories', 'budgets', 'saving_goals', 'saving_contributions');");

    // [FIX 2]
    // Helper "Penerjemah" (semua ditambah .trim())
    int? parseIntNullable(dynamic val) {
      final str = val.toString().trim(); // Tambah .trim()
      if (val == null || str.isEmpty || str.toLowerCase() == 'null') return null;
      return int.parse(str);
    }
    
    DateTime? parseDateNullable(dynamic val) {
      final str = val.toString().trim(); // Tambah .trim()
      if (val == null || str.isEmpty || str.toLowerCase() == 'null') return null;
      return DateTime.parse(str);
    }
    
    // Bikin helper baru buat tanggal non-nullable
    DateTime parseDate(dynamic val) => DateTime.parse(val.toString().trim());

    bool parseBool(dynamic val) => val.toString().trim().toLowerCase() == 'true'; // Tambah .trim()
    double parseDouble(dynamic val) => double.parse(val.toString().trim()); // Tambah .trim()
    int parseInt(dynamic val) => int.parse(val.toString().trim()); // Tambah .trim()
    String parseString(dynamic val) => val.toString().trim(); // Tambah .trim()

    // Parsing & Insert data baru
    String currentTable = "";
    for (var row in csvData) {
      if (row.isEmpty) continue; // Nangkep baris []
      
      final cell1 = row[0].toString().trim();

      // --- [FIX BARU DARI ERROR KEDUA] ---
      // Kalo cell pertamanya kosong, ini pasti baris sampah (kayak barIS [''])
      // di antara tabel. Langsung skip.
      if (cell1.isEmpty) continue; // Nangkep baris ['']
      // ------------------------------------

      if (cell1.startsWith('TABLE:')) {
        currentTable = cell1.split(': ')[1].trim();
        continue;
      }
      if (cell1.startsWith('#') || cell1 == 'Generated On' || cell1 == 'id') {
        continue;
      }

      try {
        switch (currentTable) {
          case 'TRANSACTIONS':
            await database.into(database.transactions).insert(TransactionsCompanion(
                  id: Value(parseInt(row[0])),
                  description: Value(parseString(row[1])),
                  amount: Value(parseDouble(row[2])),
                  isExpense: Value(parseBool(row[3])),
                  categoryId: Value(parseIntNullable(row[4])),
                  transactionDate: Value(parseDate(row[5])),
                ));
            break;
          case 'CATEGORIES':
            await database.into(database.categories).insert(CategoriesCompanion(
                  id: Value(parseInt(row[0])),
                  name: Value(parseString(row[1])),
                  color: Value(parseInt(row[2])),
                  iconName: Value(parseString(row[3])),
                ));
            break;
          case 'BUDGETS':
            await database.into(database.budgets).insert(BudgetsCompanion(
                  id: Value(parseInt(row[0])),
                  categoryId: Value(parseInt(row[1])),
                  amount: Value(parseDouble(row[2])),
                  month: Value(parseInt(row[3])),
                  year: Value(parseInt(row[4])),
                ));
            break;
          case 'SAVING_GOALS':
            await database.into(database.savingGoals).insert(SavingGoalsCompanion(
                  id: Value(parseInt(row[0])),
                  name: Value(parseString(row[1])),
                  targetAmount: Value(parseDouble(row[2])),
                  targetDate: Value(parseDateNullable(row[3])), 
                ));
            break;
          case 'SAVING_CONTRIBUTIONS':
            await database
                .into(database.savingContributions)
                .insert(SavingContributionsCompanion(
                  id: Value(parseInt(row[0])),
                  goalId: Value(parseInt(row[1])),
                  amount: Value(parseDouble(row[2])),
                  transactionDate: Value(parseDate(row[3])),
                ));
            break;
        }
      } catch (e) {
        await database.customStatement('PRAGMA foreign_keys = ON;');
        // Error message ini udah bagus, nge-print baris yg error
        throw Exception(
            'Data di file rusak di tabel $currentTable (Baris: $row): ${e.toString()}');
      }
    }

    await database.customStatement('PRAGMA foreign_keys = ON;');
  }
}