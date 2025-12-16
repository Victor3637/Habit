import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Додаємо імпорт для Google

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Екземпляр Google Sign In

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
  User? get currentUser => _auth.currentUser;

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Невідома помилка входу';
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.signUp(email: email, password: password);
      return 'Будь ласка, підтвердьте вашу пошту, перейшовши за посиланням у листі.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Невідома помилка реєстрації';
    }
  }

  // --- ДОДАНИЙ МЕТОД ДЛЯ GOOGLE ---
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Вхід через Google (нативний)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Вхід скасовано користувачем';
      }
      
      // 2. Отримання токенів
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        return 'Не вдалося отримати токен доступу Google';
      }
      if (idToken == null) {
        return 'Не вдалося отримати ID токен Google';
      }

      // 3. Вхід у Supabase за допомогою токенів Google
      await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return null; // Успіх
    } catch (e) {
      return 'Помилка входу через Google: $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Виходимо також з Google
    await _auth.signOut();
  }
}