import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String productName;
  final String productImage;
  final int price;
  int quantity;
  final int total;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      cartId: json['cart_id'].toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: (json['price'] ?? 0) is int
          ? json['price'] as int
          : (double.tryParse(json['price'].toString()) ?? 0).round(),
      quantity: (json['quantity'] ?? 1) is int
          ? json['quantity'] as int
          : (double.tryParse(json['quantity'].toString()) ?? 1).round(),
      total: (json['total'] ?? 0) is int
          ? json['total'] as int
          : (double.tryParse(json['total'].toString()) ?? 0).round(),
    );
  }
}

class CartProvider extends ChangeNotifier {
  final http.Client _client = http.Client();
  List<CartItem> _items = [];
  String? _cartId;
  bool _loading = false;

  List<CartItem> get items => _items;
  String? get cartId => _cartId;
  bool get loading => _loading;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  int get totalPrice => _items.fold(0, (sum, i) => sum + i.total);

  String get _slug => ApiConfig.storeSlug;

  Future<Map<String, String>> _headers() async {
    final authHeaders = await AuthService.authHeaders();
    if (_cartId != null) {
      authHeaders['x-cart-id'] = _cartId!;
    }
    return authHeaders;
  }

  Future<void> fetchCart() async {
    _loading = true;
    notifyListeners();
    try {
      final headers = await _headers();
      final res = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/api/public/cart/$_slug'),
        headers: headers,
      );
      final body = jsonDecode(res.body);
      if (body['status'] == 'success') {
        final itemsList = body['data']['items'] as List<dynamic>? ?? [];
        _items = itemsList.map((j) => CartItem.fromJson(j)).toList();
        if (body['data']['cart'] != null) {
          _cartId = body['data']['cart']['id'].toString();
        }
      }
    } catch (_) {
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required String productId,
    required String productName,
    required String productImage,
    required int price,
    int quantity = 1,
  }) async {
    try {
      final headers = await _headers();
      final res = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/public/cart/$_slug/items'),
        headers: headers,
        body: jsonEncode({
          'product_id': productId,
          'product_name': productName,
          'product_image': productImage,
          'price': price,
          'quantity': quantity,
        }),
      );
      final body = jsonDecode(res.body);
      if (body['status'] == 'success') {
        _cartId = body['data']['cartId'];
        final itemsList = body['data']['items'] as List<dynamic>;
        _items = itemsList.map((j) => CartItem.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final headers = await _headers();
      final res = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}/api/public/cart/$_slug/items/$itemId'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );
      final body = jsonDecode(res.body);
      if (body['status'] == 'success') {
        final itemsList = body['data']['items'] as List<dynamic>;
        _items = itemsList.map((j) => CartItem.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> removeItem(String itemId) async {
    try {
      final headers = await _headers();
      final res = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/public/cart/$_slug/items/$itemId'),
        headers: headers,
      );
      final body = jsonDecode(res.body);
      if (body['status'] == 'success') {
        final itemsList = body['data']['items'] as List<dynamic>;
        _items = itemsList.map((j) => CartItem.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      final headers = await _headers();
      await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/public/cart/$_slug'),
        headers: headers,
      );
      _items.clear();
      _cartId = null;
      notifyListeners();
    } catch (_) {}
  }
}
