import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

void main() {
  Future<void> pump(WidgetTester tester, MockAuthRepository repo) {
    return pumpRiverpod(
      tester,
      const AccountScreen(),
      authRepository: repo,
      routes: {
        AppRoutes.orders: (_) => const Scaffold(body: Text('Orders')),
        AppRoutes.cart: (_) => const Scaffold(body: Text('Cart')),
        AppRoutes.chat: (_) => const Scaffold(body: Text('Chat')),
        AppRoutes.about: (_) => const Scaffold(body: Text('About')),
      },
    );
  }

  testWidgets('belum login -> form login embedded', (tester) async {
    await pump(tester, mockAuthRepo());
    // LoginForm embedded: judul Masuk + tombol Google.
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('sudah login -> profil + menu tampil', (tester) async {
    await pump(
        tester,
        mockAuthRepo(
            user: buildUser(
                email: 'budi@mail.com',
                userMetadata: {'full_name': 'Budi'})));
    expect(find.text('Budi'), findsWidgets);
    expect(find.text('budi@mail.com'), findsOneWidget);
    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Chat Support'), findsOneWidget);
    expect(find.text('Tentang Kami'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets('tap Pesanan Saya -> navigasi /orders', (tester) async {
    final orderRepo = MockOrderRepository();
    when(() => orderRepo.getMyOrders(any()))
        .thenAnswer((_) async => const Result.ok([]));
    await pumpRouter(
      tester,
      authRepo: mockAuthRepo(user: buildUser()),
      orderRepo: orderRepo,
      initialLocation: AppRoutes.account,
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Pesanan Saya'));
    await tester.pump();
    await tester.pump();
    // Layar pesanan nyata tampil.
    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(find.text('Belum ada pesanan'), findsOneWidget);
  });

  testWidgets('logout -> dialog konfirmasi, Ya memanggil signOut',
      (tester) async {
    final repo = mockAuthRepo(user: buildUser());
    when(() => repo.signOut()).thenAnswer((_) async {});
    await pump(tester, repo);
    await tester.tap(find.text('Keluar'));
    await tester.pump();
    expect(find.text('Keluar akun?'), findsOneWidget);
    await tester.tap(find.text('Keluar').last);
    await tester.pump();
    await tester.pump();
    verify(() => repo.signOut()).called(1);
    // Setelah logout tampil form login.
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('logout Batal -> tetap login', (tester) async {
    final repo = mockAuthRepo(user: buildUser());
    await pump(tester, repo);
    await tester.tap(find.text('Keluar'));
    await tester.pump();
    await tester.tap(find.text('Batal'));
    await tester.pump();
    verifyNever(() => repo.signOut());
    expect(find.text('Pesanan Saya'), findsOneWidget);
  });
}
