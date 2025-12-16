import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/habit_provider.dart';
import 'screens/auth_gate.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізуємо Supabase з вашими ключами.
  await Supabase.initialize(
    url: 'https://nrpnnhdlwedfvriiyhcz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ycG5uaGRsd2VkZnZyaWl5aGN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4Mjk4ODQsImV4cCI6MjA4MTQwNTg4NH0.IkBkZM_DJGHCRXsr0X5XseBatxfk_vrp3hXkbungrng',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: const HabitFlowApp(),
    ),
  );
}

class HabitFlowApp extends StatefulWidget {
  const HabitFlowApp({super.key});
  @override
  State<HabitFlowApp> createState() => _HabitFlowAppState();
}

class _HabitFlowAppState extends State<HabitFlowApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        cardColor: AppColors.lightCard,
        colorScheme: const ColorScheme.light(primary: AppColors.lightPrimary),
        appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: AppColors.lightText),
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.lightCard),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        cardColor: AppColors.darkCard,
        colorScheme: const ColorScheme.dark(primary: AppColors.darkPrimary),
        appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: AppColors.darkText),
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.darkCard),
      ),
      themeMode: _themeMode,
      home: AuthGate(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}