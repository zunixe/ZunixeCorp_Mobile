import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(OAuthProvider.google);
  });

  Future<void> pump(WidgetTester tester, MockAuthRepository repo,
      {String dividerLabel = 'atau masuk dengan'}) {
    return pumpRiverpod(
      tester,
      Scaffold(body: SocialAuthButtons(dividerLabel: dividerLabel)),
      authRepository: repo,
    );
  }

  testWidgets('dua tombol + divider tampil', (tester) async {
    await pump(tester, mockAuthRepo());
    expect(find.text('atau masuk dengan'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Facebook'), findsOneWidget);
  });

  testWidgets('tap Google -> signInWithOAuth google dipanggil',
      (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signInWithOAuth(
          provider: any(named: 'provider'),
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).thenAnswer((_) async => true);
    await pump(tester, repo);
    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    verify(() => repo.signInWithOAuth(
          provider: OAuthProvider.google,
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).called(1);
  });

  testWidgets('tap Facebook -> signInWithOAuth facebook dipanggil',
      (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signInWithOAuth(
          provider: any(named: 'provider'),
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).thenAnswer((_) async => true);
    await pump(tester, repo);
    await tester.tap(find.text('Lanjutkan dengan Facebook'));
    await tester.pump();
    verify(() => repo.signInWithOAuth(
          provider: OAuthProvider.facebook,
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).called(1);
  });

  testWidgets('OAuth gagal dibuka -> snackbar error', (tester) async {
    final repo = mockAuthRepo();
    when(() => repo.signInWithOAuth(
          provider: any(named: 'provider'),
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).thenAnswer((_) async => false);
    await pump(tester, repo);
    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Login Google gagal. Tidak dapat membuka browser.'),
        findsOneWidget);
  });

  testWidgets('dividerLabel kustom', (tester) async {
    await pump(tester, mockAuthRepo(),
        dividerLabel: 'atau daftar dengan');
    expect(find.text('atau daftar dengan'), findsOneWidget);
  });
}
