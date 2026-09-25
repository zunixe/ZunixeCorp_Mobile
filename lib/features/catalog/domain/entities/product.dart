class Product {
  final String id;
  final String sku;
  final String name;
  final double price;
  final double originalPrice;
  final int stock;
  final String imageUrl;
  final List<String> imageList;
  final String category;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.originalPrice = 0,
    this.stock = 0,
    this.imageUrl = '',
    this.imageList = const [],
    this.category = '',
    this.sku = '',
  });

  int get discountPercent {
    if (originalPrice <= 0 || originalPrice <= price) return 0;
    return ((originalPrice - price) / originalPrice * 100).round();
  }

  factory Product.fromSupabase(Map<String, dynamic> row) {
    List<String> images = [];
    final raw = row['image_urls'];
    if (raw is List) {
      images = raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = raw.replaceAll(RegExp(r'^\[|\]$'), '').split(',');
        images = decoded.map((s) => s.trim().replaceAll('"', '')).where((s) => s.isNotEmpty).toList();
      } catch (_) {}
    }

    return Product(
      id: (row['id'] ?? '').toString(),
      sku: (row['sku'] ?? '').toString(),
      name: (row['name'] ?? '').toString(),
      price: _toDouble(row['price']),
      originalPrice: _toDouble(row['original_price']),
      stock: _toInt(row['stock']),
      imageUrl: images.isNotEmpty ? images.first : '',
      imageList: images,
      category: (row['category'] ?? '').toString(),
      description: row['description']?.toString(),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {    List<String> images = [];
    final rawImages = json['image_urls'] ?? json['imageList'] ?? json['image_list'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      images = [rawImages];
    }
    final imageUrl = images.isNotEmpty ? images.first : '';

    final price = _toDouble(json['price']);
    final originalPrice = json.containsKey('originalPrice') || json.containsKey('original_price')
        ? _toDouble(json['originalPrice'] ?? json['original_price'])
        : price;

    return Product(
      id: (json['id'] ?? json['itemId'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      name: (json['name'] ?? json['itemName'] ?? '').toString(),
      price: price,
      originalPrice: originalPrice,
      stock: _toInt(json['stock'] ?? json['totalStock']),
      imageUrl: imageUrl,
      imageList: images,
      category: (json['category'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}

/// num, String angka ("12.500"/"12500"), atau null → double aman.
double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) {
    final cleaned = v.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }
  return 0;
}

int _toInt(dynamic v) => _toDouble(v).round();

// NOTE (Fase 2): dummyProducts id '1'..'8' dihapus — harga/stok fiktif
// dengan tombol Beli aktif berbahaya (FK violation / harga palsu).
