import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required MockCartRepository cartRepo,
    MockAuthRepository? authRepo,
    VoidCallback? onSwitchToProduk,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cartRepo),
          authRepositoryProvider.overrideWithValue(
              authRepo ?? mockAuthRepo(user: buildUser(id: 'u1'))),
        ],
        child: MaterialApp(
          home: CartScreen(
              onSwitchToProduk: onSwitchToProduk ?? () {}),
        ),
      ),
    );
  }

  MockCartRepository repoWithItems(List<CartItem> items) {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any()))
        .thenAnswer((_) async => Result.ok(items));
    when(() => cr.updateQuantity(any(), any()))
        .thenAnswer((_) async => const Result.ok(null));
    when(() => cr.removeItem(any()))
        .thenAnswer((_) async => const Result.ok(null));
    when(() => cr.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        )).thenAnswer((_) async => const Result.ok(null));
    return cr;
  }

  testWidgets('loading awal -> spinner', (tester) async {
    final gate = Completer<Result<List<CartItem>>>();
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any())).thenAnswer((_) => gate.future);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gate.complete(const Result.ok([]));
    await tester.pump();
  });

  testWidgets('error + kosong -> pesan + tombol Coba Lagi', (tester) async {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any())).thenAnswer(
      (_) async => const Result.err(ServerFailure('x')));
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    expect(find.text('Gagal memuat keranjang'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    verify(() => cr.fetchCart(any())).called(greaterThanOrEqualTo(2));
  });

  testWidgets('kosong -> empty state', (tester) async {
    var switched = false;
    final cr = repoWithItems([]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cr),
          authRepositoryProvider.overrideWithValue(
              mockAuthRepo(user: buildUser(id: 'u1'))),
        ],
        child: MaterialApp(
          home: CartScreen(onSwitchToProduk: () => switched = true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Keranjang Kosong'), findsOneWidget);
    await tester.tap(find.text('Lanjutkan berbelanja'));
    expect(switched, isTrue);
  });

  testWidgets('list item + total tampil', (tester) async {
    final cr = repoWithItems([
      buildCartItem(
          id: 'a', productName: 'Sensor', price: 25000, quantity: 2),
      buildCartItem(id: 'b', productName: 'Kabel', price: 10000, quantity: 1),
    ]);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    expect(find.text('Sensor'), findsOneWidget);
    expect(find.text('Kabel'), findsOneWidget);
    // Total 25000*2 + 10000 = 60000.
    expect(find.text('Rp60.000'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('tombol tambah memanggil updateQuantity', (tester) async {
    final cr = repoWithItems([
      buildCartItem(id: 'a', productName: 'Sensor', price: 1000, quantity: 1),
    ]);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();
    verify(() => cr.updateQuantity('a', 2)).called(1);
  });

  testWidgets('tombol kurang memanggil updateQuantity', (tester) async {
    final cr = repoWithItems([
      buildCartItem(id: 'a', productName: 'Sensor', price: 1000, quantity: 2),
    ]);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();
    verify(() => cr.updateQuantity('a', 1)).called(1);
  });

  testWidgets('qty >= stok -> tombol tambah disabled', (tester) async {
    final cr = repoWithItems([
      buildCartItem(
          id: 'a', productName: 'Limit', price: 1000, quantity: 3, stock: 3),
    ]);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    final btn = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add_circle_outline),
    );
    expect(btn.onPressed, isNull);
  });

  testWidgets('swipe hapus -> removeItem + snackbar urungkan', (tester) async {
    final cr = repoWithItems([
      buildCartItem(id: 'a', productName: 'Sensor', price: 1000, quantity: 1),
    ]);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    await tester.drag(find.text('Sensor'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    verify(() => cr.removeItem('a')).called(1);
    expect(find.textContaining('dihapus dari keranjang'), findsOneWidget);
    expect(find.text('Urungkan'), findsOneWidget);
  });

  testWidgets('tombol Checkout tampil saat ada item', (tester) async {
    final cr = repoWithItems([buildCartItem()]);
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    expect(find.text('Checkout'), findsOneWidget);
  });
}
