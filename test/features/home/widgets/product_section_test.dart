import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/home/home.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpSection(
    WidgetTester tester,
    ProductSection section,
  ) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) =>
              Scaffold(body: SingleChildScrollView(child: section)),
        ),
        GoRoute(
          path: AppRoutes.productsFull,
          builder: (_, __) => const Text('HALAMAN_PRODUK'),
        ),
        GoRoute(
          path: AppRoutes.productDetail,
          name: AppRouteNames.productDetail,
          builder: (_, state) => Text('DETAIL ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    return tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('daftar kosong -> tidak render apa pun', (tester) async {
    await pumpSection(
      tester,
      const ProductSection(title: 'Rekomendasi', products: []),
    );

    expect(find.text('Rekomendasi'), findsNothing);
    expect(find.text('Lihat Semua'), findsNothing);
  });

  testWidgets('judul + Lihat Semua + kartu produk tampil', (tester) async {
    await pumpSection(
      tester,
      ProductSection(
        title: 'Produk Terbaru',
        products: [
          buildProduct(id: 'p1', name: 'ESP32'),
          buildProduct(id: 'p2', name: 'Sensor'),
        ],
      ),
    );

    expect(find.text('Produk Terbaru'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);
    expect(find.text('ESP32'), findsOneWidget);
    expect(find.text('Sensor'), findsOneWidget);
  });

  testWidgets('tap Lihat Semua -> push productsFull', (tester) async {
    await pumpSection(
      tester,
      ProductSection(
        title: 'Rekomendasi',
        products: [buildProduct(id: 'p1')],
      ),
    );

    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN_PRODUK'), findsOneWidget);
  });

  testWidgets('tap kartu produk -> detail dengan id', (tester) async {
    await pumpSection(
      tester,
      ProductSection(
        title: 'Rekomendasi',
        products: [buildProduct(id: 'abc', name: 'Breadboard')],
      ),
    );

    await tester.tap(find.text('Breadboard'));
    await tester.pumpAndSettle();

    expect(find.text('DETAIL abc'), findsOneWidget);
  });
}
