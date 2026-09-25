import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/catalog/domain/entities/product.dart';
import 'package:zunixe_corp_mobile/features/catalog/domain/product_sort.dart';

/// Kontrak data katalog. Implementasi: Supabase (`data/`), fake (test).
abstract class ProductRepository {
  static const int pageSize = 20;

  /// Produk aktif + stok tersedia, difilter/diurutkan server-side.
  Future<Result<List<Product>>> getProducts({
    String? search,
    String? category,
    int offset = 0,
    int limit = pageSize,
    ProductSort sort = ProductSort.newest,
  });

  /// Daftar kategori unik (produk aktif + stok tersedia).
  Future<Result<List<String>>> getCategories();

  /// Satu produk; `Ok(null)` bila tidak ditemukan.
  Future<Result<Product?>> getProductById(String id);
}
