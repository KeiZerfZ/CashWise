import 'package:equatable/equatable.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

// Event untuk mengambil semua data
class FetchAllTransactions extends TransactionEvent {}

// Event untuk menambah transaksi baru
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

// EVENT BARU: Untuk menghapus transaksi
// Cukup bawa ID-nya saja, karena itu yang dibutuhkan untuk query DELETE
class DeleteTransactionEvent extends TransactionEvent {
  final int transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

// EVENT BARU: Untuk mengupdate transaksi
// Bawa keseluruhan objek Transaction yang sudah diubah datanya
class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}
