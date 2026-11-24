import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRole {
  customer,  // زبون / متسوق
  seller,    // بائع / صاحب المتجر
  developer, // مطور / المشرف التقني
}

extension AppRoleExtension on AppRole {
  String get title {
    switch (this) {
      case AppRole.customer:
        return 'Customer View';
      case AppRole.seller:
        return 'Seller Dashboard';
      case AppRole.developer:
        return 'Developer Console';
    }
  }

  String get arabicTitle {
    switch (this) {
      case AppRole.customer:
        return 'واجهة الزبون';
      case AppRole.seller:
        return 'واجهة البائع';
      case AppRole.developer:
        return 'واجهة المطور';
    }
  }

  String get description {
    switch (this) {
      case AppRole.customer:
        return 'Browse items, smart AI skin analysis, cart & checkout';
      case AppRole.seller:
        return 'Manage products, inventory, revenue, and incoming orders';
      case AppRole.developer:
        return 'Cloud API health, database tables, seed data & system logs';
    }
  }
}

class RoleNotifier extends Notifier<AppRole> {
  static const _key = 'active_app_role';

  @override
  AppRole build() {
    _loadRole();
    return AppRole.customer;
  }

  Future<void> _loadRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_key);
      if (index != null && index >= 0 && index < AppRole.values.length) {
        state = AppRole.values[index];
      }
    } catch (_) {}
  }

  Future<void> setRole(AppRole role) async {
    state = role;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, role.index);
    } catch (_) {}
  }
}

final roleProvider = NotifierProvider<RoleNotifier, AppRole>(RoleNotifier.new);
