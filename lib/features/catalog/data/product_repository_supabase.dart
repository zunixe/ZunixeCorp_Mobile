import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/catalog/domain/entities/product.dart';
import 'package:zunixe_corp_mobile/features/catalog/domain/product_sort.dart';
import 'package:zunixe_corp_mobile/features/catalog/domain/repositories/product_repository.dart';

/// [ProductRepository] berbasis Supabase/PostgREST.
class ProductRepositorySupabase implements ProductRepository {
  /// [client] dapat di-inject untuk pengujian; default ke singleton global.
  ProductRepositorySupabase({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<Result<List<Product>>> getProducts({
    String? search,
    String? category,
    int offset = 0,
    int limit = ProductRepository.pageSize,
    ProductSort sort = ProductSort.newest,
  }) async {
    try {
      dynamic q = _client
          .from('products')
          .select()
          .eq('is_active', true)
          .gt('stock', 0);

      final kw = search?.trim() ?? '';
      if (kw.isNotEmpty) {
        q = q.ilike('name', '%${_escapeLike(kw)}%');
      }
      if (category != null && category.isNotEmpty) {
        q = q.eq('category', category);
      }
      switch (sort) {
        case ProductSort.cheapest:
          q = q.order('price', ascending: true);
          break;
        case ProductSort.priciest:
          q = q.order('price', ascending: false);
          break;
        case ProductSort.newest:
          // Tak ada created_at → updated_at desc sebagai pendekatan.
          q = q.order('updated_at', ascending: false);
          break;
      }

      final rows = await q.range(offset, offset + limit - 1);
      final products = (rows as List)
          .map((r) => Product.fromSupabase(Map<String, dynamic>.from(r)))
          .toList();
      return Result.ok(products);
    } catch (e) {
      return Result.err(Failure.from(e,
          fallback: 'Gagal memuat produk. Periksa koneksi.'));
    }
  }

  @override
  Future<Result<List<String>>> getCategories() async {
    try {
      final rows = await _client
          .from('products')
          .select('category')
          .eq('is_active', true)
          .gt('stock', 0)
          .order('category', ascending: true)
          .limit(200);
      final set = <String>{};
      for (final r in (rows as List)) {
        final c = ((r as Map)['category'] ?? '').toString().trim();
        if (c.isNotEmpty) set.add(c);
      }
      return Result.ok(set.toList());
    } catch (e) {
      return const Result.err(
          NetworkFailure('Gagal memuat kategori. Periksa koneksi.'));
    }
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      final row = await _client
          .from('products')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) return const Result.ok(null);
      return Result.ok(Product.fromSupabase(Map<String, dynamic>.from(row)));
    } catch (_) {
      return const Result.ok(null);
    }
  }

  /// Escape wildcard LIKE agar cari '%', '_' literal aman.
  String _escapeLike(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
