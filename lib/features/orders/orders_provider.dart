import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/supabase_service.dart';
import 'order_model.dart';

class OrdersNotifier extends Notifier<List<Order>> {
  static const _key = 'orders_json';

  @override
  List<Order> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final local = await _readLocal();
    final remote = await SupabaseService.getOrders();
    if (remote != null && remote.isNotEmpty) {
      final ids = remote.map((order) => order.id).toSet();
      final merged = [
        ...remote,
        ...local.where((order) => !ids.contains(order.id)),
      ];
      state = merged;
      await _writeLocal(merged);
      return;
    }
    state = local;
  }

  Future<List<Order>> _readLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return [
        for (final item in decoded)
          if (item is Map)
            Order.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeLocal(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final order in orders) order.toJson()]),
    );
  }

  Future<void> add(Order order) async {
    state = [order, ...state];
    await _writeLocal(state);
    await SupabaseService.saveOrder(order);
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: newStatus)
        else
          order,
    ];
    await _writeLocal(state);
  }

  Future<void> deleteOrder(String orderId) async {
    state = state.where((o) => o.id != orderId).toList();
    await _writeLocal(state);
  }
}

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);
