import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_event.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_state.dart';
// import 'package:cashwise/features/saving_goal/presentation/pages/add_edit_goal_page.dart'; // Gak perlu lagi
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        // Gak perlu tombol back di halaman utama tab
        automaticallyImplyLeading: false, 
        title: const Text('Celengan Digital', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Kamu belum punya celengan.\nKlik tombol + di bawah untuk membuat!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                final goalWithDetails = state.goals[index];
                return SavingGoalListItem(
                  goalWithDetails: goalWithDetails,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<SavingGoalBloc>(),
                          child: GoalDetailPage(goalWithDetails: goalWithDetails),
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
      // =================================================================
      // FLOATING ACTION BUTTON DIHAPUS DARI SINI
      // =================================================================
    );
  }
}