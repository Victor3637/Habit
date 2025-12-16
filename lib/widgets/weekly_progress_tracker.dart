import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/app_colors.dart';

class WeeklyProgressTracker extends StatelessWidget {
  final Map<DateTime, bool> history;
  final Function(DateTime) onToggleDay;
  final Color habitColor;
  const WeeklyProgressTracker({super.key, required this.history, required this.onToggleDay, required this.habitColor});

  @override
  Widget build(BuildContext context) {
    final days = ['П', 'В', 'С', 'Ч', 'П', 'С', 'Н'];
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Padding(
      padding: const EdgeInsets.only(top: 6.0), // Зменшено
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final dayOnly = DateTime(date.year, date.month, date.day);
          final isCompleted = history[dayOnly] ?? false;
          final isToday = isSameDay(date, today);

          return GestureDetector(
            onTap: () => onToggleDay(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, // Зменшено
              height: 28, // Зменшено
              margin: const EdgeInsets.symmetric(horizontal: 1.5), // Зменшено
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? habitColor : Colors.transparent,
                border: Border.all(
                  color: isToday ? habitColor : Colors.grey.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  days[index],
                  style: TextStyle(
                    fontSize: 11, // Зменшено
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBg : AppColors.lightBg) : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}