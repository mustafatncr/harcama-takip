import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

class WeeklyChart extends StatelessWidget {
  final List<Expense> expenses;
  const WeeklyChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // 🔹 Son 7 güne göre harcamaları grupluyoruz
    final now = DateTime.now();
    final last7days =
        List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    // 🔹 Günlük toplamları hesapla
    final dailyTotals = List<double>.generate(7, (i) {
      final day = last7days[i];
      final dayExpenses = expenses.where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);

      // ⬇️ başlangıcı 0.0 yap ve generic'i double belirt
      final total = dayExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      return total; // .toDouble() gerek yok artık
    });

    final maxValue = (dailyTotals.reduce((a, b) => a > b ? a : b)) + 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Haftalık Harcama",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index > 6)
                          return const SizedBox.shrink();
                        const days = [
                          "Pzt",
                          "Sal",
                          "Çar",
                          "Per",
                          "Cum",
                          "Cmt",
                          "Paz"
                        ];
                        return Text(days[index],
                            style: const TextStyle(fontSize: 11));
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dailyTotals[i],
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  );
                }),
                maxY: maxValue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
