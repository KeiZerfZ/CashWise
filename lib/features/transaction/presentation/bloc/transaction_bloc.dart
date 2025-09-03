// lib/features/transaction/presentation/bloc/transaction_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/transaction/domain/usecases/add_transaction.dart'; 
import 'package:cashwise/features/transaction/domain/usecases/get_all_transactions.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactions getAllTransactions;
  final AddTransaction addTransaction; 

  TransactionBloc({
    required this.getAllTransactions,
    required this.addTransaction, 
  }) : super(TransactionInitial()) {
    on<FetchAllTransactions>(_onFetchAllTransactions);
    on<AddTransactionEvent>(_onAddTransaction); 
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
      (_) => add(FetchAllTransactions()), 
    );
  }
}