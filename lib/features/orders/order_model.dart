import '../cart/cart_provider.dart';
import '../shop/product.dart';

class Order {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String wilaya;
  final String address;
  final List<CartItem> items;
  final double subtotal;
  final double delivery;
  final DateTime date;
  final String status; // Pending, Confirmed, Shipped, Delivered, Cancelled

  const Order({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.wilaya,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.date,
    this.status = 'Pending',
  });

  Order copyWith({
    String? status,
  }) {
    return Order(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      wilaya: wilaya,
      address: address,
      items: items,
      subtotal: subtotal,
      delivery: delivery,
      date: date,
      status: status ?? this.status,
    );
  }

  double get total => subtotal + delivery;

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'wilaya': wilaya,
    'address': address,
    'subtotal': subtotal,
    'delivery': delivery,
    'date': date.toIso8601String(),
    'status': status,
    'items': [
      for (final e in items)
        {
          'productId': e.product.id,
          'name': e.product.name,
          'brand': e.product.brand,
          'price': e.product.price,
          'image': e.product.image,
          'category': e.product.category,
          'qty': e.quantity,
        },
    ],
  };

  factory Order.fromJson(Map<String, dynamic> j) {
    final items = <CartItem>[];
    final rawItems = j['items'];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map) {
          final product = Product(
            id: (it['productId'] ?? '').toString(),
            name: (it['name'] ?? 'Product').toString(),
            brand: (it['brand'] ?? 'GlowCare').toString(),
            price: (it['price'] as num?)?.toDouble() ?? 0.0,
            rating: 4.5,
            category: (it['category'] ?? 'Skincare').toString(),
            image: (it['image'] ?? '').toString(),
          );
          items.add(CartItem(
            product: product,
            quantity: (it['qty'] as num?)?.toInt() ?? 1,
          ));
        }
      }
    }
    return Order(
      id: (j['id'] ?? '').toString(),
      firstName: (j['firstName'] ?? '').toString(),
      lastName: (j['lastName'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      wilaya: (j['wilaya'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      items: items,
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0.0,
      delivery: (j['delivery'] as num?)?.toDouble() ?? 0.0,
      date: j['date'] != null
          ? (DateTime.tryParse(j['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      status: (j['status'] ?? 'Pending').toString(),
    );
  }
}
