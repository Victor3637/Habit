import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../models/habit_model.dart';
import '../providers/habit_provider.dart'; 
import '../widgets/habit_card.dart';
import '../widgets/max_width_container.dart';
import 'habit_detail_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  final List<String> _quotes = [
    "Дисципліна — це міст між цілями та досягненнями.",
    "Маленькі кроки щодня приводять до великих результатів.",
    "Секрет вашого майбутнього прихований у вашій щоденній рутині.",
  ];
  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Доброго ранку';
    if (hour < 17) return 'Доброго дня';
    return 'Доброго вечора';
  }

  // --- УСЯ ЛОГІКА РОБОТИ ЗІ ЗВИЧКАМИ ТЕПЕР В ПРОВАЙДЕРІ ---
  // Ми видалили методи _addHabit, _editHabit, _deleteHabit, _toggleHabitCompletion

  void _showAddOrEditHabitDialog({Habit? habit}) {
    // Отримуємо доступ до провайдера БЕЗ прослуховування змін
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final isEditing = habit != null;
    final controller = TextEditingController(text: isEditing ? habit.name : '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Редагувати звичку' : 'Нова звичка'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Назва звички"), autofocus: true),
        actions: [
          TextButton(child: const Text('Скасувати'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text(isEditing ? 'Зберегти' : 'Додати'),
            onPressed: () {
              final newName = controller.text.trim();
              if (isEditing) {
                habitProvider.editHabit(habit.id, newName); // Викликаємо метод провайдера
              } else {
                habitProvider.addHabit(newName); // Викликаємо метод провайдера
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Habit habit) async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Підтвердити видалення'),
        content: Text('Ви впевнені, що хочете видалити звичку "${habit.name}"?'),
        actions: <Widget>[
          TextButton(child: const Text('Скасувати'), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(child: Text('Видалити', style: TextStyle(color: Theme.of(context).colorScheme.error)), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (confirmed == true) {
      habitProvider.deleteHabit(habit.id); // Викликаємо метод провайдера
    }
  }

  void _navigateToHabitDetails(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habit: habit,
          onDelete: () => _showDeleteConfirmationDialog(habit),
          onEdit: () => _showAddOrEditHabitDialog(habit: habit),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Використовуємо Consumer, щоб отримати доступ до даних і перебудувати UI при змінах
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        
        final habits = habitProvider.habits;

        double calculateTodayProgress() {
          if (habits.isEmpty) return 0.0;
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          final completedToday = habits.where((h) => h.history.containsKey(todayDate)).length;
          return completedToday / habits.length;
        }

        return Scaffold(
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text('${_getGreeting()}, Вікторе!'),
                    floating: true,
                    actions: [
                      IconButton(tooltip: 'Статистика', icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsScreen(habits: habits)))),
                      IconButton(tooltip: 'Профіль', icon: const Icon(Icons.person_outline), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(onToggleTheme: widget.onToggleTheme)))),
                      IconButton(tooltip: 'Змінити тему', icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined), onPressed: widget.onToggleTheme),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: MaxWidthContainer(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(50)),
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentQuote,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(180)),
                                ),
                                const SizedBox(height: 10),
                                Text('Сьогоднішній прогрес', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: calculateTodayProgress(),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  habits.isEmpty
                    ? const SliverFillRemaining(child: Center(child: Text('Додайте свою першу звичку!', style: TextStyle(fontSize: 18, color: Colors.grey))))
                    : SliverToBoxAdapter(
                        child: MaxWidthContainer(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: habits.length,
                            itemBuilder: (context, index) {
                              final habit = habits[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: HabitCard(
                                  habit: habit,
                                  onTap: () => _navigateToHabitDetails(habit),
                                  onEdit: () => _showAddOrEditHabitDialog(habit: habit),
                                  onDelete: () => _showDeleteConfirmationDialog(habit),
                                  onToggleDay: (date) {
                                    // Викликаємо метод провайдера для зміни стану
                                    habitProvider.toggleHabitCompletion(habit, date);
                                    if (calculateTodayProgress() == 1.0) {
                                      _confettiController.play();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                ],
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddOrEditHabitDialog(),
            tooltip: 'Додати звичку',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}