import 'package:get_it/get_it.dart';
import 'package:cashwise/data/local/app_database.dart';

// Transaksi
import 'package:cashwise/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:cashwise/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:cashwise/features/transaction/domain/usecases/get_all_transactions.dart';
import 'package:cashwise/features/transaction/domain/usecases/add_transaction.dart';
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';

// Kategori
import 'package:cashwise/features/category/data/datasources/category_local_data_source.dart';
import 'package:cashwise/features/category/data/repositories/category_repository_impl.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';
import 'package:cashwise/features/category/domain/usecases/get_all_categories.dart';
import 'package:cashwise/features/category/domain/usecases/add_category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';

// Import untuk Fitur Budgeting (Versi Modul 2)
import 'package:cashwise/features/budgeting/data/datasources/budget_local_data_source.dart';
import 'package:cashwise/features/budgeting/data/repositories/budget_repository_impl.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';
import 'package:cashwise/features/budgeting/domain/usecases/get_budgets_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/usecases/save_budget.dart';
import 'package:cashwise/features/budgeting/domain/usecases/delete_budget.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';


final locator = GetIt.instance;

Future<void> init() async {
  // ==========================================================================
  //                            !!! FITUR-FITUR !!!
  // ==========================================================================
  
  // --- Fitur Transaksi ---
  locator.registerFactory(() => TransactionBloc(getAllTransactions: locator(), addTransaction: locator()));
  locator.registerLazySingleton(() => GetAllTransactions(locator()));
  locator.registerLazySingleton(() => AddTransaction(locator()));
  locator.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<TransactionLocalDataSource>(() => TransactionLocalDataSourceImpl(database: locator()));

  // --- Fitur Kategori ---
  locator.registerFactory(() => CategoryBloc(getAllCategories: locator(), addCategory: locator()));
  locator.registerLazySingleton(() => GetAllCategories(locator()));
  locator.registerLazySingleton(() => AddCategory(locator()));
  locator.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<CategoryLocalDataSource>(() => CategoryLocalDataSourceImpl(database: locator()));

  // --- Fitur Budgeting (Versi Modul 2) ---
  locator.registerFactory(() => BudgetBloc(
        getBudgetsWithSpending: locator(),
        saveBudget: locator(),
        deleteBudget: locator(),
      ));
  locator.registerLazySingleton(() => GetBudgetsWithSpending(locator()));
  locator.registerLazySingleton(() => SaveBudget(locator()));
  locator.registerLazySingleton(() => DeleteBudget(locator()));
  locator.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<BudgetLocalDataSource>(() => BudgetLocalDataSourceImpl(database: locator()));


  // ==========================================================================
  //                              !!! EXTERNAL !!!
  // ==========================================================================
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());
}