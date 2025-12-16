import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../services/habit_repository.dart';
import '../services/auth_service.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final AuthService _authService = AuthService();
  List<Habit> _habits = [];
  bool isLoading = false;

  List<Habit> get habits => _habits;

  HabitProvider() {
    // Слухаємо зміни стану авторизації, щоб перезавантажувати дані
    _authService.authStateChanges.listen((event) {
      if (event.session != null) {
        fetchHabits();
      } else {
        _habits = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchHabits() async {
    isLoading = true;
    notifyListeners();
    _habits = await _repository.getHabits();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(String name) async {
    if (name.isEmpty) return;
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      userId: _authService.currentUser!.id,
    );
    _habits.add(newHabit);
    notifyListeners();
    await _repository.addHabit(newHabit);
  }

  Future<void> editHabit(int id, String newName) async {
    if (newName.isEmpty) return;
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.name = newName;
    notifyListeners();
    await _repository.updateHabit(habit);
  }

  Future<void> deleteHabit(int id) async {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
    await _repository.deleteHabit(id);
  }

  Future<void> toggleHabitCompletion(Habit habit, DateTime date) async {
    final dayToToggle = DateTime(date.year, date.month, date.day);
    if (habit.history.containsKey(dayToToggle)) {
      habit.history.remove(dayToToggle);
    } else {
      habit.history[dayToToggle] = true;
    }
    notifyListeners();
    await _repository.updateHabit(habit);
  }
}