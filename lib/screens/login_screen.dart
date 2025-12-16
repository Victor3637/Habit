import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false; // Новий прапорець для кнопки Google

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final error = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  
  // --- НОВА ФУНКЦІЯ ДЛЯ ВХОДУ ЧЕРЕЗ GOOGLE ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    final error = await _authService.signInWithGoogle();
    if (mounted) {
      setState(() => _isGoogleLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.checklist_rtl_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 20),
                  Text('Вхід у HabitFlow', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) return 'Введіть коректний email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) return 'Пароль має бути не менше 6 символів';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: _signIn,
                          child: const Text('Увійти'),
                        ),
                  const SizedBox(height: 12),
                  
                  // --- РОЗДІЛЮВАЧ ТА НОВА КНОПКА ---
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('АБО'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isGoogleLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton.icon(
                      icon: Image.asset('lib/assets/google_logo.png', height: 20), // Вам потрібно додати лого Google
                      label: const Text('Увійти через Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _signInWithGoogle,
                    ),

                  const SizedBox(height: 12),
                  TextButton(
                    child: const Text('Немає акаунту? Зареєструватися'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(onToggleTheme: widget.onToggleTheme))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}