import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/transaction/domain/entities/transaction.dart'; // Pastikan import Transaction
import 'package:cashwise/features/transaction/domain/usecases/add_transaction.dart';
import 'package:cashwise/features/transaction/domain/usecases/get_all_transactions.dart';

// BARU: Impor use case delete dan update
import 'package:cashwise/features/transaction/domain/usecases/delete_transaction.dart';
import 'package:cashwise/features/transaction/domain/usecases/update_transaction.dart';

import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactions getAllTransactions;
  final AddTransaction addTransaction;
  
  // BARU: Tambahkan use case delete dan update
  final DeleteTransaction deleteTransaction;
  final UpdateTransaction updateTransaction;

  TransactionBloc({
    required this.getAllTransactions,
    required this.addTransaction,

    // BARU: Jadikan required di constructor
    required this.deleteTransaction,
    required this.updateTransaction,
  }) : super(TransactionInitial()) {
    on<FetchAllTransactions>(_onFetchAllTransactions);
    on<AddTransactionEvent>(_onAddTransaction);

    // BARU: Daftarkan event handler baru
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
  }

  void _onFetchAllTransactions(
    FetchAllTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getAllTransactions(NoParams());
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  void _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(FetchAllTransactions()), // Panggil Fetch lagi untuk refresh data
    );
  }

  // BARU: Handler untuk event DeleteTransactionEvent
  void _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    // Gunakan use case DeleteTransaction
    final result = await deleteTransaction(Params(id: event.transactionId));
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(FetchAllTransactions()), // Panggil Fetch lagi untuk refresh data
    );
  }

  // BARU: Handler untuk event UpdateTransactionEvent
  void _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    // Gunakan use case UpdateTransaction
    final result = await updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(FetchAllTransactions()), // Panggil Fetch lagi untuk refresh data
    );
  }
}
