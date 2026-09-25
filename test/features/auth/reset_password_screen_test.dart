import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';

import '../../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(UserAttributes());
    registerFallbackValue(ProductSort.newest);
  });

  Future<void> pump(WidgetTester tester, MockAuthRepository repo) {
    return pumpRiverpod(
      tester,
      const ResetPasswordScreen(),
      authRepository: repo,
    );
  }

  Future<void> fillMatching(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password baru'), 'baru123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi password baru'),
        'baru123');
  }

  testWidgets('judul + field tampil', (tester) async {
    await pump(tester, mockAuthRepo());
    expect(find.text('Password Baru'), findsOneWidget);
    expect(find.text('Password baru'), findsOneWidget);
    expect(find.text('Konfirmasi password baru'), findsOneWidget);
    expect(find.widgetWithText(GradientButton, 'Simpan Password'),
        findsOneWidget);
  });

  testWidgets('validasi: kosong -> error', (tester) async {
    final repo = mockAuthRepo();
    await pump(tester, repo);
    await tester.tap(find.widgetWithText(GradientButton, 'Simpan Password'));
    await tester.pump();
    expect(find.text('Password harus diisi'), findsOneWidget);
    verifyNever(() => repo.updateUser(any()));
  });

  testWidgets('validasi: < 6 karakter', (tester) async {
    await pump(tester, mockAuthRepo());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password baru'), '123');
    await tester.tap(find.widgetWithText(GradientButton, 'Simpan Password'));
    await tester.pump();
    expect(find.text('Minimal 6 karakter'), findsOneWidget);
  });

  testWidgets('konfirmasi beda -> error', (tester) async {
    await pump(tester, mockAuthRepo());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password baru'), '123456');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi password baru'),
        '654321');
    await tester.tap(find.widgetWithText(GradientButton, 'Simpan Password'));
    await tester.pump();
    expect(find.text('Password tidak cocok'), findsOneWidget);
  });

  testWidgets('sukses -> snackbar + logout + pulang', (tester) async {
    // Stream broadcast agar didengar router-refresh + notifier; pancarkan
    // initialSession agar AuthGate di home lolos.
    final controller = StreamController<AuthState>.broadcast();
    final repo = mockAuthRepo(stream: controller.stream);
    when(() => repo.updateUser(any())).thenAnswer(
      (_) async => UserResponse.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'aud': 'authenticated',
        'created_at': '2024-01-01T00:00:00Z',
        'app_metadata': <String, dynamic>{},
      }),
    );
    when(() => repo.signOut()).thenAnswer((_) async {});
    await pumpRouter(
      tester,
      authRepo: repo,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
      initialLocation: AppRoutes.resetPassword,
    );
    await fillMatching(tester);
    await tester.tap(find.widgetWithText(GradientButton, 'Simpan Password'));
    await tester.pump();
    await tester.pump();
    verify(() => repo.updateUser(any())).called(1);
    expect(find.text('Password berhasil diubah. Silakan masuk.'),
        findsOneWidget);
    verify(() => repo.signOut()).called(1);
    // Kembali ke home (MainShell) setelah sukses.
    controller.add(const AuthState(AuthChangeEvent.initialSession, null));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Get our latest products!'), findsOneWidget);
    await controller.close();
  });

  testWidgets('gagal -> snackbar merah', (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.updateUser(any()))
        .thenThrow(const AuthException('Token kedaluwarsa'));
    await pump(tester, repo);
    await fillMatching(tester);
    await tester.tap(find.widgetWithText(GradientButton, 'Simpan Password'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Token kedaluwarsa'), findsOneWidget);
  });
}
