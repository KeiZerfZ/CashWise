import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashwise/data/local/app_database.dart';

// Import BLoCs
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/data/backup/data_backup_bloc.dart';

// Import Repositories & DataSources
import 'package:cashwise/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:cashwise/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:cashwise/features/category/data/datasources/category_local_data_source.dart';
import 'package:cashwise/features/category/data/repositories/category_repository_impl.dart';
import 'package:cashwise/features/category/domain/repositories/category_repository.dart';
import 'package:cashwise/features/budgeting/data/datasources/budget_local_data_source.dart';
import 'package:cashwise/features/budgeting/data/repositories/budget_repository_impl.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';
import 'package:cashwise/features/saving_goal/data/datasources/saving_goal_local_data_source.dart';
import 'package:cashwise/features/saving_goal/data/repositories/saving_goal_repository_impl.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';
import 'package:cashwise/features/profile/data/repositories/profile_repository.dart';
import 'package:cashwise/data/backup/data_backup_repository.dart';

// Import UseCases
import 'package:cashwise/features/transaction/domain/usecases/get_all_transactions.dart';
import 'package:cashwise/features/transaction/domain/usecases/add_transaction.dart';
import 'package:cashwise/features/transaction/domain/usecases/delete_transaction.dart';
import 'package:cashwise/features/transaction/domain/usecases/update_transaction.dart';
import 'package:cashwise/features/category/domain/usecases/get_all_categories.dart';
import 'package:cashwise/features/category/domain/usecases/add_category.dart';
import 'package:cashwise/features/category/domain/usecases/delete_category.dart';
import 'package:cashwise/features/category/domain/usecases/update_category.dart';
import 'package:cashwise/features/budgeting/domain/usecases/get_budgets_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/usecases/save_budget.dart';
import 'package:cashwise/features/budgeting/domain/usecases/delete_budget.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/add_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/delete_saving_goal.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/get_all_saving_goals.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/get_goal_details.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/save_saving_goal.dart';


final locator = GetIt.instance;

Future<void> init() async {
  // ==========================================================================
  //                            !!! BLOCS !!!
  // ==========================================================================
  locator.registerFactory(() => TransactionBloc(
        getAllTransactions: locator(),
        addTransaction: locator(),
        deleteTransaction: locator(),
        updateTransaction: locator(),
      ));
  locator.registerFactory(() => CategoryBloc(
        getAllCategories: locator(),
        addCategory: locator(),
        deleteCategory: locator(),
        updateCategory: locator(),
      ));
  locator.registerFactory(() => BudgetBloc(
        getBudgetsWithSpending: locator(),
        saveBudget: locator(),
        deleteBudget: locator(),
      ));
  locator.registerFactory(() => SavingGoalBloc(
        getAllSavingGoals: locator(),
        getGoalDetails: locator(),
        saveSavingGoal: locator(),
        deleteSavingGoal: locator(),
        addContribution: locator(),
      ));
  locator.registerLazySingleton(() => ProfileBloc(repository: locator()));
  locator.registerFactory(() => DataBackupBloc(locator()));
  
  // ==========================================================================
  //                           !!! USE CASES !!!
  // ==========================================================================
  // (Transaksi)
  locator.registerLazySingleton(() => GetAllTransactions(locator()));
  locator.registerLazySingleton(() => AddTransaction(locator()));
  locator.registerLazySingleton(() => DeleteTransaction(locator()));
  locator.registerLazySingleton(() => UpdateTransaction(locator()));
  // (Kategori)
  locator.registerLazySingleton(() => GetAllCategories(locator()));
  locator.registerLazySingleton(() => AddCategory(locator()));
  locator.registerLazySingleton(() => DeleteCategory(locator()));
  locator.registerLazySingleton(() => UpdateCategory(locator()));
  // (Budgeting)
  locator.registerLazySingleton(() => GetBudgetsWithSpending(locator()));
  locator.registerLazySingleton(() => SaveBudget(locator()));
  locator.registerLazySingleton(() => DeleteBudget(locator()));
  // (Saving Goal)
  locator.registerLazySingleton(() => GetAllSavingGoals(locator()));
  locator.registerLazySingleton(() => GetGoalDetails(locator()));
  locator.registerLazySingleton(() => SaveSavingGoal(locator()));
  locator.registerLazySingleton(() => DeleteSavingGoal(locator()));
  locator.registerLazySingleton(() => AddContribution(locator()));

  
  // ==========================================================================
  //                           !!! REPOSITORIES !!!
  // ==========================================================================
  locator.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<SavingGoalRepository>(() => SavingGoalRepositoryImpl(localDataSource: locator()));
  locator.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(prefs: locator(), imagePicker: locator()));

  // =================================================================
  // INI DIA PERBAIKANNYA! (Pake 'database: locator()')
  // =================================================================
  locator.registerLazySingleton<DataBackupRepository>(() => DataBackupRepositoryImpl(database: locator()));


  // ==========================================================================
  //                           !!! DATA SOURCES !!!
  // ==========================================================================
  locator.registerLazySingleton<TransactionLocalDataSource>(() => TransactionLocalDataSourceImpl(database: locator()));
  locator.registerLazySingleton<CategoryLocalDataSource>(() => CategoryLocalDataSourceImpl(database: locator()));
  locator.registerLazySingleton<BudgetLocalDataSource>(() => BudgetLocalDataSourceImpl(database: locator()));
  locator.registerLazySingleton<SavingGoalLocalDataSource>(() => SavingGoalLocalDataSourceImpl(database: locator()));


  // ==========================================================================
  //                              !!! EXTERNAL !!!
  // ==========================================================================
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());
  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs);
  locator.registerLazySingleton(() => ImagePicker());
}