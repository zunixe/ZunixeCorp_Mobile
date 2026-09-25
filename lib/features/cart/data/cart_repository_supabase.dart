import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:zunixe_corp_mobile/features/cart/domain/repositories/cart_repository.dart';

/// [CartRepository] berbasis Supabase/PostgREST + RPC `cart_add`.
class CartRepositorySupabase implements CartRepository {
  /// [client] dapat di-inject untuk pengujian; default ke singleton global.
  CartRepositorySupabase({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<Result<List<CartItem>>> fetchCart(String userId) async {
    try {
      final rows = await _client
          .from('cart_items')
          .select('*, products(stock)')
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      final items =
          (rows as List).map((r) => CartItem.fromRow(r)).toList();
      return Result.ok(items);
    } catch (e) {
      return Result.err(Failure.from(e,
          fallback: 'Gagal memuat keranjang'));
    }
  }

  @override
  Future<Result<void>> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      await _client.rpc('cart_add', params: {
        'p_product_id': productId,
        'p_qty': quantity,
      });
      return const Result.ok(null);
    } catch (e) {
      // Pesan error server sudah ramah-pengguna (mis. stok).
      return Result.err(
          Failure.from(e, fallback: 'Gagal menambah ke keranjang'));
    }
  }

  @override
  Future<Result<void>> updateQuantity(String itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await _client.from('cart_items').delete().eq('id', itemId);
      } else {
        await _client
            .from('cart_items')
            .update({'quantity': quantity}).eq('id', itemId);
      }
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
          Failure.from(e, fallback: 'Gagal memperbarui jumlah'));
    }
  }

  @override
  Future<Result<void>> removeItem(String itemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', itemId);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
          Failure.from(e, fallback: 'Gagal menghapus item'));
    }
  }

  @override
  Future<Result<void>> clearCart(String userId) async {
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
          Failure.from(e, fallback: 'Gagal mengosongkan keranjang'));
    }
  }
}
