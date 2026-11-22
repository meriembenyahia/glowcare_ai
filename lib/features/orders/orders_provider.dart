import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import 'order_model.dart';

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    // محاولة تحميل الطلبات من Supabase عند البداية
    loadOrders();
    return [];
  }

  Future<void> loadOrders() async {
    final remoteOrders = await SupabaseService.getOrders();
    if (remoteOrders != null) {
      state = remoteOrders;
    }
  }

  Future<void> add(Order order) async {
    state = [order, ...state];
    await SupabaseService.saveOrder(order);
  }
}

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);
