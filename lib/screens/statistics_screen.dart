import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit_model.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Habit> habits;
  const StatisticsScreen({super.key, required this.habits});

  List<double> _calculateWeeklyStats() {
    List<double> completions = List.filled(7, 0.0);
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startOfWeek.add(Duration(days: i));
      for (var habit in habits) {
        if (habit.history[DateTime(currentDay.year, currentDay.month, currentDay.day)] == true) {
          completions[i]++;
        }
      }
    }
    return completions;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _calculateWeeklyStats();
    final double maxCompletions = weeklyData.isEmpty ? 5 : weeklyData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Виконання звичок за тиждень', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCompletions > 0 ? maxCompletions + 2 : 5,
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
                        return SideTitleWidget(axisSide: meta.axisSide, child: Text(days[value.toInt()]));
                    })),
                  ),
                  barGroups: weeklyData.asMap().entries.map((e) {
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(toY: e.value, color: Theme.of(context).colorScheme.primary, width: 20, borderRadius: BorderRadius.circular(4)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}