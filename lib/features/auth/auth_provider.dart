import 'package:flutter_riverpod/flutter_riverpod.dart';

// حالة المستخدم: guest ولا مسجل
enum AuthStatus { guest, loggedIn }

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => AuthStatus.guest;

  void loginAsGuest() => state = AuthStatus.guest;
  void logIn() => state = AuthStatus.loggedIn;
  void logOut() => state = AuthStatus.guest;
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
