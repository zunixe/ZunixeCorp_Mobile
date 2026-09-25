import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  Future<void> pump(
    WidgetTester tester, {
    ProductDetailScreen? screen,
    MockProductRepository? productRepo,
    MockCartRepository? cartRepo,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
              productRepo ?? MockProductRepository()),
          cartRepositoryProvider.overrideWithValue(
              cartRepo ?? MockCartRepository()),
          authRepositoryProvider.overrideWithValue(mockAuthRepo()),
        ],
        child: MaterialApp(home: screen ?? const SizedBox()),
      ),
    );
  }

  MockProductRepository productRepoWith(Product? product) {
    final repo = MockProductRepository();
    when(() => repo.getProductById(any())).thenAnswer(
      (_) async => Result.ok(product),
    );
    return repo;
  }

  testWidgets('produk langsung -> detail tampil', (tester) async {
    await pump(
        tester,
        screen: ProductDetailScreen(
            product: buildProduct(
          name: 'Board X',
          price: 120000,
          originalPrice: 150000,
          stock: 4,
          category: 'Board',
          description: 'Deskripsi mantap',
        )));
    expect(find.text('Board X'), findsOneWidget);
    expect(find.text('Rp120.000'), findsOneWidget);
    expect(find.text('Rp150.000'), findsOneWidget);
    expect(find.text('-20%'), findsOneWidget);
    expect(find.text('Stok 4'), findsOneWidget);
    expect(find.text('Board'), findsOneWidget);
    expect(find.text('Deskripsi Produk'), findsOneWidget);
    expect(find.text('Deskripsi mantap'), findsOneWidget);
    expect(find.text('Tambah ke Keranjang'), findsOneWidget);
  });

  testWidgets('tanpa diskon -> tanpa harga coret', (tester) async {
    await pump(
        tester,
        screen: ProductDetailScreen(
            product: buildProduct(price: 50000, originalPrice: 0)));
    expect(find.text('Rp50.000'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('stok habis -> badge merah + tombol mati', (tester) async {
    await pump(
        tester, screen: ProductDetailScreen(product: buildProduct(stock: 0)));
    expect(find.text('Stok Habis'), findsWidgets);
  });

  testWidgets('tanpa produk & tanpa id -> tidak ditemukan', (tester) async {
    await pump(tester, screen: const ProductDetailScreen());
    expect(find.text('Produk tidak ditemukan'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });

  testWidgets('via productId -> fetch repository', (tester) async {
    final repo = productRepoWith(buildProduct(id: 'x9', name: 'Dari Server'));
    await pump(tester,
        screen: const ProductDetailScreen(productId: 'x9'),
        productRepo: repo);
    await tester.pump();
    await tester.pump();
    verify(() => repo.getProductById('x9')).called(1);
    expect(find.text('Dari Server'), findsOneWidget);
  });

  testWidgets('via productId tidak ada -> tidak ditemukan', (tester) async {
    await pump(tester,
        screen: const ProductDetailScreen(productId: 'zz'),
        productRepo: productRepoWith(null));
    await tester.pump();
    await tester.pump();
    expect(find.text('Produk tidak ditemukan'), findsOneWidget);
  });

  testWidgets('kategori "0" disembunyikan', (tester) async {
    await pump(
        tester,
        screen: ProductDetailScreen(
            product: buildProduct(category: '0', stock: 1)));
    expect(find.text('0'), findsNothing);
  });

  testWidgets('galeri multi-image -> thumbnail tampil', (tester) async {
    await pump(
        tester,
        screen: ProductDetailScreen(
            product: buildProduct(
          imageUrl: 'https://x/a.png',
          imageList: ['https://x/a.png', 'https://x/b.png'],
        )));
    // 1 gambar utama + 2 thumbnail.
    expect(find.byType(Image), findsWidgets);
  });
}
