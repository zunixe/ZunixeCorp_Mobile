import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
void main() {
  group('productSortFromLabel', () {
    test('Terbaru -> newest', () {
      expect(productSortFromLabel('Terbaru'), ProductSort.newest);
    });

    test('Termurah -> cheapest', () {
      expect(productSortFromLabel('Termurah'), ProductSort.cheapest);
    });

    test('Termahal -> priciest', () {
      expect(productSortFromLabel('Termahal'), ProductSort.priciest);
    });

    test('label tak dikenal -> newest (default)', () {
      expect(productSortFromLabel('Terlaris'), ProductSort.newest);
      expect(productSortFromLabel(''), ProductSort.newest);
    });

    test('kProductSortLabels berisi 3 label & urut', () {
      expect(kProductSortLabels, ['Terbaru', 'Termurah', 'Termahal']);
    });
  });

  group('ProductRepository.pageSize', () {
    test('default 20', () => expect(ProductRepository.pageSize, 20));
  });
}
