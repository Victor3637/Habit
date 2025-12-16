import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../widgets/max_width_container.dart';
import '../widgets/background_blobs.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const ProfileScreen({super.key, required this.onToggleTheme});
  
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Профіль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const BackgroundBlobs(),
          MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 80), // Відступ для AppBar
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person_outline, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authService.currentUser?.email ?? 'Користувач',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings_outlined),
                          title: const Text('Налаштування'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                          dense: true,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Допомога та підтримка'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                       ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Про застосунок'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'HabitFlow',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.checklist_rtl_rounded),
                            children: [
                              const Text('Розроблено в рамках лабораторної роботи №4.'),
                            ]
                          );
                        },
                        dense: true,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(Icons.bug_report_outlined, color: Theme.of(context).colorScheme.tertiary),
                        title: Text('Згенерувати помилку для Sentry', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                        onTap: () {
                          try {
                            throw StateError('Це тестова помилка для перевірки Sentry!');
                          } catch (exception, stackTrace) {
                            Sentry.captureException(exception, stackTrace: stackTrace);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Тестова помилка відправлена в Sentry!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        dense: true,
                      ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Вийти'),
                      onPressed: () {
                        authService.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginScreen(onToggleTheme: onToggleTheme)),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}