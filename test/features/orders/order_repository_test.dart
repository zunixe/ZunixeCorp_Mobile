import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';

import '../../helpers/mock_supabase.dart';
import '../../helpers/supabase_test_client.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> orderMap({
    String id = 'o1',
    String code = 'INV-1',
    String status = 'pending',
    String payment = 'unpaid',
  }) =>
      <String, dynamic>{
        'id': id,
        'order_code': code,
        'status': status,
        'payment_status': payment,
        'total': 150000,
        'created_at': '2024-05-01T10:30:00Z',
        'shipping_address': 'Jl. Mawar 1',
        'customer_phone': '0812',
        'notes': 'cepat',
        'order_items': [
          <String, dynamic>{
            'product_name': 'Sensor',
            'quantity': 2,
            'price': 75000,
          },
        ],
      };

  group('Order.fromMap', () {
    test('parsing lengkap', () {
      final o = Order.fromMap(orderMap());
      expect(o.id, 'o1');
      expect(o.orderCode, 'INV-1');
      expect(o.status, 'pending');
      expect(o.paymentStatus, 'unpaid');
      expect(o.total, 150000);
      expect(o.createdAt, DateTime.parse('2024-05-01T10:30:00Z'));
      expect(o.shippingAddress, 'Jl. Mawar 1');
      expect(o.items.single.productName, 'Sensor');
      expect(o.items.single.subtotal, 150000);
    });

    test('default aman untuk map kosong', () {
      final o = Order.fromMap({});
      expect(o.id, '');
      expect(o.orderCode, '-');
      expect(o.status, 'pending');
      expect(o.total, 0);
      expect(o.createdAt, isNull);
      expect(o.items, isEmpty);
    });

    test('isPaid + canCancel', () {
      expect(Order.fromMap(orderMap()).canCancel, isTrue);
      expect(
          Order.fromMap(orderMap(payment: 'paid')).canCancel, isFalse);
      expect(
          Order.fromMap(orderMap(status: 'shipped')).canCancel, isFalse);
      expect(
          Order.fromMap(orderMap(status: 'completed', payment: 'paid'))
              .isPaid,
          isTrue);
    });
  });

  group('OrderConfirmation', () {
    test('fromMap + toMap round-trip', () {
      const c = OrderConfirmation(orderCode: 'INV-9', total: 5000);
      final back = OrderConfirmation.fromMap(c.toMap());
      expect(back.orderCode, 'INV-9');
      expect(back.total, 5000);
    });

    test('default aman', () {
      final c = OrderConfirmation.fromMap({});
      expect(c.orderCode, '-');
      expect(c.total, 0);
    });
  });

  group('orderStatusLabel (domain)', () {
    test('semua status', () {
      expect(orderStatusLabel('pending'), 'Menunggu');
      expect(orderStatusLabel('processing'), 'Diproses');
      expect(orderStatusLabel('shipped'), 'Dikirim');
      expect(orderStatusLabel('completed'), 'Selesai');
      expect(orderStatusLabel('cancelled'), 'Dibatalkan');
      expect(orderStatusLabel('aneh'), 'aneh');
    });
  });

  group('OrderRepositorySupabase', () {
    MockSupabaseTestClient authedClient() {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      return client;
    }

    test('placeOrder ok -> confirmation', () async {
      final client = authedClient();
      client.stubRpc('place_order', returning: <String, dynamic>{
        'order_code': 'INV-99',
        'total': 150000,
      });
      final repo = OrderRepositorySupabase(client: client);

      final res = await repo.placeOrder(
        shippingAddress: 'Jl. Mawar 1',
        idempotencyKey: 'k',
      );

      expect(res.isOk, isTrue);
      expect(res.value.orderCode, 'INV-99');
      expect(res.value.total, 150000);
    });

    test('placeOrder error -> Err', () async {
      final client = authedClient();
      client.stubRpc('place_order', throws: Exception('stok habis'));
      final repo = OrderRepositorySupabase(client: client);

      final res = await repo.placeOrder(
        shippingAddress: 'A',
        idempotencyKey: 'k',
      );

      expect(res.isErr, isTrue);
      expect(res.failure.message, 'stok habis');
    });

    test('getMyOrders ok -> entities', () async {
      final client = authedClient();
      client.stubFrom('orders', returning: <Map<String, dynamic>>[
        orderMap(),
      ]);
      final repo = OrderRepositorySupabase(client: client);

      final res = await repo.getMyOrders('u7');

      expect(res.isOk, isTrue);
      expect(res.value.single.orderCode, 'INV-1');
      expect(res.value.single.items.single.quantity, 2);
    });

    test('getOrder null -> Ok(null)', () async {
      final client = authedClient();
      client.stubFrom('orders', returning: null);
      final repo = OrderRepositorySupabase(client: client);

      final res = await repo.getOrder('x');

      expect(res.isOk, isTrue);
      expect(res.value, isNull);
    });

    test('cancelOrder ok + error', () async {
      final client = authedClient();
      client.stubRpc('cancel_order', returning: null);
      final repo = OrderRepositorySupabase(client: client);
      expect((await repo.cancelOrder('o5')).isOk, isTrue);

      final client2 = authedClient();
      client2.stubRpc('cancel_order', throws: Exception('terlambat'));
      final repo2 = OrderRepositorySupabase(client: client2);
      final res = await repo2.cancelOrder('o5');
      expect(res.isErr, isTrue);
      expect(res.failure.message, 'terlambat');
    });
  });
}
