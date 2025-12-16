import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';

class HabitRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw 'Користувач не автентифікований';
    }
    return user.id;
  }

  Future<List<Habit>> getHabits() async {
    try {
      final data = await _client
          .from('habits')
          .select()
          .eq('user_id', _userId);
      return (data as List).map((map) => Habit.fromMap(map)).toList();
    } catch (e) {
      // Обробка помилок
      print('Помилка при завантаженні звичок: $e');
      return [];
    }
  }

  Future<void> addHabit(Habit habit) async {
    await _client.from('habits').insert(habit.toMap());
  }

  Future<void> updateHabit(Habit habit) async {
    await _client
        .from('habits')
        .update(habit.toMap())
        .eq('id', habit.id);
  }

  Future<void> deleteHabit(int id) async {
    await _client
        .from('habits')
        .delete()
        .eq('id', id);
  }
}