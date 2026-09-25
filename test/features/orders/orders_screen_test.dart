import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  group('orderStatusLabel & orderStatusColor (murni)', () {
    test('label semua status', () {
      expect(orderStatusLabel('pending'), 'Menunggu');
      expect(orderStatusLabel('processing'), 'Diproses');
      expect(orderStatusLabel('shipped'), 'Dikirim');
      expect(orderStatusLabel('completed'), 'Selesai');
      expect(orderStatusLabel('cancelled'), 'Dibatalkan');
      expect(orderStatusLabel('aneh'), 'aneh');
    });

    test('warna valid untuk semua status', () {
      for (final s in [
        'pending',
        'processing',
        'shipped',
        'completed',
        'cancelled',
        'lain'
      ]) {
        expect(orderStatusColor(s), isA<Color>());
      }
    });

    test('cancelled merah, completed hijau', () {
      expect(orderStatusColor('cancelled'), Colors.red);
      expect(orderStatusColor('completed'), const Color(0xFF1BA303));
    });
  });

  group('OrdersScreen widget', () {
    Future<void> pump(
      WidgetTester tester, {
      MockAuthRepository? authRepo,
      required MockOrderRepository orderRepo,
    }) {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
                authRepo ?? mockAuthRepo(user: buildUser())),
            orderRepositoryProvider.overrideWithValue(orderRepo),
          ],
          child: const MaterialApp(home: OrdersScreen()),
        ),
      );
    }

    MockOrderRepository repoWith(List<Order> orders) {
      final repo = MockOrderRepository();
      when(() => repo.getMyOrders(any()))
          .thenAnswer((_) async => Result.ok(orders));
      when(() => repo.cancelOrder(any()))
          .thenAnswer((_) async => const Result.ok(null));
      return repo;
    }

    Order order({
      String id = 'o1',
      String code = 'INV-1',
      String status = 'pending',
      String payment = 'unpaid',
    }) =>
        Order(
          id: id,
          orderCode: code,
          status: status,
          paymentStatus: payment,
          total: 150000,
          createdAt: DateTime.parse('2024-05-01T10:30:00Z'),
          shippingAddress: 'Jl. Mawar 1',
          customerPhone: '0812',
          items: const [
            OrderItem(productName: 'Sensor', quantity: 2, price: 75000),
          ],
        );

    testWidgets('belum login -> ajakan login', (tester) async {
      await pump(tester,
          authRepo: mockAuthRepo(), orderRepo: MockOrderRepository());
      await tester.pump();
      expect(find.text('Login untuk melihat pesanan'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('loading -> spinner', (tester) async {
      await pump(tester, orderRepo: repoWith([]));
      // Frame pertama masih loading (fetch async belum selesai).
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
      await tester.pump();
    });

    testWidgets('error -> pesan + Coba Lagi', (tester) async {
      final repo = MockOrderRepository();
      when(() => repo.getMyOrders(any())).thenAnswer(
        (_) async => const Result.err(ServerFailure('net')));
      await pump(tester, orderRepo: repo);
      await tester.pump();
      await tester.pump();
      expect(find.text('Gagal memuat pesanan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('kosong -> Belum ada pesanan', (tester) async {
      await pump(tester, orderRepo: repoWith([]));
      await tester.pump();
      await tester.pump();
      expect(find.text('Belum ada pesanan'), findsOneWidget);
    });

    testWidgets('daftar order + status + total tampil', (tester) async {
      await pump(tester, orderRepo: repoWith([order()]));
      await tester.pump();
      await tester.pump();
      expect(find.text('INV-1'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.textContaining('Rp150.000'), findsOneWidget);
    });

    testWidgets('expand menampilkan item + tombol batal', (tester) async {
      await pump(tester, orderRepo: repoWith([order()]));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('INV-1'));
      await tester.pump();
      expect(find.text('Sensor x2'), findsOneWidget);
      expect(find.text('Batalkan Pesanan'), findsOneWidget);
    });

    testWidgets('order paid -> tanpa tombol batal & PaymentInfo',
        (tester) async {
      await pump(
          tester,
          orderRepo: repoWith(
              [order(status: 'completed', payment: 'paid')]));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('INV-1'));
      await tester.pump();
      expect(find.text('Batalkan Pesanan'), findsNothing);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('batalkan -> dialog konfirmasi + repository dipanggil',
        (tester) async {
      final repo = repoWith([order()]);
      await pump(tester, orderRepo: repo);
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('INV-1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batalkan Pesanan'));
      await tester.pumpAndSettle();
      expect(find.text('Batalkan pesanan?'), findsOneWidget);
      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pump();
      await tester.pump();
      verify(() => repo.cancelOrder('o1')).called(1);
      expect(find.text('Pesanan INV-1 dibatalkan.'), findsOneWidget);
    });
  });
}
