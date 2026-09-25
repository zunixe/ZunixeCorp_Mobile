import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

import '../../helpers/mock_supabase.dart';
import '../../helpers/supabase_test_client.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> row(String id,
          {int qty = 1, double price = 1000, int? stock}) =>
      <String, dynamic>{
        'id': id,
        'product_id': 'p1',
        'product_name': 'A',
        'product_image': '',
        'price': price,
        'quantity': qty,
        if (stock != null) 'products': {'stock': stock},
      };

  MockSupabaseTestClient authedClient(String userId) {
    final client = MockSupabaseTestClient();
    stubSupabaseAuth(
      client,
      currentUser: User(
        id: userId,
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2024-01-01T00:00:00Z',
      ),
    );
    return client;
  }

  group('CartRepositorySupabase', () {
    test('fetchCart ok -> items terparse', () async {
      final client = authedClient('u1');
      client.stubFrom('cart_items', returning: <Map<String, dynamic>>[
        row('ci1', qty: 2, stock: 5),
      ]);
      final repo = CartRepositorySupabase(client: client);

      final res = await repo.fetchCart('u1');

      expect(res.isOk, isTrue);
      expect(res.value.single.quantity, 2);
      expect(res.value.single.stock, 5);
    });

    test('fetchCart error -> Err', () async {
      final client = authedClient('u1');
      client.stubFrom('cart_items', throws: Exception('net'));
      final repo = CartRepositorySupabase(client: client);

      final res = await repo.fetchCart('u1');

      expect(res.isErr, isTrue);
      // Pesan mentah diteruskan; provider memetakan ke pesan generik.
      expect(res.failure.message, 'net');
    });

    test('addToCart ok -> Ok(null) + rpc terpanggil', () async {
      final client = authedClient('u1');
      client.stubRpc('cart_add', returning: null);
      final repo = CartRepositorySupabase(client: client);

      final res =
          await repo.addToCart(productId: 'p1', quantity: 2);

      expect(res.isOk, isTrue);
      final captured = verify(
        () => client.rpc<dynamic>('cart_add',
            params: captureAny(named: 'params')),
      ).captured.single as Map;
      expect(captured['p_product_id'], 'p1');
      expect(captured['p_qty'], 2);
    });

    test('addToCart server error -> Err(message server)', () async {
      final client = authedClient('u1');
      client.stubRpc('cart_add',
          throws: const PostgrestException(message: 'Stok tidak cukup'));
      final repo = CartRepositorySupabase(client: client);

      final res = await repo.addToCart(productId: 'p1');

      expect(res.isErr, isTrue);
      expect(res.failure.message, 'Stok tidak cukup');
    });

    test('updateQuantity qty 0 -> delete path', () async {
      final client = authedClient('u1');
      client.stubFrom('cart_items', returning: <Map<String, dynamic>>[]);
      final repo = CartRepositorySupabase(client: client);

      final res = await repo.updateQuantity('ci1', 0);

      expect(res.isOk, isTrue);
      final qb = client.queryBuilders['cart_items']!.first;
      expect(qb.wasCalled('delete'), isTrue);
    });

    test('removeItem error -> Err', () async {
      final client = authedClient('u1');
      client.stubFrom('cart_items', throws: Exception('net'));
      final repo = CartRepositorySupabase(client: client);

      final res = await repo.removeItem('ci1');

      expect(res.isErr, isTrue);
    });

    test('clearCart ok', () async {
      final client = authedClient('u1');
      client.stubFrom('cart_items', returning: <Map<String, dynamic>>[]);
      final repo = CartRepositorySupabase(client: client);

      expect((await repo.clearCart('u1')).isOk, isTrue);
    });
  });
}
