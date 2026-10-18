import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/home/home.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/riverpod_scope.dart';

void main() {
  Future<ProviderContainer> pumpDrawer(
    WidgetTester tester,
    MockAuthRepository authRepo,
  ) async {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            drawer: HomeDrawer(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.productsFull,
          builder: (_, __) => const Text('HALAMAN_PRODUK'),
        ),
        GoRoute(
          path: AppRoutes.cart,
          builder: (_, __) => const Text('HALAMAN_KERANJANG'),
        ),
        GoRoute(
          path: AppRoutes.about,
          builder: (_, __) => const Text('HALAMAN_TENTANG'),
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
    return container;
  }

  Future<void> openDrawer(WidgetTester tester) async {
    final ScaffoldState scaffold = tester.state(find.byType(Scaffold).first);
    scaffold.openDrawer();
    await tester.pumpAndSettle();
  }

  testWidgets('tamu -> tagline + tanpa Keluar', (tester) async {
    await pumpDrawer(tester, mockAuthRepo());
    await openDrawer(tester);

    expect(find.text('zunixe'), findsOneWidget);
    expect(find.text('Mitra Terpercaya Inovasi Elektronika Anda'), findsOneWidget);
    expect(find.text('Keluar'), findsNothing);
  });

  testWidgets('login -> nama + email + Keluar', (tester) async {
    await pumpDrawer(
      tester,
      mockAuthRepo(
        user: buildUser(
          email: 'budi@mail.com',
          userMetadata: {'full_name': 'Budi'},
        ),
      ),
    );
    await openDrawer(tester);

    expect(find.text('Budi'), findsWidgets);
    expect(find.text('budi@mail.com'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets('tap Semua Produk -> push productsFull', (tester) async {
    await pumpDrawer(tester, mockAuthRepo());
    await openDrawer(tester);

    await tester.tap(find.text('Semua Produk'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN_PRODUK'), findsOneWidget);
  });

  testWidgets('tap Keranjang -> push cart', (tester) async {
    await pumpDrawer(tester, mockAuthRepo());
    await openDrawer(tester);

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN_KERANJANG'), findsOneWidget);
  });

  testWidgets('tap Tentang Kami -> push about', (tester) async {
    await pumpDrawer(tester, mockAuthRepo());
    await openDrawer(tester);

    await tester.tap(find.text('Tentang Kami'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN_TENTANG'), findsOneWidget);
  });

  testWidgets('tap Home -> drawer tertutup tanpa pindah', (tester) async {
    await pumpDrawer(tester, mockAuthRepo());
    await openDrawer(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Semua Produk'), findsNothing);
  });

  testWidgets('tap Keluar -> logout dipanggil', (tester) async {
    final repo = mockAuthRepo(user: buildUser());
    when(() => repo.signOut()).thenAnswer((_) async {});
    await pumpDrawer(tester, repo);
    await openDrawer(tester);

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    verify(() => repo.signOut()).called(1);
  });
}
