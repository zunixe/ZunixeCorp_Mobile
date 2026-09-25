import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    MockCartRepository? cartRepo,
    MockAuthRepository? authRepo,
    int stock = 5,
    bool compact = false,
    bool expand = false,
    String label = 'Beli',
    Map<String, WidgetBuilder>? routes,
  }) {
    final cr = cartRepo ?? MockCartRepository();
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cr),
          authRepositoryProvider.overrideWithValue(
              authRepo ?? mockAuthRepo()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: AddToCartButton(
              product: buildProduct(stock: stock),
              compact: compact,
              expand: expand,
              label: label,
            ),
          ),
          routes: routes ?? const {},
        ),
      ),
    );
  }

  MockCartRepository successRepo() {
    final cr = MockCartRepository();
    when(() => cr.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        )).thenAnswer((_) async => const Result.ok(null));
    when(() => cr.fetchCart(any()))
        .thenAnswer((_) async => const Result.ok([]));
    return cr;
  }

  MockAuthRepository loggedIn() =>
      mockAuthRepo(user: buildUser(id: 'u1'));

  testWidgets('stok habis -> tombol mati Stok Habis', (tester) async {
    final cr = MockCartRepository();
    await pump(tester, cartRepo: cr, stock: 0);
    expect(find.text('Stok Habis'), findsOneWidget);
    await tester.tap(find.text('Stok Habis'));
    await tester.pump();
    verifyNever(() => cr.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        ));
  });

  testWidgets('label default + ikon tampil', (tester) async {
    await pump(tester);
    expect(find.text('Beli'), findsOneWidget);
    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
  });

  testWidgets('tap sukses -> addToCart dipanggil + snackbar', (tester) async {
    final cr = successRepo();
    await pump(tester, cartRepo: cr, authRepo: loggedIn());
    await tester.tap(find.text('Beli'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    verify(() => cr.addToCart(productId: 'p1', quantity: 1)).called(1);
    expect(find.text('Berhasil Ditambahkan'), findsOneWidget);
    expect(find.textContaining('masuk keranjang'), findsOneWidget);
    // Biarkan timer reset 1300ms selesai agar tidak pending.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Beli'), findsOneWidget);
  });

  testWidgets('gagal + needsLogin -> dialog Belum Login', (tester) async {
    await pump(tester); // logged out -> needsLogin
    await tester.tap(find.text('Beli'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Belum Login'), findsOneWidget);
    expect(
        find.text('Login dulu yuk biar bisa menambah produk ke keranjang.'),
        findsOneWidget);
  });

  testWidgets('dialog pilih Nanti -> dialog tertutup', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Beli'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Nanti'));
    await tester.pump();
    expect(find.text('Belum Login'), findsNothing);
  });

  testWidgets('dialog pilih Login -> navigasi /login', (tester) async {
    final container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(MockCartRepository()),
        authRepositoryProvider.overrideWithValue(mockAuthRepo()),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: AddToCartButton(product: buildProduct()),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) =>
              const Scaffold(body: Text('Halaman Login')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('Beli'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Halaman Login'), findsOneWidget);
  });

  testWidgets('gagal tanpa needsLogin -> snackbar error', (tester) async {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any()))
        .thenAnswer((_) async => const Result.ok([]));
    when(() => cr.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        )).thenAnswer(
        (_) async => const Result.err(ServerFailure('Stok habis')));
    await pump(tester, cartRepo: cr, authRepo: loggedIn());
    await tester.tap(find.text('Beli'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Stok habis'), findsOneWidget);
  });

  testWidgets('compact sukses -> teks OK', (tester) async {
    await pump(tester,
        cartRepo: successRepo(), authRepo: loggedIn(), compact: true);
    await tester.tap(find.text('Beli'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('OK'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('compact + expand -> full width', (tester) async {
    await pump(tester, compact: true, expand: true);
    expect(find.text('Beli'), findsOneWidget);
  });
}
