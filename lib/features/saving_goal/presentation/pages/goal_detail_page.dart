// lib/features/saving_goal/presentation/pages/goal_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal_with_details.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_bloc.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_event.dart';
import 'package:cashwise/features/saving_goal/presentation/bloc/saving_goal_state.dart';
import 'package:cashwise/features/saving_goal/presentation/widgets/contribution_list_item.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

class GoalDetailPage extends StatefulWidget {
  final SavingGoalWithDetails goalWithDetails;
  const GoalDetailPage({super.key, required this.goalWithDetails});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<SavingGoalBloc>()
        .add(LoadGoalDetails(goalId: widget.goalWithDetails.goal.id));
  }

  void _showAddContributionSheet(BuildContext context) {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // --- REFAKTOR: Styling modal ---
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<SavingGoalBloc>(),
          child: _ContributionNumpadSheet(
            goalId: widget.goalWithDetails.goal.id,
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          // --- REFAKTOR: Styling dialog ---
          backgroundColor: theme.colorScheme.surface,
          title: Text('Hapus Celengan?', style: theme.textTheme.titleLarge),
          content: Text(
              'Yakin mau menghapus "${widget.goalWithDetails.goal.name}"? Semua riwayat setoran juga akan hilang selamanya.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              // (Warna SEMANTIK, biarin)
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<SavingGoalBloc>().add(
                    DeleteSavingGoalEvent(goalId: widget.goalWithDetails.goal.id));
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor' ---
      appBar: AppBar(
        title: Text(widget.goalWithDetails.goal.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        // --- REFAKTOR: Hapus styling, biarin AppBarTheme ---
        actions: [
          IconButton(
            // --- REFAKTOR: Bikin warna semantik theme-aware ---
            icon: Icon(Icons.delete_outline,
                color: isLightMode ? Colors.red : Colors.red.shade300),
            tooltip: 'Hapus Celengan',
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<SavingGoalBloc, SavingGoalState>(
        builder: (context, state) {
          if (state is! SavingGoalLoaded) {
            return const LoadingIndicator();
          }

          SavingGoalWithDetails currentGoalDetails;
          try {
            currentGoalDetails = state.goals
                .firstWhere((g) => g.goal.id == widget.goalWithDetails.goal.id);
          } catch (e) {
            currentGoalDetails = widget.goalWithDetails;
          }

          final formatCurrencyFull = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
              
          // --- REFAKTOR: Bikin warna semantik theme-aware ---
          final double progress = currentGoalDetails.progress;
          final Color progressColor = currentGoalDetails.isAchieved
              ? (isLightMode ? Colors.green.shade600 : Colors.green.shade300)
              : theme.primaryColor;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  // --- REFAKTOR: Ganti warna hardcode ---
                  color: theme.cardColor,
                  border: Border(
                      bottom: BorderSide(
                          color: theme.dividerColor.withOpacity(0.5))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terkumpul: ${formatCurrencyFull.format(currentGoalDetails.totalContribution)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor, // (SEMANTIK, udah bener)
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ${formatCurrencyFull.format(currentGoalDetails.goal.targetAmount)}',
                      // --- REFAKTOR: Ganti style/warna hardcode ---
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        // --- REFAKTOR: Ganti warna hardcode ---
                        backgroundColor: theme.dividerColor.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(1)}% Tercapai',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: progressColor, // (SEMANTIK, udah bener)
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Riwayat Setoran',
                        // --- REFAKTOR: Ganti style hardcode ---
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: state.contributions.isEmpty
                          ? const Center(child: Text('Belum ada setoran.'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.contributions.length,
                              itemBuilder: (context, index) {
                                final contribution =
                                    state.contributions.reversed.toList()[index];
                                // (Widget ini udah kita refactor)
                                return ContributionListItem(
                                    contribution: contribution);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContributionSheet(context),
        // (Warna SEMANTIK, biarin)
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- WIDGET UNTUK BOTTOM SHEET NUMPAD SETORAN ---
class _ContributionNumpadSheet extends StatefulWidget {
  final int goalId;
  const _ContributionNumpadSheet({required this.goalId});

  @override
  State<_ContributionNumpadSheet> createState() =>
      _ContributionNumpadSheetState();
}

class _ContributionNumpadSheetState extends State<_ContributionNumpadSheet> {
  String _amountString = '0';
  bool _isSaving = false;

  void _onNumpadTapped(String value) {
    if (_isSaving) return;
    setState(() {
      if (value == 'backspace') {
        _amountString = (_amountString.length == 1)
            ? '0'
            : _amountString.substring(0, _amountString.length - 1);
      } else if (_amountString == '0') {
        _amountString = value;
      } else if (_amountString.length < 12) {
        _amountString += value;
      }
    });
  }

  void _onSave() {
    if (_isSaving) return;
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Jumlah setoran harus lebih dari 0!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final contribution = SavingContribution(
      id: 0,
      goalId: widget.goalId,
      amount: amount,
      transactionDate: DateTime.now(),
    );

    context
        .read<SavingGoalBloc>()
        .add(AddContributionEvent(contribution: contribution));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // --- REFAKTOR: Bikin warna semantik theme-aware ---
    final Color contributionColor = isLightMode ? Colors.green.shade600 : Colors.green.shade300;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- REFAKTOR: Ganti style hardcode ---
          Text('Tambah Setoran', style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          Text(
            currencyFormatter.format(double.tryParse(_amountString) ?? 0.0),
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: contributionColor, // (SEMANTIK, udah bener)
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _onSave,
              // (Warna SEMANTIK, biarin)
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Setoran',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          // Numpad Kustom
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.0,
            children: [
              _numpadButton('1'), _numpadButton('2'), _numpadButton('3'),
              _numpadButton('4'), _numpadButton('5'), _numpadButton('6'),
              _numpadButton('7'), _numpadButton('8'), _numpadButton('9'),
              _numpadButton(''), _numpadButton('0'), _numpadButton('backspace'),
            ],
          ),
        ],
      ),
    );
  }

  // --- REFAKTOR: Bikin numpad button-nya theme-aware ---
  Widget _numpadButton(String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (value == '') return Container();
    return InkWell(
      onTap: () => _onNumpadTapped(value),
      child: Center(
        child: value == 'backspace'
            ? Icon(Icons.backspace_outlined, color: colorScheme.onSurfaceVariant)
            : Text(
                value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}