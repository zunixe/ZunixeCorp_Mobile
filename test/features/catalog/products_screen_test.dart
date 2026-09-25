import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  List<Product> defaultProducts() => [
        buildProduct(id: 'p1', name: 'Sensor', price: 50000, stock: 5),
        buildProduct(
            id: 'p2',
            name: 'Board',
            price: 75000,
            originalPrice: 100000,
            stock: 3),
      ];

  MockProductRepository repoWith({
    List<Product>? products,
    List<String> categories = const [],
  }) {
    final repo = MockProductRepository();
    final all = products ?? defaultProducts();
    when(() => repo.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).thenAnswer((inv) async {
      final offset = inv.namedArguments[#offset] as int;
      final limit = inv.namedArguments[#limit] as int;
      if (offset >= all.length) return const Result.ok([]);
      final end = (offset + limit).clamp(0, all.length);
      return Result.ok(all.sublist(offset, end));
    });
    when(() => repo.getCategories())
        .thenAnswer((_) async => Result.ok(categories));
    return repo;
  }

  Future<void> pump(
    WidgetTester tester,
    MockProductRepository repo, {
    bool isTab = true,
  }) {
    // ProviderScope di atas MaterialApp agar route hasil navigasi
    // (detail produk) tetap dapat mengakses providers.
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
          cartRepositoryProvider.overrideWithValue(MockCartRepository()),
          authRepositoryProvider.overrideWithValue(mockAuthRepo()),
        ],
        child: MaterialApp(
          home: ProductsScreen(isTab: isTab),
        ),
      ),
    );
  }

  testWidgets('loading awal -> spinner', (tester) async {
    await pump(tester, repoWith());
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('produk tampil sebagai grid', (tester) async {
    await pump(tester, repoWith());
    await tester.pump();
    await tester.pump();
    expect(find.text('Sensor'), findsOneWidget);
    expect(find.text('Board'), findsOneWidget);
  });

  testWidgets('error -> pesan + Coba Lagi + retry', (tester) async {
    final repo = MockProductRepository();
    when(() => repo.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).thenAnswer(
        (_) async => const Result.err(ServerFailure('net')));
    when(() => repo.getCategories())
        .thenAnswer((_) async => const Result.ok([]));
    await pump(tester, repo);
    await tester.pump();
    await tester.pump();
    expect(find.text('net'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    verify(() => repo.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).called(greaterThanOrEqualTo(2));
  });

  testWidgets('kosong -> Tidak ada produk ditemukan', (tester) async {
    await pump(tester, repoWith(products: []));
    await tester.pump();
    await tester.pump();
    expect(find.text('Tidak ada produk ditemukan'), findsOneWidget);
  });

  testWidgets('dropdown sort memicu reload', (tester) async {
    final repo = repoWith();
    await pump(tester, repo);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Terbaru'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Termurah').last);
    await tester.pump();
    await tester.pump();
    verify(() => repo.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: ProductSort.cheapest,
        )).called(greaterThanOrEqualTo(1));
  });

  testWidgets('chip kategori memicu reload dengan kategori', (tester) async {
    final repo = repoWith(categories: ['Elektronik', 'Aksesoris']);
    await pump(tester, repo);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Aksesoris'));
    await tester.pump();
    await tester.pump();
    verify(() => repo.getProducts(
          search: any(named: 'search'),
          category: 'Aksesoris',
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).called(greaterThanOrEqualTo(1));
  });

  testWidgets('dialog cari -> set search + reload', (tester) async {
    final repo = repoWith();
    await pump(tester, repo);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.text('Cari Produk'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Ketik nama produk...'), 'board');
    await tester.tap(find.text('Cari'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Hasil: "board"'), findsOneWidget);
    verify(() => repo.getProducts(
          search: 'board',
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).called(greaterThanOrEqualTo(1));
  });

  testWidgets('tap produk -> navigasi detail', (tester) async {
    await pumpRouter(
      tester,
      authRepo: mockAuthRepo(),
      cartRepo: stubEmptyCart(),
      productRepo: repoWith(
          products: [buildProduct(id: 'p9', name: 'Unik', stock: 2)]),
      initialLocation: AppRoutes.productsFull,
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Unik'));
    await tester.pump();
    await tester.pump();
    // Halaman detail menampilkan nama produk.
    expect(find.text('Detail Produk'), findsOneWidget);
  });
}
