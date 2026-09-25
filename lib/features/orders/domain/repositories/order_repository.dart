import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/orders/domain/entities/order.dart';

/// Kontrak data pesanan. Implementasi: Supabase (`data/`), fake (test).
abstract class OrderRepository {
  /// Checkout atomik via RPC `place_order`.
  /// [idempotencyKey] wajib unik per upaya — retry dengan key sama
  /// mengembalikan order yang sudah ada (anti double-submit).
  Future<Result<OrderConfirmation>> placeOrder({
    required String shippingAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? idempotencyKey,
  });

  Future<Result<List<Order>>> getMyOrders(String userId);
  Future<Result<Order?>> getOrder(String orderId);

  /// Batalkan pesanan milik sendiri (stok dikembalikan server).
  Future<Result<void>> cancelOrder(String orderId);
}
