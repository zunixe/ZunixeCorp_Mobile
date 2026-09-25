import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  /// Kartu butuh constraint lebar seperti di Grid produksi (anti-overflow).
  Widget card(Product product, {VoidCallback? onTap}) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo()),
        cartRepositoryProvider.overrideWithValue(MockCartRepository()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: ProductCard(product: product, onTap: onTap),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pump(
    WidgetTester tester, {
    double price = 75000,
    double originalPrice = 100000,
    int stock = 5,
    String name = 'Sensor Suhu',
  }) {
    return tester.pumpWidget(card(buildProduct(
      name: name,
      price: price,
      originalPrice: originalPrice,
      stock: stock,
    )));
  }

  testWidgets('nama + harga tampil', (tester) async {
    await pump(tester);
    expect(find.text('Sensor Suhu'), findsOneWidget);
    expect(find.text('Rp75.000'), findsOneWidget);
  });

  testWidgets('badge diskon + harga coret saat ada diskon', (tester) async {
    await pump(tester, price: 75000, originalPrice: 100000);
    expect(find.text('-25%'), findsOneWidget);
    expect(find.text('Rp100.000'), findsOneWidget);
  });

  testWidgets('tanpa diskon -> tanpa badge & harga coret', (tester) async {
    await pump(tester, price: 50000, originalPrice: 0);
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Rp50.000'), findsOneWidget);
  });

  testWidgets('tap kartu -> onTap dipanggil', (tester) async {
    var tapped = false;
    await tester.pumpWidget(card(buildProduct(), onTap: () => tapped = true));
    await tester.tap(find.byType(ProductCard));
    expect(tapped, isTrue);
  });
}
