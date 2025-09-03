// lib/features/transaction/presentation/bloc/transaction_state.dart

import 'package:equatable/equatable.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

// Kondisi awal, saat BLoC baru dibuat
class TransactionInitial extends TransactionState {}

// Kondisi saat sedang mengambil data dari database
class TransactionLoading extends TransactionState {}

// Kondisi saat data berhasil diambil
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}

// Kondisi saat terjadi error
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}