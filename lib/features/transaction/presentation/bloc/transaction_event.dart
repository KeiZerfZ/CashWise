// lib/features/transaction/presentation/bloc/transaction_event.dart
import 'package:equatable/equatable.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart'; // Impor ini

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class FetchAllTransactions extends TransactionEvent {}

// EVENT BARU: Membawa data transaksi yang akan ditambahkan
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}