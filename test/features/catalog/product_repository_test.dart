import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../../helpers/supabase_test_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  Map<String, dynamic> row(String id, {double price = 1000}) =>
      <String, dynamic>{
        'id': id,
        'name': 'Produk $id',
        'price': price,
        'original_price': 0,
        'stock': 5,
        'image_urls': <String>[],
        'category': 'Elektronik',
      };

  group('ProductRepositorySupabase', () {
    test('getProducts ok -> Result.ok + filter terkirim', () async {
      final client = MockSupabaseTestClient();
      final fb = client.stubFrom('products', returning: <Map<String, dynamic>>[
        row('a'),
        row('b'),
      ]);
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getProducts();

      expect(res.isOk, isTrue);
      expect(res.value, hasLength(2));
      expect(res.value.first.id, 'a');
      expect(fb.argOf('eq'), 'is_active');
      expect(fb.argOf('gt'), 'stock');
    });

    test('getProducts error -> Result.err(ServerFailure)', () async {
      final client = MockSupabaseTestClient();
      client.stubFrom('products', throws: Exception('net'));
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getProducts();

      expect(res.isErr, isTrue);
      expect(res.failure, isA<Failure>());
      expect(res.failure.message, isNotEmpty);
    });

    test('getCategories ok -> dedup', () async {
      final client = MockSupabaseTestClient();
      client.stubFrom('products', returning: <Map<String, dynamic>>[
        <String, dynamic>{'category': 'Elektronik'},
        <String, dynamic>{'category': 'Elektronik'},
        <String, dynamic>{'category': ''},
      ]);
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getCategories();

      expect(res.isOk, isTrue);
      expect(res.value, ['Elektronik']);
    });

    test('getProductById null -> Ok(null)', () async {
      final client = MockSupabaseTestClient();
      client.stubFrom('products', returning: null);
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getProductById('x');

      expect(res.isOk, isTrue);
      expect(res.value, isNull);
    });

    test('getProductById ada -> Ok(product)', () async {
      final client = MockSupabaseTestClient();
      client.stubFrom('products', returning: row('p1', price: 5000));
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getProductById('p1');

      expect(res.isOk, isTrue);
      expect(res.value!.price, 5000);
    });
  });
}
