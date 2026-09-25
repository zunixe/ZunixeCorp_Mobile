import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fake_http.dart';
import '../../helpers/riverpod_scope.dart';
import 'package:zunixe_corp_mobile/features/home/home.dart';

void main() {
  HttpOverrides? previous;

  setUp(() {
    previous = HttpOverrides.current;
    HttpOverrides.global = FakeHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = previous;
  });

  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  Future<void> pump(
    WidgetTester tester, {
    MockAuthRepository? authRepo,
    MockCartRepository? cartRepo,
    MockProductRepository? productRepo,
  }) {
    final pr = productRepo ?? MockProductRepository();
    when(() => pr.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).thenAnswer((_) async => const Result.ok([]));
    when(() => pr.getCategories())
        .thenAnswer((_) async => const Result.ok([]));
    final cr = cartRepo ??
        (() {
          final c = MockCartRepository();
          when(() => c.fetchCart(any()))
              .thenAnswer((_) async => const Result.ok([]));
          return c;
        })();
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
              authRepo ?? mockAuthRepo()),
          cartRepositoryProvider.overrideWithValue(cr),
          productRepositoryProvider.overrideWithValue(pr),
        ],
        child: const MaterialApp(home: MainShell()),
      ),
    );
  }

  /// Pump via router nyata (untuk aksi yang memicu navigasi).
  Future<ProviderContainer> pumpWithRouter(
    WidgetTester tester, {
    MockAuthRepository? authRepo,
    MockCartRepository? cartRepo,
    MockProductRepository? productRepo,
  }) {
    final pr = productRepo ?? MockProductRepository();
    when(() => pr.getProducts(
          search: any(named: 'search'),
          category: any(named: 'category'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        )).thenAnswer((_) async => const Result.ok([]));
    when(() => pr.getCategories())
        .thenAnswer((_) async => const Result.ok([]));
    final cr = cartRepo ??
        (() {
          final c = MockCartRepository();
          when(() => c.fetchCart(any()))
              .thenAnswer((_) async => const Result.ok([]));
          return c;
        })();
    return pumpRouter(
      tester,
      authRepo: authRepo,
      cartRepo: cr,
      productRepo: pr,
    );
  }

  MockCartRepository cartWithItems() {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any())).thenAnswer(
      (_) async => Result.ok([
        buildCartItem(quantity: 2),
        buildCartItem(id: 'b', quantity: 1),
      ]),
    );
    return cr;
  }

  testWidgets('5 tab tampil', (tester) async {
    await pump(tester);
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Produk'), findsWidgets);
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
  });

  testWidgets('pindah tab Produk', (tester) async {
    await pump(tester);
    await tester.pump();
    await tester.tap(find.text('Produk').first);
    await tester.pump();
    await tester.pump();
    // Tab produk (ProductsScreen) tampil.
    expect(find.text('Semua'), findsOneWidget);
  });

  testWidgets('badge cart tampil saat ada item', (tester) async {
    await pump(tester,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
        cartRepo: cartWithItems());
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // Badge di bottom nav + badge angka di AppHeader home.
    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('tanpa item -> tanpa badge', (tester) async {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any()))
        .thenAnswer((_) async => const Result.ok([]));
    await pump(tester, cartRepo: cr);
    await tester.pump();
    await tester.pump();
    expect(find.byType(Badge), findsNothing);
  });

  testWidgets('event passwordRecovery -> buka ResetPasswordScreen',
      (tester) async {
    final controller = StreamController<AuthState>.broadcast();
    await pumpWithRouter(tester,
        authRepo: mockAuthRepo(
            user: buildUser(), stream: controller.stream));
    await tester.pump();
    // Event pertama melewatkan AuthGate (MainShell subscribe setelahnya,
    // seperti alur produksi: sesi pulih dulu, link diklik kemudian).
    controller.add(const AuthState(AuthChangeEvent.initialSession, null));
    await tester.pump();
    await tester.pump();
    controller.add(AuthState(
      AuthChangeEvent.passwordRecovery,
      Session(
        accessToken: 't',
        tokenType: 'bearer',
        user: buildUser(),
      ),
    ));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    await controller.close();
  });
}
