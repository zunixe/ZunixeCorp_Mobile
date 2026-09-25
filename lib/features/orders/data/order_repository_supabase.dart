import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/orders/domain/entities/order.dart';
import 'package:zunixe_corp_mobile/features/orders/domain/repositories/order_repository.dart';

/// [OrderRepository] berbasis Supabase/PostgREST + RPC.
class OrderRepositorySupabase implements OrderRepository {
  /// [client] dapat di-inject untuk pengujian; default ke singleton global.
  OrderRepositorySupabase({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<Result<OrderConfirmation>> placeOrder({
    required String shippingAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? idempotencyKey,
  }) async {
    try {
      final res = await _client.rpc('place_order', params: {
        'p_shipping_address': shippingAddress,
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_notes': notes,
        'p_idempotency_key': idempotencyKey,
      });
      return Result.ok(
          OrderConfirmation.fromMap(Map<String, dynamic>.from(res as Map)));
    } catch (e) {
      return Result.err(
          Failure.from(e, fallback: 'Gagal membuat pesanan.'));
    }
  }

  @override
  Future<Result<List<Order>>> getMyOrders(String userId) async {
    try {
      final rows = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      final orders = (rows as List)
          .map((r) => Order.fromMap(Map<String, dynamic>.from(r)))
          .toList();
      return Result.ok(orders);
    } catch (e) {
      return Result.err(
          Failure.from(e, fallback: 'Gagal memuat pesanan'));
    }
  }

  @override
  Future<Result<Order?>> getOrder(String orderId) async {
    try {
      final row = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .maybeSingle();
      if (row == null) return const Result.ok(null);
      return Result.ok(Order.fromMap(Map<String, dynamic>.from(row)));
    } catch (_) {
      return const Result.ok(null);
    }
  }

  @override
  Future<Result<void>> cancelOrder(String orderId) async {
    try {
      await _client.rpc('cancel_order', params: {'p_order_id': orderId});
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
          Failure.from(e, fallback: 'Gagal membatalkan.'));
    }
  }
}
