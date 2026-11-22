import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/shop/product.dart';
import '../../features/orders/order_model.dart';

class SupabaseService {
  // 🔑 غير هاد قيم بـ URL و Anon Key تاع مشروعك فـ Supabase Dashboard
  static const String supabaseUrl = 'https://ppphfquwtjyacbeewjyc.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_u2Jm05Gm3t0Tx04GPOfdSA_h3RSumi-';

  static Future<void> initialize() async {
    // نتفادو الكراش يلا مزال مابدلوش المفاتيح
    if (supabaseUrl == 'YOUR_SUPABASE_URL') {
      return;
    }
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static bool get isInitialized => supabaseUrl != 'YOUR_SUPABASE_URL';

  // ================= 🔐 AUTHENTICATION =================
  static User? get currentUser => isInitialized ? client.auth.currentUser : null;

  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) return null;
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) return null;
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    if (!isInitialized) return;
    await client.auth.signOut();
  }

  // ================= 🛍️ PRODUCTS =================
  static Future<List<Product>?> getProducts() async {
    if (!isInitialized) return null;
    try {
      final response = await client.from('products').select();
      final data = response as List<dynamic>;
      if (data.isEmpty) return null;

      return data.map((json) {
        final Map<String, dynamic> j = Map<String, dynamic>.from(json as Map);
        final rawIng = j['ingredients'];
        final List<String> ingredients = [];
        if (rawIng is List) {
          for (final item in rawIng) {
            if (item != null) ingredients.add(item.toString());
          }
        }
        return Product(
          id: (j['id'] ?? '').toString(),
          name: (j['name'] ?? '').toString(),
          brand: (j['brand'] ?? 'GlowCare').toString(),
          price: (j['price'] as num?)?.toDouble() ?? 0.0,
          rating: (j['rating'] as num?)?.toDouble() ?? 4.5,
          category: (j['category'] ?? 'Skincare').toString(),
          image: (j['image'] ?? '').toString(),
          description: (j['description'] ?? '').toString(),
          ingredients: ingredients,
        );
      }).toList();
    } catch (e) {
      print('Supabase getProducts error: $e');
      return null;
    }
  }

  // ================= 🛒 ORDERS =================
  static Future<bool> saveOrder(Order order) async {
    if (!isInitialized) return false;
    try {
      final userId = currentUser?.id;
      await client.from('orders').insert({
        'id': order.id,
        'user_id': userId,
        'first_name': order.firstName,
        'last_name': order.lastName,
        'phone': order.phone,
        'wilaya': order.wilaya,
        'address': order.address,
        'subtotal': order.subtotal,
        'delivery': order.delivery,
        'total': order.total,
        'items': order.toJson()['items'],
        'created_at': order.date.toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Supabase saveOrder error: $e');
      return false;
    }
  }

  static Future<List<Order>?> getOrders() async {
    if (!isInitialized) return null;
    try {
      final userId = currentUser?.id;
      if (userId == null) return [];
      final response = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final data = response as List<dynamic>;

      return data.map((row) {
        final j = Map<String, dynamic>.from(row as Map);
        final Map<String, dynamic> json = {
          'id': j['id'] ?? '',
          'firstName': j['first_name'] ?? '',
          'lastName': j['last_name'] ?? '',
          'phone': j['phone'] ?? '',
          'wilaya': j['wilaya'] ?? '',
          'address': j['address'] ?? '',
          'subtotal': j['subtotal'] ?? 0,
          'delivery': j['delivery'] ?? 0,
          'date': j['created_at'] ?? DateTime.now().toIso8601String(),
          'items': j['items'] is List ? j['items'] : [],
        };
        return Order.fromJson(json);
      }).toList();
    } catch (e) {
      print('Supabase getOrders error: $e');
      return null;
    }
  }
}
