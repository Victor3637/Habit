import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import 'weekly_progress_tracker.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(DateTime) onToggleDay;

  const HabitCard({super.key, required this.habit, required this.onTap, required this.onEdit, required this.onDelete, required this.onToggleDay});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withAlpha(50)),
        borderRadius: BorderRadius.circular(12)
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            visualDensity: VisualDensity.compact,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: color.withAlpha(30),
              child: Icon(Icons.check_circle_outline, color: color, size: 22),
            ),
            title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: WeeklyProgressTracker(history: habit.history, onToggleDay: onToggleDay, habitColor: color),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔥 ${habit.calculateCurrentStreak()}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20), tooltip: 'Редагувати', onPressed: onEdit),
                IconButton(icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error), tooltip: 'Видалити', onPressed: onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}