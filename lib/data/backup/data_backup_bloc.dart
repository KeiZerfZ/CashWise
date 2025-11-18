import 'dart:io'; // <-- BARU
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/data/backup/data_backup_repository.dart';
// FIX: Import file event & state yang udah dipisah
import 'data_backup_event.dart';
import 'data_backup_state.dart';


class DataBackupBloc extends Bloc<DataBackupEvent, DataBackupState> {
  final DataBackupRepository repository;

  DataBackupBloc(this.repository) : super(DataBackupInitial()) {
    on<ExportDataEvent>(_onExportData);
    on<ImportDataEvent>(_onImportData);
  }

  Future<void> _onExportData(ExportDataEvent event, Emitter<DataBackupState> emit) async {
    emit(DataBackupLoading());
    try {
      await repository.exportData();
      emit(const DataBackupSuccess('Data berhasil diekspor!'));
    } catch (e) {
      emit(DataBackupError('Gagal ekspor data: ${e.toString()}'));
    }
  }

  Future<void> _onImportData(ImportDataEvent event, Emitter<DataBackupState> emit) async {
    emit(DataBackupLoading());
    try {
      // Panggil repository buat ngurusin file-nya
      await repository.importData(event.file);
      
      // Kasih tau user kalo sukses
      emit(const DataBackupSuccess('Data berhasil diimpor! Harap restart aplikasi untuk melihat perubahan.'));
      // (Kita bisa bikin BLoC lain nge-refresh, tapi restart lebih gampang & aman buat V1)
      
    } catch (e) {
      emit(DataBackupError('Gagal impor data: ${e.toString()}'));
    }
  }
}