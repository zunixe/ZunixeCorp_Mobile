import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

void main() {
  group('discountPercent', () {
    test('0 ketika originalPrice <= 0', () {
      expect(
        const Product(id: '1', name: 'A', price: 100, originalPrice: 0)
            .discountPercent,
        0,
      );
      expect(
        const Product(id: '1', name: 'A', price: 100, originalPrice: -5)
            .discountPercent,
        0,
      );
    });

    test('0 ketika originalPrice <= price (tanpa diskon)', () {
      expect(
        const Product(id: '1', name: 'A', price: 100, originalPrice: 100)
            .discountPercent,
        0,
      );
      expect(
        const Product(id: '1', name: 'A', price: 100, originalPrice: 90)
            .discountPercent,
        0,
      );
    });

    test('hitung diskon normal', () {
      expect(
        const Product(id: '1', name: 'A', price: 75000, originalPrice: 100000)
            .discountPercent,
        25,
      );
    });

    test('pembulatan 10%', () {
      expect(
        const Product(id: '1', name: 'A', price: 90, originalPrice: 100)
            .discountPercent,
        10,
      );
    });

    test('pembulatan 33%', () {
      expect(
        const Product(id: '1', name: 'A', price: 2, originalPrice: 3)
            .discountPercent,
        33,
      );
    });

    test('pembulatan 50%', () {
      expect(
        const Product(id: '1', name: 'A', price: 50, originalPrice: 100)
            .discountPercent,
        50,
      );
    });
  });

  group('Product.fromSupabase', () {
    test('parsing dasar + defaults', () {
      final p = Product.fromSupabase({
        'id': 7,
        'sku': 'SKU-7',
        'name': 'Sensor',
        'price': 12500,
        'original_price': 15000,
        'stock': 4,
        'category': 'Sensor',
        'description': 'Deskripsi',
      });
      expect(p.id, '7');
      expect(p.sku, 'SKU-7');
      expect(p.name, 'Sensor');
      expect(p.price, 12500);
      expect(p.originalPrice, 15000);
      expect(p.stock, 4);
      expect(p.category, 'Sensor');
      expect(p.description, 'Deskripsi');
      expect(p.imageUrl, '');
      expect(p.imageList, isEmpty);
    });

    test('field hilang -> default aman', () {
      final p = Product.fromSupabase({});
      expect(p.id, '');
      expect(p.name, '');
      expect(p.price, 0);
      expect(p.originalPrice, 0);
      expect(p.stock, 0);
      expect(p.category, '');
      expect(p.description, isNull);
      expect(p.imageUrl, '');
    });

    test('price sebagai String "12.500"', () {
      final p = Product.fromSupabase({'price': '12.500'});
      expect(p.price, 12500);
    });

    test('price sebagai String "12500"', () {
      final p = Product.fromSupabase({'price': '12500'});
      expect(p.price, 12500);
    });

    test('price String koma sebagai desimal ID "12,500" -> 12.5', () {
      // Konvensi: '.' = pemisah ribuan, ',' = pemisah desimal.
      final p = Product.fromSupabase({'price': '12,500'});
      expect(p.price, 12.5);
    });

    test('price String dengan simbol Rp', () {
      final p = Product.fromSupabase({'price': 'Rp 25.000'});
      expect(p.price, 25000);
    });

    test('price null -> 0', () {
      expect(Product.fromSupabase({'price': null}).price, 0);
    });

    test('image_urls sebagai List', () {
      final p = Product.fromSupabase({
        'image_urls': ['a.png', 'b.png', ''],
      });
      expect(p.imageList, ['a.png', 'b.png']);
      expect(p.imageUrl, 'a.png');
    });

    test('image_urls sebagai List kosong', () {
      final p = Product.fromSupabase({'image_urls': <String>[]});
      expect(p.imageList, isEmpty);
      expect(p.imageUrl, '');
    });

    test('image_urls sebagai String JSON-ish', () {
      final p = Product.fromSupabase({'image_urls': '["x.png", "y.png"]'});
      expect(p.imageList, ['x.png', 'y.png']);
      expect(p.imageUrl, 'x.png');
    });

    test('image_urls String tunggal tanpa bracket', () {
      final p = Product.fromSupabase({'image_urls': 'solo.png'});
      expect(p.imageList, ['solo.png']);
      expect(p.imageUrl, 'solo.png');
    });

    test('image_urls bukan List/String -> kosong', () {
      expect(Product.fromSupabase({'image_urls': 42}).imageList, isEmpty);
    });

    test('stock dari String "12.7" -> titik dianggap pemisah ribuan', () {
      // '.' dihapus sebagai pemisah ribuan -> 127.
      expect(Product.fromSupabase({'stock': '12.7'}).stock, 127);
    });

    test('stock dari String "12" -> 12', () {
      expect(Product.fromSupabase({'stock': '12'}).stock, 12);
    });
  });

  group('Product.fromJson', () {
    test('alias id/itemId, name/itemName', () {
      final p = Product.fromJson({
        'itemId': 'abc',
        'itemName': 'Board',
        'price': 100,
      });
      expect(p.id, 'abc');
      expect(p.name, 'Board');
    });

    test('original_price dipakai jika ada', () {
      final p = Product.fromJson({'price': 100, 'original_price': 200});
      expect(p.originalPrice, 200);
    });

    test('originalPrice (camel) dipakai jika ada', () {
      final p = Product.fromJson({'price': 100, 'originalPrice': 150});
      expect(p.originalPrice, 150);
    });

    test('originalPrice default = price bila tak ada key', () {
      final p = Product.fromJson({'price': 100});
      expect(p.originalPrice, 100);
    });

    test('stock dari totalStock', () {
      final p = Product.fromJson({'totalStock': 9});
      expect(p.stock, 9);
    });

    test('imageList sebagai list dipakai', () {
      final p = Product.fromJson({
        'imageList': ['p.png', 'q.png'],
      });
      expect(p.imageList, ['p.png', 'q.png']);
      expect(p.imageUrl, 'p.png');
    });

    test('image_list snake_case dipakai', () {
      final p = Product.fromJson({
        'image_list': ['r.png'],
      });
      expect(p.imageList, ['r.png']);
    });

    test('image_urls String tunggal -> satu elemen', () {
      final p = Product.fromJson({'image_urls': 'only.png'});
      expect(p.imageList, ['only.png']);
    });

    test('price String locale ID "1.234,56"', () {
      final p = Product.fromJson({'price': '1.234,56'});
      expect(p.price, 1234.56);
    });

    test('price non-numerik -> 0', () {
      expect(Product.fromJson({'price': 'abc'}).price, 0);
    });

    test('price negatif String', () {
      expect(Product.fromJson({'price': '-5'}).price, -5);
    });

    test('price bool -> 0', () {
      expect(Product.fromJson({'price': true}).price, 0);
    });

    test('stock null -> 0', () {
      expect(Product.fromJson({'stock': null}).stock, 0);
    });
  });
}
