import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/supabase_service.dart';

enum AuthStatus { guest, loggedIn }

class AuthNotifier extends Notifier<AuthStatus> {
  static const String _keyIsLoggedIn = 'is_user_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyAccounts = 'local_accounts';

  String _userEmail = '';
  String _userName = '';

  String get userEmail => _userEmail.isNotEmpty
      ? _userEmail
      : (SupabaseService.currentUser?.email ?? '');

  String get userName {
    if (_userName.isNotEmpty) return _userName;
    final meta = SupabaseService.currentUser?.userMetadata?['full_name'];
    if (meta != null && meta.toString().trim().isNotEmpty) {
      return meta.toString();
    }
    return 'GlowCare Member';
  }

  @override
  AuthStatus build() {
    _initSession();
    if (SupabaseService.currentUser != null) {
      return AuthStatus.loggedIn;
    }
    return AuthStatus.guest;
  }

  Future<void> _initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userEmail = prefs.getString(_keyUserEmail) ?? '';
      _userName = prefs.getString(_keyUserName) ?? '';

      if (isLoggedIn || SupabaseService.currentUser != null) {
        state = AuthStatus.loggedIn;
      }
    } catch (_) {}
  }

  Future<void> _saveSession(
    bool loggedIn, {
    String email = '',
    String name = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, loggedIn);
      if (email.isNotEmpty) {
        await prefs.setString(_keyUserEmail, email);
        _userEmail = email;
      }
      if (name.isNotEmpty) {
        await prefs.setString(_keyUserName, name);
        _userName = name;
      }
      if (!loggedIn) {
        await prefs.remove(_keyUserName);
        _userName = '';
      }
    } catch (_) {}
  }

  Future<Map<String, Map<String, String>>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAccounts);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    final accounts = <String, Map<String, String>>{};
    decoded.forEach((key, value) {
      if (value is Map) {
        accounts[key.toString()] = {
          'password': (value['password'] ?? '').toString(),
          'name': (value['name'] ?? '').toString(),
        };
      }
    });
    return accounts;
  }

  Future<void> _saveAccounts(Map<String, Map<String, String>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccounts, jsonEncode(accounts));
  }

  void loginAsGuest() {
    _saveSession(false);
    state = AuthStatus.guest;
  }

  Future<String?> signInWithEmail(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!SupabaseService.isInitialized) {
      final accounts = await _loadAccounts();
      final account = accounts[normalized];
      if (account == null || account['password'] != password) {
        return 'Incorrect email or password.';
      }
      await _saveSession(
        true,
        email: normalized,
        name: account['name'] ?? '',
      );
      state = AuthStatus.loggedIn;
      return null;
    }
    try {
      final res = await SupabaseService.signIn(
        email: normalized,
        password: password,
      );
      if (res?.user != null) {
        final meta = res?.user?.userMetadata?['full_name'];
        await _saveSession(
          true,
          email: res?.user?.email ?? normalized,
          name: meta?.toString() ?? '',
        );
        state = AuthStatus.loggedIn;
        return null;
      }
      return 'Sign in failed. Check your email and password.';
    } catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<String?> signUpWithEmail(
    String email,
    String password, {
    String name = '',
  }) async {
    final normalized = email.trim().toLowerCase();
    final displayName = name.trim();
    if (!SupabaseService.isInitialized) {
      final accounts = await _loadAccounts();
      if (accounts.containsKey(normalized)) {
        return 'This email is already registered. Try logging in.';
      }
      accounts[normalized] = {
        'password': password,
        'name': displayName,
      };
      await _saveAccounts(accounts);
      await _saveSession(true, email: normalized, name: displayName);
      state = AuthStatus.loggedIn;
      return null;
    }
    try {
      final res = await SupabaseService.signUp(
        email: normalized,
        password: password,
        name: displayName,
      );
      if (res?.user != null) {
        await _saveSession(
          true,
          email: res?.user?.email ?? normalized,
          name: displayName,
        );
        state = AuthStatus.loggedIn;
        return null;
      }
      return 'Account creation failed.';
    } catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    final normalized = email.trim().toLowerCase();
    if (!SupabaseService.isInitialized) {
      return 'Password reset is available when the account server is connected.';
    }
    try {
      await SupabaseService.resetPassword(normalized);
      return null;
    } catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<void> logOut() async {
    await SupabaseService.signOut();
    await _saveSession(false);
    _userEmail = '';
    state = AuthStatus.guest;
  }

  String _friendlyAuthError(Object error) {
    final raw = error.toString();
    if (raw.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('already registered') ||
        raw.contains('already been registered')) {
      return 'This email is already registered. Try logging in.';
    }
    if (raw.contains('Password should be') || raw.contains('weak_password')) {
      return 'Password must be at least 6 characters.';
    }
    final lower = raw.toLowerCase();
    if (lower.contains('unable to validate email') ||
        (lower.contains('invalid') && lower.contains('email'))) {
      return 'Enter a valid email address.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
