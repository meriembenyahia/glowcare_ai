import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';

// حالة المستخدم: guest ولا مسجل
enum AuthStatus { guest, loggedIn }

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    if (SupabaseService.currentUser != null) {
      return AuthStatus.loggedIn;
    }
    return AuthStatus.guest;
  }

  void loginAsGuest() => state = AuthStatus.guest;

  Future<String?> signInWithEmail(String email, String password) async {
    if (!SupabaseService.isInitialized) {
      state = AuthStatus.loggedIn;
      return null;
    }
    try {
      final res = await SupabaseService.signIn(email: email, password: password);
      if (res?.user != null) {
        state = AuthStatus.loggedIn;
        return null;
      }
      return 'فشل تسجيل الدخول. تأكد من البريد وكلمة السر.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUpWithEmail(String email, String password) async {
    if (!SupabaseService.isInitialized) {
      state = AuthStatus.loggedIn;
      return null;
    }
    try {
      final res = await SupabaseService.signUp(email: email, password: password);
      if (res?.user != null) {
        state = AuthStatus.loggedIn;
        return null;
      }
      return 'فشل إنشاء الحساب.';
    } catch (e) {
      return e.toString();
    }
  }

  void logIn() => state = AuthStatus.loggedIn;

  Future<void> logOut() async {
    await SupabaseService.signOut();
    state = AuthStatus.guest;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
