import 'package:equatable/equatable.dart';

abstract class DataBackupState extends Equatable {
  const DataBackupState();
  @override
  List<Object> get props => [];
}

class DataBackupInitial extends DataBackupState {}

class DataBackupLoading extends DataBackupState {}

class DataBackupSuccess extends DataBackupState {
  final String message;
  const DataBackupSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class DataBackupError extends DataBackupState {
  final String message;
  const DataBackupError(this.message);
  @override
  List<Object> get props => [message];
}