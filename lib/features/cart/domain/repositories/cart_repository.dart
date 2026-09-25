import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/cart/domain/entities/cart_item.dart';

/// Kontrak data keranjang. Implementasi: Supabase (`data/`), fake (test).
///
/// Operasi tulis (`addToCart`, `updateQuantity`, `removeItem`) mengandalkan
/// sesi login aktif (RLS) sehingga tak butuh `userId` eksplisit.
abstract class CartRepository {
  Future<Result<List<CartItem>>> fetchCart(String userId);
  Future<Result<void>> addToCart({required String productId, int quantity = 1});
  Future<Result<void>> updateQuantity(String itemId, int quantity);
  Future<Result<void>> removeItem(String itemId);
  Future<Result<void>> clearCart(String userId);
}
