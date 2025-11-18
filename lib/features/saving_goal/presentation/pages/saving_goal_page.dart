// lib/features/saving_goal/presentation/pages/saving_goal_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_event.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_state.dart';
import 'package:cashwise/features/saving_goal/presentation/pages/goal_detail_page.dart';
import 'package:cashwise/features/saving_goal/presentation/widgets/saving_goal_list_item.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

class SavingGoalPage extends StatefulWidget {
  const SavingGoalPage({super.key});

  @override
  State<SavingGoalPage> createState() => _SavingGoalPageState();
}

class _SavingGoalPageState extends State<SavingGoalPage> {
  @override
  void initState() {
    super.initState();
    context.read<SavingGoalBloc>().add(LoadAllSavingGoals());
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor' ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Celengan Digital',
            style: TextStyle(fontWeight: FontWeight.bold)),
        // --- REFAKTOR: Hapus styling, biarin AppBarTheme ---
      ),
      body: BlocBuilder<SavingGoalBloc, SavingGoalState>(
        builder: (context, state) {
          if (state is SavingGoalLoading || state is SavingGoalInitial) {
            return const LoadingIndicator();
          }
          if (state is SavingGoalError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is SavingGoalLoaded) {
            if (state.goals.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Kamu belum punya celengan.\nKlik tombol + di bawah untuk membuat!',
                    textAlign: TextAlign.center,
                    // --- REFAKTOR: Ganti style/warna hardcode ---
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                final goalWithDetails = state.goals[index];
                // (Widget ini udah kita refactor)
                return SavingGoalListItem(
                  goalWithDetails: goalWithDetails,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<SavingGoalBloc>(),
                          child:
                              GoalDetailPage(goalWithDetails: goalWithDetails),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}