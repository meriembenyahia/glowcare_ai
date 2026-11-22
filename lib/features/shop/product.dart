class Product {
  final String id;
  final String name;
  final String brand;
  final double price; // بالدينار DA
  final double rating;
  final String category;
  final String image;
  final String description;
  final List<String> ingredients;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.category,
    required this.image,
    this.description = '',
    this.ingredients = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // مطابقة تصنيفات الـ API مع تصنيفات التطبيق تاعك
    final rawCat = (json['category'] ?? '').toString().toLowerCase();
    String mappedCategory = 'Skincare';
    if (rawCat == 'beauty') {
      mappedCategory = 'Makeup';
    } else if (rawCat == 'fragrances') {
      mappedCategory = 'Fragrance';
    }

    // تحويل السعر من الدولار للدينار وتقريبه
    final usdPrice = (json['price'] as num?)?.toDouble() ?? 10.0;
    final daPrice = (usdPrice * 200).roundToDouble();

    return Product(
      id: json['id'].toString(),
      name: json['title'] ?? '',
      brand: json['brand'] ?? 'GlowCare',
      price: daPrice,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      category: mappedCategory,
      image: json['thumbnail'] ?? '',
      description: json['description'] ?? '',
      // DummyJSON يرجع tags، نستعملوهم كمكونات/خصائص
      ingredients: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}