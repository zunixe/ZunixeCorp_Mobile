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

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    final rawImages = json['image_urls'] ?? json['imageList'] ?? json['image_list'];
    if (rawImages is List) {
      images = rawImages.whereType<String>().toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      images = [rawImages];
    }
    final imageUrl = images.isNotEmpty ? images.first : '';

    final price = (json['price'] ?? 0).toDouble();
    final originalPrice = (json['originalPrice'] ?? json['original_price'] ?? price).toDouble();

    return Product(
      id: (json['id'] ?? json['itemId'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      name: (json['name'] ?? json['itemName'] ?? '').toString(),
      price: price,
      originalPrice: originalPrice,
      stock: (json['stock'] ?? json['totalStock'] ?? 0).toInt(),
      imageUrl: imageUrl,
      imageList: images,
      category: (json['category'] ?? '').toString(),
      description: json['description'],
    );
  }
}

final List<Product> dummyProducts = [
  Product(
    id: '1',
    name: 'ESP32 ESP-32S WiFi + Bluetooth Development Board',
    price: 98100,
    originalPrice: 109000,
    imageUrl: 'assets/bfb52d4b9f3cf7ff29077954bbbd5fe1_1775517138178_resized512-jpeg.webp',
  ),
  Product(
    id: '2',
    name: 'ARDUINO UNO R3 CH340 ATMEGA328P COMPATIBLE',
    price: 103500,
    originalPrice: 115000,
    imageUrl: 'assets/4a83aa86e33c2815bb2b52b5f8dd8686_1775430834342_resized512-jpeg.webp',
  ),
  Product(
    id: '3',
    name: 'SENSOR API FLAME SENSOR LM393 IR INFRARED DETECTION',
    price: 14500,
    originalPrice: 20000,
    imageUrl: 'assets/6c8c0951-b9c2-47e0-9a94-a24a56c3e972_1752016277960_resized512-png.webp',
  ),
  Product(
    id: '4',
    name: 'SIM800L GPRS GSM MODULE MICROSIM CARD QUAD-BAND',
    price: 89000,
    originalPrice: 110000,
    imageUrl: 'assets/a3f56016d7b74883ab3eee5edb6c8bc4_1748673422115_resized512-jpeg.webp',
  ),
  Product(
    id: '5',
    name: 'HC-05 BLUETOOTH MODULE FOR ARDUINO, RASPBERRY PI',
    price: 89000,
    originalPrice: 100000,
    imageUrl: 'assets/main-image-2_1775881477356_resized512-jpeg.webp',
  ),
  Product(
    id: '6',
    name: 'Power Supply 50W 5V 10A Running Text Adaptor',
    price: 134000,
    originalPrice: 175000,
    imageUrl: 'assets/9e6feb29-cc6c-4807-a621-7e418ef35870_1751923568956_resized512-png.webp',
  ),
  Product(
    id: '7',
    name: 'DHT11 MODUL SENSOR KELEMBABAN SUHU TEMPERATURE',
    price: 35000,
    originalPrice: 45000,
    imageUrl: 'assets/cd0bc853-4550-4214-8897-c54aa78d8d45_1751926385243_resized512-png.webp',
  ),
  Product(
    id: '8',
    name: 'RELAY 5V 1 CHANNEL ACTIVE HIGH / ACTIVE LOW',
    price: 22500,
    originalPrice: 32000,
    imageUrl: 'assets/090f329c7415745f2878517293d05cc1_1775517283301_resized512-jpeg.webp',
  ),
];
