import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const String _storeSlug = ApiConfig.storeSlug;

  static Future<Product?> fetchProduct(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/public/store/$_storeSlug/products/$id');
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return Product.fromJson(json['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> fetchProducts({String? search, String? category}) async {
    final params = <String, String>{'limit': '100'};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;

    final uri = Uri.parse('$_baseUrl/api/public/store/$_storeSlug/products').replace(
      queryParameters: params.isEmpty ? null : params,
    );

    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) {
      throw Exception('Gagal memuat produk (HTTP ${resp.statusCode})');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;

    return items
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .where((p) => p.name.isNotEmpty)
        .toList();
  }
}
