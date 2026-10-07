import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../helpers/fakes.dart';
import '../helpers/riverpod_scope.dart';

/// Regresi: tombol back di AppHeader harus benar-benar menutup halaman
/// yang dibuka via `push` (go_router). Sebelumnya `Navigator.maybePop`
/// tidak pop di router go_router → tombol back tak berfungsi (Xiaomi).
void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  MockProductRepository productRepo() {
    final repo = MockProductRepository();
    when(() => repo.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).thenAnswer((_) async => Result.ok([
          buildProduct(id: 'p1', name: 'Sensor', price: 50000, stock: 5),
        ]));
    when(() => repo.getCategories())
        .thenAnswer((_) async => const Result.ok([]));
    when(() => repo.getProductById(any()))
        .thenAnswer((_) async => const Result.ok(null));
    return repo;
  }

  testWidgets('back dari detail produk kembali ke daftar', (tester) async {
    final h = await pumpRouter(
      tester,
      authRepo: mockAuthRepo(),
      cartRepo: stubEmptyCart(),
      productRepo: productRepo(),
      initialLocation: AppRoutes.productsFull,
    );
    await tester.pump();
    await tester.pump();

    h.router.pushNamed(
      AppRouteNames.productDetail,
      pathParameters: {'id': 'p1'},
      extra: buildProduct(id: 'p1', name: 'Produk Uji'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Detail Produk'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Detail Produk'), findsNothing);
    expect(find.text('Sensor'), findsOneWidget);
  });

  testWidgets('back dari halaman legal kembali ke sebelumnya',
      (tester) async {
    final h = await pumpRouter(
      tester,
      authRepo: mockAuthRepo(),
      cartRepo: stubEmptyCart(),
      productRepo: productRepo(),
      initialLocation: AppRoutes.productsFull,
    );
    await tester.pump();
    await tester.pump();

    h.router.pushNamed(
      AppRouteNames.legal,
      pathParameters: {'slug': 'tos'},
    );
    await tester.pumpAndSettle();
    expect(find.text('Persyaratan Layanan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Persyaratan Layanan'), findsNothing);
  });

  testWidgets('back dari checkout kembali ke keranjang', (tester) async {
    final h = await pumpRouter(
      tester,
      authRepo: mockAuthRepo(user: buildUser()),
      cartRepo: stubEmptyCart(),
      productRepo: productRepo(),
      orderRepo: MockOrderRepository(),
      initialLocation: AppRoutes.cart,
    );
    await tester.pump();
    await tester.pump();

    h.router.push(AppRoutes.checkout);
    await tester.pumpAndSettle();
    expect(find.text('Checkout'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Checkout'), findsNothing);
  });
}
