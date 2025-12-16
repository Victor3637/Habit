import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit_model.dart';
import '../widgets/max_width_container.dart'; // <--- ДОДАНО ІМПОРТ

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const HabitDetailScreen({super.key, required this.habit, required this.onDelete, required this.onEdit});
  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Редагувати', onPressed: (){
            Navigator.pop(context);
            widget.onEdit();
          }),
          IconButton(icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), tooltip: 'Видалити', onPressed: (){
            Navigator.pop(context);
            widget.onDelete();
          }),
        ],
      ),
      body: MaxWidthContainer( // <--- ДОДАНО ОБГОРТКУ
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0), // Зменшено відступи
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text(widget.habit.calculateCurrentStreak().toString(), style: Theme.of(context).textTheme.headlineMedium), const Text('Поточний стрик')]),
                        Column(children: [Text(widget.habit.history.length.toString(), style: Theme.of(context).textTheme.headlineMedium), const Text('Всього виконано')]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Зменшено відступ
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: color.withAlpha(128), shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    eventLoader: (day) {
                      final date = DateTime(day.year, day.month, day.day);
                      return widget.habit.history.containsKey(date) ? [widget.habit] : [];
                    },
                    selectedDayPredicate: (day) => isSameDay(_focusedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        final dayToToggle = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                        if (widget.habit.history.containsKey(dayToToggle)) {
                          widget.habit.history.remove(dayToToggle);
                        } else {
                          widget.habit.history[dayToToggle] = true;
                        }
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}