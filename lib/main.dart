import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/injection_container.dart' as di;
// Import BLoC
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
// BARU: Import BLoC Profil
import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_event.dart';

import 'package:cashwise/presentation/pages/main_page.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.locator<TransactionBloc>()),
        BlocProvider(create: (context) => di.locator<CategoryBloc>()..add(FetchAllCategories())),
        BlocProvider(create: (context) => di.locator<BudgetBloc>()),
        BlocProvider(create: (context) => di.locator<SavingGoalBloc>()),
        
        // =================================================================
        // BARU: Nyalain "Otak" Profil & langsung suruh dia muat data
        // =================================================================
        BlocProvider(create: (context) => di.locator<ProfileBloc>()..add(LoadProfile())),
      ],
      child: MaterialApp(
        title: 'CashWise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey.shade100,
          fontFamily: 'Poppins'
        ),
        home: const MainPage(), 
      ),
    );
  }
}