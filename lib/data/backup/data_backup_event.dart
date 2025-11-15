import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class DataBackupEvent extends Equatable {
  const DataBackupEvent();
  @override
  List<Object> get props => [];
}

/// Perintah: "Mulai proses ekspor!"
class ExportDataEvent extends DataBackupEvent {}

/// Perintah: "Mulai proses impor dari file ini!"
class ImportDataEvent extends DataBackupEvent {
  final File file;
  const ImportDataEvent({required this.file});
  @override
  List<Object> get props => [file];
}