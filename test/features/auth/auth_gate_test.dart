import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

void main() {
  group('Route guard (redirect router)', () {
    testWidgets('belum login -> /checkout dialihkan ke /login',
        (tester) async {
      await pumpRouter(
        tester,
        authRepo: mockAuthRepo(),
        initialLocation: AppRoutes.checkout,
      );
      await tester.pump();
      await tester.pump();
      // Layar login tampil, bukan checkout.
      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Data Penerima'), findsNothing);
    });

    testWidgets('belum login -> /orders dialihkan ke /login',
        (tester) async {
      await pumpRouter(
        tester,
        authRepo: mockAuthRepo(),
        initialLocation: AppRoutes.orders,
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Pesanan Saya'), findsNothing);
    });

    testWidgets('sudah login -> /orders tampil', (tester) async {
      final orderRepo = MockOrderRepository();
      when(() => orderRepo.getMyOrders(any()))
          .thenAnswer((_) async => const Result.ok([]));
      await pumpRouter(
        tester,
        authRepo: mockAuthRepo(user: buildUser()),
        orderRepo: orderRepo,
        initialLocation: AppRoutes.orders,
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Pesanan Saya'), findsOneWidget);
    });
  });

  group('AuthGate', () {
    Future<void> pumpGate(WidgetTester tester, MockAuthRepository repo) {
      return pumpRiverpod(
        tester,
        const AuthGate(
          child: Scaffold(body: Text('Aplikasi')),
        ),
        authRepository: repo,
      );
    }

    testWidgets('initialized selesai -> child tampil', (tester) async {
      final controller = StreamController<AuthState>.broadcast();
      final repo = mockAuthRepo(
          user: buildUser(), stream: controller.stream);
      await pumpGate(tester, repo);
      // Splash dulu karena event pertama belum tiba.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.add(const AuthState(AuthChangeEvent.initialSession, null));
      await tester.pump();
      await tester.pump();
      expect(find.text('Aplikasi'), findsOneWidget);
      await controller.close();
    });

    testWidgets('initialized belum selesai -> splash', (tester) async {
      await pumpGate(tester, mockAuthRepo(user: buildUser()));
      await tester.pump();
      expect(find.text('Aplikasi'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
