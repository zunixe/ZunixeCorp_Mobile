import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';
import 'package:zunixe_corp_mobile/features/checkout/checkout.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  Future<void> pump(
    WidgetTester tester, {
    MockAuthRepository? authRepo,
    MockCartRepository? cartRepo,
    MockOrderRepository? orderRepo,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
              authRepo ?? mockAuthRepo(user: buildUser())),
          cartRepositoryProvider.overrideWithValue(
              cartRepo ?? MockCartRepository()),
          orderRepositoryProvider.overrideWithValue(
              orderRepo ?? MockOrderRepository()),
        ],
        child: const MaterialApp(home: CheckoutScreen()),
      ),
    );
  }

  MockCartRepository cartWith(List<CartItem> items) {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any()))
        .thenAnswer((_) async => Result.ok(items));
    return cr;
  }

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'No. WhatsApp'), '0812');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat Lengkap Pengiriman'),
        'Jl. Mawar 1');
  }

  testWidgets('ringkasan produk + total tampil', (tester) async {
    await pump(tester,
        cartRepo: cartWith([
          buildCartItem(
              productName: 'Sensor', price: 50000, quantity: 2),
        ]));
    await tester.pump();
    await tester.pump();
    expect(find.text('Produk (2)'), findsOneWidget);
    expect(find.text('Sensor x2'), findsOneWidget);
    expect(find.text('Ongkir'), findsOneWidget);
    expect(find.text('Rp 0 (GRATIS)'), findsOneWidget);
    expect(find.text('Rp100.000'), findsWidgets);
  });

  testWidgets('validasi: submit kosong -> error wajib isi', (tester) async {
    final orderRepo = MockOrderRepository();
    await pump(tester, cartRepo: cartWith([buildCartItem()]),
        orderRepo: orderRepo);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.textContaining('Buat Pesanan'));
    await tester.pump();
    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(find.text('Nomor wajib diisi'), findsOneWidget);
    expect(find.text('Alamat wajib diisi'), findsOneWidget);
    verifyNever(() => orderRepo.placeOrder(
          shippingAddress: any(named: 'shippingAddress'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          notes: any(named: 'notes'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ));
  });

  testWidgets('submit valid -> placeOrder + navigasi sukses', (tester) async {
    final orderRepo = MockOrderRepository();
    when(() => orderRepo.placeOrder(
          shippingAddress: any(named: 'shippingAddress'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          notes: any(named: 'notes'),
          idempotencyKey: any(named: 'idempotencyKey'),
        )).thenAnswer((_) async => const Result.ok(
        OrderConfirmation(orderCode: 'INV-55', total: 100000)));
    final cartRepo = cartWith([buildCartItem()]);
    await pumpRouter(
      tester,
      authRepo: mockAuthRepo(user: buildUser()),
      cartRepo: cartRepo,
      orderRepo: orderRepo,
      productRepo: stubEmptyProducts(),
      initialLocation: AppRoutes.checkout,
    );
    await tester.pump();
    await tester.pump();
    await fillValid(tester);
    await tester.tap(find.textContaining('Buat Pesanan'));
    await tester.pump();
    await tester.pump();
    verify(() => orderRepo.placeOrder(
          shippingAddress: 'Jl. Mawar 1',
          customerName: 'Budi',
          customerPhone: '0812',
          notes: null,
          idempotencyKey: any(named: 'idempotencyKey'),
        )).called(1);
    verify(() => cartRepo.fetchCart(any()))
        .called(greaterThanOrEqualTo(1));
    expect(find.text('INV-55'), findsOneWidget);
    expect(find.byType(OrderSuccessScreen), findsOneWidget);
  });

  testWidgets('submit gagal -> snackbar error', (tester) async {
    final orderRepo = MockOrderRepository();
    when(() => orderRepo.placeOrder(
          shippingAddress: any(named: 'shippingAddress'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          notes: any(named: 'notes'),
          idempotencyKey: any(named: 'idempotencyKey'),
        )).thenAnswer(
        (_) async => const Result.err(ServerFailure('Stok habis')));
    await pump(tester,
        cartRepo: cartWith([buildCartItem()]), orderRepo: orderRepo);
    await tester.pump();
    await tester.pump();
    await fillValid(tester);
    await tester.tap(find.textContaining('Buat Pesanan'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Stok habis'), findsOneWidget);
  });

  testWidgets('belum login -> cart dikosongkan + tombol disabled',
      (tester) async {
    final orderRepo = MockOrderRepository();
    await pump(tester,
        authRepo: mockAuthRepo(),
        cartRepo: cartWith([buildCartItem()]),
        orderRepo: orderRepo);
    await tester.pump();
    await tester.pump();
    // Tanpa sesi: keranjang dikosongkan sehingga submit tak bisa jalan
    // (route checkout sendiri dijaga RequireLogin di produksi).
    expect(find.text('Produk (0)'), findsOneWidget);
    final button = tester.widget<GradientButton>(
      find.widgetWithText(GradientButton, 'Buat Pesanan - Rp0'),
    );
    expect(button.onPressed, isNull);
    verifyNever(() => orderRepo.placeOrder(
          shippingAddress: any(named: 'shippingAddress'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          notes: any(named: 'notes'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ));
  });

  testWidgets('teks pembayaran tanpa bank', (tester) async {
    await pump(tester, cartRepo: cartWith([buildCartItem()]));
    await tester.pump();
    await tester.pump();
    // Teks berada di bawah fold -> cari dengan skipOffstage false.
    expect(
        find.textContaining('konfirmasi via WhatsApp 0877-7771-1056',
            skipOffstage: false),
        findsOneWidget);
  });
}
