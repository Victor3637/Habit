
class Habit {
  final int id;
  String name;
  Map<DateTime, bool> history;
  String userId; // Додано поле для ID користувача

  Habit({
    required this.id,
    required this.name,
    required this.userId,
    Map<DateTime, bool>? history,
  }) : history = history ?? {};

  // Метод для перетворення об'єкта в Map для Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'history': history.keys.map((date) => date.toIso8601String()).toList(),
      'user_id': userId,
    };
  }

  // Метод для створення об'єкта з Map, отриманого з Supabase.
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      history: {
        for (var dateString in (map['history'] as List))
          DateTime.parse(dateString as String): true,
      },
      userId: map['user_id'],
    );
  }

  int calculateCurrentStreak() {
    if (history.isEmpty) return 0;
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDay = DateTime(today.year, today.month, today.day);
    if (!history.containsKey(checkDay)) {
      checkDay = checkDay.subtract(const Duration(days: 1));
    }
    while (history.containsKey(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }
    return streak;
  }
}