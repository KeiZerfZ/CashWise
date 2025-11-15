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
    context.read<SavingGoalBloc>().add(LoadGoalDetails(goalId: widget.goalWithDetails.goal.id));
  }
  
  // =================================================================
  // REFACTOR: Ganti 'AlertDialog' jadi 'showModalBottomSheet'
  // =================================================================
  void _showAddContributionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Biar gak ketutup keyboard (walau kita pake numpad)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        // Kirim BLoC ke Bottom Sheet
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Celengan?'),
          content: Text('Yakin mau menghapus "${widget.goalWithDetails.goal.name}"? Semua riwayat setoran juga akan hilang selamanya.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<SavingGoalBloc>().add(DeleteSavingGoalEvent(goalId: widget.goalWithDetails.goal.id));
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.goalWithDetails.goal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
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

          // FIX: Ambil 'currentGoalDetails' dari state.goals
          // Ini Bikin Progress Bar-nya realtime
          SavingGoalWithDetails currentGoalDetails;
          try {
            currentGoalDetails = state.goals.firstWhere((g) => g.goal.id == widget.goalWithDetails.goal.id);
          } catch (e) {
            currentGoalDetails = widget.goalWithDetails;
          }

          final formatCurrencyFull = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final double progress = currentGoalDetails.progress;
          final Color progressColor = currentGoalDetails.isAchieved ? Colors.green : Theme.of(context).primaryColor;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terkumpul: ${formatCurrencyFull.format(currentGoalDetails.totalContribution)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ${formatCurrencyFull.format(currentGoalDetails.goal.targetAmount)}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(1)}% Tercapai',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: progressColor),
                      ),
                    )
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Riwayat Setoran',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      // FIX: Ambil 'contributions' dari state
                      // Ini Bikin List-nya realtime
                      child: state.contributions.isEmpty
                          ? const Center(child: Text('Belum ada setoran.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.contributions.length,
                              itemBuilder: (context, index) {
                                final contribution = state.contributions.reversed.toList()[index];
                                return ContributionListItem(contribution: contribution);
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


// =================================================================
// BARU: WIDGET UNTUK BOTTOM SHEET NUMPAD SETORAN
// =================================================================
class _ContributionNumpadSheet extends StatefulWidget {
  final int goalId;
  const _ContributionNumpadSheet({required this.goalId});

  @override
  State<_ContributionNumpadSheet> createState() => _ContributionNumpadSheetState();
}

class _ContributionNumpadSheetState extends State<_ContributionNumpadSheet> {
  String _amountString = '0';
  bool _isSaving = false;

  void _onNumpadTapped(String value) {
    if (_isSaving) return;
    setState(() {
      if (value == 'backspace') {
        _amountString = (_amountString.length == 1) ? '0' : _amountString.substring(0, _amountString.length - 1);
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
        const SnackBar(content: Text('Jumlah setoran harus lebih dari 0!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isSaving = true; });

    final contribution = SavingContribution(
      id: 0,
      goalId: widget.goalId,
      amount: amount,
      transactionDate: DateTime.now(),
    );
    
    // Tembak event
    context.read<SavingGoalBloc>().add(AddContributionEvent(contribution: contribution));
    // Tutup sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tambah Setoran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Tampilan Angka Gede
          Text(
            currencyFormatter.format(double.tryParse(_amountString) ?? 0.0),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.green, // Warna hijau
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Setoran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              _numpadButton('1'),_numpadButton('2'),_numpadButton('3'),
              _numpadButton('4'),_numpadButton('5'),_numpadButton('6'),
              _numpadButton('7'),_numpadButton('8'),_numpadButton('9'),
              _numpadButton(''),_numpadButton('0'),_numpadButton('backspace'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numpadButton(String value) {
    if (value == '') return Container();
    return InkWell(
      onTap: () => _onNumpadTapped(value),
      child: Center(
        child: value == 'backspace'
            ? const Icon(Icons.backspace_outlined, color: Colors.grey)
            : Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
      ),
    );
  }
}