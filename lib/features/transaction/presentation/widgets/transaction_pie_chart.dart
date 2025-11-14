import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;

  const TransactionPieChart({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Nanti kita bisa nambahin animasi di sini
          },
        ),
      ),
      // =================================================================
      // FIX: BAGIAN 'options' DI HAPUS SEMUA
      // =================================================================
    );
  }
}