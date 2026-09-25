import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

void main() {
  group('CartItem.fromRow', () {
    test('parsing lengkap dengan nested products.stock', () {
      final item = CartItem.fromRow({
        'id': 'ci1',
        'product_id': 'p1',
        'product_name': 'Sensor',
        'product_image': 'a.png',
        'price': 12500,
        'quantity': 3,
        'products': {'stock': 7},
      });
      expect(item.id, 'ci1');
      expect(item.productId, 'p1');
      expect(item.productName, 'Sensor');
      expect(item.productImage, 'a.png');
      expect(item.price, 12500);
      expect(item.quantity, 3);
      expect(item.stock, 7);
    });

    test('tanpa nested products -> stock tak terbatas (1<<30)', () {
      final item = CartItem.fromRow({
        'id': 'ci1',
        'product_id': 'p1',
        'price': 100,
        'quantity': 1,
      });
      expect(item.stock, 1 << 30);
    });

    test('products bukan Map -> stock tak terbatas', () {
      final item = CartItem.fromRow({
        'id': 'ci1',
        'product_id': 'p1',
        'products': 'oops',
      });
      expect(item.stock, 1 << 30);
    });

    test('quantity null -> default 1', () {
      final item = CartItem.fromRow({'id': 'x', 'product_id': 'p'});
      expect(item.quantity, 1);
    });

    test('price null -> default 0', () {
      final item = CartItem.fromRow({'id': 'x', 'product_id': 'p'});
      expect(item.price, 0);
    });

    test('product_name & product_image null -> string kosong', () {
      final item = CartItem.fromRow({'id': 'x', 'product_id': 'p'});
      expect(item.productName, '');
      expect(item.productImage, '');
    });

    test('id / product_id numerik -> toString', () {
      final item = CartItem.fromRow({'id': 99, 'product_id': 42});
      expect(item.id, '99');
      expect(item.productId, '42');
    });

    test('price sebagai double', () {
      final item = CartItem.fromRow({'id': 'x', 'product_id': 'p', 'price': 9.5});
      expect(item.price, 9.5);
    });

    test('quantity mutable dapat diubah', () {
      final item = CartItem.fromRow({'id': 'x', 'product_id': 'p', 'quantity': 2});
      item.quantity = 5;
      expect(item.quantity, 5);
    });
  });

  group('default stock', () {
    test('konstruktor memakai 1<<30 bila tak diberi stock', () {
      final item = CartItem(
        id: 'x',
        productId: 'p',
        productName: 'n',
        productImage: '',
        price: 1,
        quantity: 1,
      );
      expect(item.stock, 1 << 30);
    });
  });
}
