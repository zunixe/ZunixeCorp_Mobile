import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fakes.dart';
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

  MockProductRepository productRepoWith(List<Product> products,
      {Object? throws}) {
    final repo = MockProductRepository();
    when(() => repo.getCategories())
        .thenAnswer((_) async => const Result.ok([]));
    if (throws != null) {
      when(() => repo.getProducts(
            search: any(named: 'search'),
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer(
          (_) async => Result.err(ServerFailure(throws.toString())));
    } else {
      when(() => repo.getProducts(
            search: any(named: 'search'),
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => Result.ok(products));
    }
    return repo;
  }

  List<Product> defaultProducts() => [
        buildProduct(id: 'p1', name: 'Sensor', price: 50000, stock: 5),
        buildProduct(
            id: 'p2',
            name: 'Board',
            price: 75000,
            originalPrice: 100000,
            stock: 3),
      ];

  MockCartRepository defaultCartRepo() {
    final cr = MockCartRepository();
    when(() => cr.fetchCart(any()))
        .thenAnswer((_) async => const Result.ok([]));
    return cr;
  }

  Future<void> pump(
    WidgetTester tester, {
    MockAuthRepository? authRepo,
    MockCartRepository? cartRepo,
    MockProductRepository? productRepo,
  }) {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
              authRepo ?? mockAuthRepo()),
          cartRepositoryProvider.overrideWithValue(
              cartRepo ?? defaultCartRepo()),
          productRepositoryProvider.overrideWithValue(
              productRepo ?? productRepoWith(defaultProducts())),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
  }

  /// Bersihkan timer periodic HomeScreen agar tidak pending.
  Future<void> disposeHome(WidgetTester tester) {
    return tester.pumpWidget(Container());
  }

  testWidgets('promo banner + hero tampil', (tester) async {
    await pump(tester);
    await tester.pump();
    expect(find.text('Get our latest products!'), findsOneWidget);
    expect(find.text('Mitra Terpercaya Inovasi Elektronika Anda'),
        findsWidgets);
    await disposeHome(tester);
  });

  testWidgets('carousel banner + indikator tampil', (tester) async {
    await pump(tester);
    expect(find.byType(PageView), findsOneWidget);
    await disposeHome(tester);
  });

  testWidgets('featured ESP32 + tombol Lihat Produk', (tester) async {
    await pump(tester);
    expect(find.text('ESP32 Development Board'), findsOneWidget);
    expect(find.text('Lihat Produk'), findsOneWidget);
    await disposeHome(tester);
  });

  testWidgets('super promo + countdown tampil', (tester) async {
    await pump(tester);
    expect(find.text('Super Promo'), findsOneWidget);
    expect(find.text('Hari'), findsOneWidget);
    expect(find.text('Jam'), findsOneWidget);
    expect(find.text('Menit'), findsOneWidget);
    expect(find.text('Detik'), findsOneWidget);
    await disposeHome(tester);
  });

  group('promoCountdown (murni)', () {
    test('awal bulan -> sisa ~sebulan', () {
      final cd = promoCountdown(DateTime(2024, 5, 1, 0, 0, 0));
      // Mei punya 31 hari: 31*24*3600-1 detik tersisa.
      expect(cd.days, 30);
      expect(cd.hours, 23);
      expect(cd.minutes, 59);
      expect(cd.seconds, 59);
    });

    test('akhir bulan 1 detik sebelumnya', () {
      final cd = promoCountdown(DateTime(2024, 5, 31, 23, 59, 58));
      expect(cd.days, 0);
      expect(cd.hours, 0);
      expect(cd.minutes, 0);
      expect(cd.seconds, 1);
    });

    test('tepat di akhir -> nol', () {
      final cd = promoCountdown(DateTime(2024, 5, 31, 23, 59, 59));
      expect((cd.days, cd.hours, cd.minutes, cd.seconds), (0, 0, 0, 0));
    });

    test('Februari kabisat 2024', () {
      final cd = promoCountdown(DateTime(2024, 2, 1, 0, 0, 0));
      expect(cd.days, 28);
    });

    test('komponen konsisten dengan total detik', () {
      final now = DateTime(2024, 6, 15, 12, 30, 45);
      final cd = promoCountdown(now);
      final end = DateTime(2024, 7, 1).subtract(const Duration(seconds: 1));
      final total = end.difference(now).inSeconds;
      expect(
        cd.days * 86400 + cd.hours * 3600 + cd.minutes * 60 + cd.seconds,
        total,
      );
    });
  });

  testWidgets('section rekomendasi + produk terbaru tampil', (tester) async {
    await pump(tester);
    await tester.pump();
    await tester.pump();
    expect(find.text('Rekomendasi'), findsOneWidget);
    expect(find.text('Produk Terbaru'), findsOneWidget);
    expect(find.text('Sensor'), findsWidgets);
    await disposeHome(tester);
  });

  testWidgets('error katalog -> pesan + Coba Lagi', (tester) async {
    await pump(tester,
        productRepo: productRepoWith([], throws: Exception('net')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Exception: net'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    await disposeHome(tester);
  });

  testWidgets('katalog kosong -> Belum ada produk', (tester) async {
    await pump(tester, productRepo: productRepoWith([]));
    await tester.pump();
    await tester.pump();
    expect(find.text('Belum ada produk tersedia.'), findsOneWidget);
    expect(find.text('Rekomendasi'), findsNothing);
    await disposeHome(tester);
  });

  testWidgets('FAQ expand menampilkan konten', (tester) async {
    await pump(tester, productRepo: productRepoWith([]));
    await tester.pump();
    await tester.pump();
    expect(find.text('Tanya Kami'), findsOneWidget);
    await tester.tap(find.text('Cara Berbelanja'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.textContaining('Telusuri produk di katalog'), findsOneWidget);
    await disposeHome(tester);
  });

  testWidgets('footer + link legal navigasi', (tester) async {
    // Viewport tinggi agar footer terlihat.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final controller = StreamController<AuthState>.broadcast();
    await pumpRouter(
      tester,
      authRepo: mockAuthRepo(stream: controller.stream),
      cartRepo: defaultCartRepo(),
      productRepo: productRepoWith([]),
    );
    // Lewati AuthGate splash.
    controller.add(const AuthState(AuthChangeEvent.initialSession, null));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Powered By : CV Zunixe Berkah Jaya'), findsOneWidget);
    await tester.tap(find.text('Kebijakan Privasi'), warnIfMissed: false);
    await tester.pump();
    await tester.pump();
    expect(find.byType(LegalScreen), findsOneWidget);
    await controller.close();
  });

  testWidgets('drawer tamu -> logo + tagline', (tester) async {
    await pump(tester, productRepo: productRepoWith([]));
    await tester.pump();
    final ScaffoldState scaffold =
        tester.state(find.byType(Scaffold).first);
    scaffold.openDrawer();
    await tester.pump();
    await tester.pump();
    expect(find.text('Semua Produk'), findsOneWidget);
    expect(find.text('Tentang Kami'), findsOneWidget);
    expect(find.text('Keluar'), findsNothing);
    await disposeHome(tester);
  });

  testWidgets('drawer login -> nama + menu Keluar', (tester) async {
    await pump(
      tester,
      authRepo: mockAuthRepo(
          user: buildUser(
              email: 'budi@mail.com',
              userMetadata: {'full_name': 'Budi'})),
      productRepo: productRepoWith([]),
    );
    await tester.pump();
    final ScaffoldState scaffold =
        tester.state(find.byType(Scaffold).first);
    scaffold.openDrawer();
    await tester.pump();
    await tester.pump();
    expect(find.text('Budi'), findsWidgets);
    expect(find.text('Keluar'), findsOneWidget);
    await disposeHome(tester);
  });

  testWidgets('tap Keluar di drawer -> logout', (tester) async {
    final authRepo = mockAuthRepo(user: buildUser());
    when(() => authRepo.signOut()).thenAnswer((_) async {});
    await pump(tester,
        authRepo: authRepo, productRepo: productRepoWith([]));
    await tester.pump();
    final ScaffoldState scaffold =
        tester.state(find.byType(Scaffold).first);
    scaffold.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pump();
    verify(() => authRepo.signOut()).called(1);
    await disposeHome(tester);
  });
}
