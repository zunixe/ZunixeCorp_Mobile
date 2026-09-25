import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    MockAuthRepository repo, {
    bool embedded = false,
  }) {
    return pumpRiverpod(
      tester,
      Scaffold(body: LoginForm(embedded: embedded)),
      authRepository: repo,
    );
  }

  testWidgets('field email + password + tombol Masuk tampil', (tester) async {
    await pump(tester, mockAuthRepo());
    expect(find.widgetWithText(GradientButton, 'Masuk'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Lupa password?'), findsOneWidget);
  });

  testWidgets('toggle visibilitas password', (tester) async {
    await pump(tester, mockAuthRepo());
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('login sukses -> snackbar hijau', (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer(
        (_) async => AuthResponse(user: buildUser(email: 'a@b.com')));
    await pump(tester, repo);
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'secret');
    await tester.tap(find.widgetWithText(GradientButton, 'Masuk'));
    await tester.pump();
    await tester.pump();
    verify(() => repo.signInWithPassword(
        email: 'a@b.com', password: 'secret')).called(1);
    expect(find.text('Login berhasil!'), findsOneWidget);
  });

  testWidgets('login gagal -> snackbar merah', (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const AuthApiException('Kredensial salah'));
    await pump(tester, repo);
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'salah');
    await tester.tap(find.widgetWithText(GradientButton, 'Masuk'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Kredensial salah'), findsOneWidget);
  });

  testWidgets('dialog lupa password tampil', (tester) async {
    await pump(tester, mockAuthRepo());
    await tester.tap(find.text('Lupa password?'));
    await tester.pump();
    expect(find.text('Lupa password'), findsOneWidget);
    expect(find.text('Kirim Link'), findsOneWidget);
  });

  testWidgets('dialog lupa password kirim -> resetPassword dipanggil',
      (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.resetPasswordForEmail(any(),
        redirectTo: any(named: 'redirectTo'))).thenAnswer((_) async {});
    await pump(tester, repo);
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'reset@mail.com');
    await tester.tap(find.text('Lupa password?'));
    await tester.pump();
    await tester.tap(find.text('Kirim Link'));
    await tester.pump();
    await tester.pump();
    verify(() => repo.resetPasswordForEmail('reset@mail.com',
        redirectTo: any(named: 'redirectTo'))).called(1);
    expect(
        find.text(
            'Link reset terkirim ke reset@mail.com. Cek inbox/spam.'),
        findsOneWidget);
  });

  testWidgets('link Daftar tampil', (tester) async {
    await pump(tester, mockAuthRepo());
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Belum punya akun? '), findsOneWidget);
  });
}
