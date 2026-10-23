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
        <String, dynamic>{'category': '100046'},
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

    test('getProductById error -> Ok(null) (ditelan)', () async {
      final client = MockSupabaseTestClient();
      client.stubFrom('products', throws: Exception('net'));
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getProductById('p1');

      expect(res.isOk, isTrue);
      expect(res.value, isNull);
    });

    test('getCategories error -> NetworkFailure berpesan ID', () async {
      final client = MockSupabaseTestClient();
      client.stubFrom('products', throws: Exception('net'));
      final repo = ProductRepositorySupabase(client: client);

      final res = await repo.getCategories();

      expect(res.isErr, isTrue);
      expect(res.failure, isA<NetworkFailure>());
      expect(res.failure.message, 'Gagal memuat kategori. Periksa koneksi.');
    });

    test('search kosong -> tanpa filter ilike', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(search: '   ');

      expect(fb.wasCalled('ilike'), isFalse);
    });

    test('search terisi -> ilike name + escape wildcard', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(search: '10%_x');

      expect(fb.wasCalled('ilike'), isTrue);
      expect(fb.argOf('ilike'), 'name');
      final pattern =
          fb.calls.firstWhere((c) => c.method == 'ilike').args.last as String;
      expect(pattern, r'%10\%\_x%');
    });

    test('category terisi -> filter eq category', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(category: 'Sensor');

      final eqArgs = fb.calls
          .where((c) => c.method == 'eq')
          .map((c) => c.args.first)
          .toList();
      expect(eqArgs, containsAll(['is_active', 'category']));
    });

    test('sort cheapest -> order price ascending', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(sort: ProductSort.cheapest);

      final order = fb.calls.firstWhere((c) => c.method == 'order');
      expect(order.args.first, 'price');
      expect(order.named[#ascending], isTrue);
    });

    test('sort priciest -> order price descending', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(sort: ProductSort.priciest);

      final order = fb.calls.firstWhere((c) => c.method == 'order');
      expect(order.args.first, 'price');
      expect(order.named[#ascending], isFalse);
    });

    test('sort newest -> order updated_at descending', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(sort: ProductSort.newest);

      final order = fb.calls.firstWhere((c) => c.method == 'order');
      expect(order.args.first, 'updated_at');
      expect(order.named[#ascending], isFalse);
    });

    test('range memakai offset + limit', () async {
      final client = MockSupabaseTestClient();
      final fb =
          client.stubFrom('products', returning: <Map<String, dynamic>>[]);
      final repo = ProductRepositorySupabase(client: client);

      await repo.getProducts(offset: 10, limit: 5);

      final range = fb.calls.firstWhere((c) => c.method == 'range');
      expect(range.args, [10, 14]);
    });
  });
}
