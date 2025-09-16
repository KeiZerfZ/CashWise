import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/injection_container.dart' as di;
import 'package:cashwise/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:cashwise/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:cashwise/features/transaction/presentation/pages/transaction_list_page.dart';
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
        
        // <-- PERUBAHAN DI SINI
        // Memuat semua kategori saat aplikasi dimulai
        BlocProvider(create: (context) => di.locator<CategoryBloc>()..add(FetchAllCategories())),
        
        BlocProvider(create: (context) => di.locator<BudgetBloc>()),
      ],
      child: MaterialApp(
        title: 'CashWise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.grey.shade100,
          dropdownMenuTheme: DropdownMenuThemeData(
            // ... (tema lainnya)
          ),
        ),
        home: const TransactionListPage(),
      ),
    );
  }
}