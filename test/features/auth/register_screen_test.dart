import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  Future<void> pump(
    WidgetTester tester,
    MockAuthRepository repo,
  ) {
    // Viewport tinggi agar tombol Daftar terlihat.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    return pumpRouter(
      tester,
      authRepo: repo,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
      initialLocation: AppRoutes.register,
    );
  }

  MockAuthRepository baseRepo() {
    final repo = mockAuthRepo();
    when(() => repo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        )).thenAnswer(
        (_) async => AuthResponse(user: buildUser(), session: null));
    return repo;
  }

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'budi@mail.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret1');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi Password'), 'secret1');
  }

  testWidgets('judul + semua field tampil', (tester) async {
    await pump(tester, mockAuthRepo());
    expect(find.text('Daftar'), findsWidgets);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Nomor WhatsApp (opsional)'), findsOneWidget);
    expect(find.widgetWithText(GradientButton, 'Daftar'), findsOneWidget);
  });

  testWidgets('validasi: nama kosong', (tester) async {
    final repo = baseRepo();
    await pump(tester, repo);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret1');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi Password'), 'secret1');
    await tester.tap(find.widgetWithText(GradientButton, 'Daftar'));
    await tester.pump();
    expect(find.text('Nama harus diisi'), findsOneWidget);
    verifyNever(() => repo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ));
  });

  testWidgets('validasi: email tak valid', (tester) async {
    await pump(tester, mockAuthRepo());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'bukan-email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret1');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi Password'), 'secret1');
    await tester.tap(find.widgetWithText(GradientButton, 'Daftar'));
    await tester.pump();
    expect(find.text('Email tidak valid'), findsOneWidget);
  });

  testWidgets('validasi: password < 6', (tester) async {
    await pump(tester, mockAuthRepo());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), '123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi Password'), '123');
    await tester.tap(find.widgetWithText(GradientButton, 'Daftar'));
    await tester.pump();
    expect(find.text('Minimal 6 karakter'), findsOneWidget);
  });

  testWidgets('validasi: konfirmasi beda', (tester) async {
    await pump(tester, mockAuthRepo());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret1');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi Password'), 'beda999');
    await tester.tap(find.widgetWithText(GradientButton, 'Daftar'));
    await tester.pump();
    expect(find.text('Password tidak cocok'), findsOneWidget);
  });

  testWidgets('needVerification -> snackbar + ke /login', (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        )).thenAnswer(
        (_) async => AuthResponse(user: buildUser(), session: null));
    await pump(tester, repo);
    await fillValid(tester);
    await tester.tap(find.widgetWithText(GradientButton, 'Daftar'));
    await tester.pump();
    await tester.pump();
    expect(
        find.text('Pendaftaran berhasil! Cek email untuk verifikasi.'),
        findsOneWidget);
    // Layar login nyata (bukan stub) tampil setelah pushReplacement.
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('failed -> snackbar merah', (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        )).thenThrow(const AuthApiException('Email sudah dipakai'));
    await pump(tester, repo);
    await fillValid(tester);
    await tester.tap(find.widgetWithText(GradientButton, 'Daftar'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Email sudah dipakai'), findsOneWidget);
  });
}
