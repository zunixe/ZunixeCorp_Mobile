import 'dart:async';

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

  /// Repo dengan OAuth yang menggantung (future tak selesai).
  MockAuthRepository hangingRepo({
    Completer<bool>? completer,
    StreamController<AuthState>? events,
  }) {
    final repo = mockAuthRepo(stream: events?.stream);
    when(() => repo.signInWithOAuth(
          provider: any(named: 'provider'),
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).thenAnswer((_) => (completer ?? Completer<bool>()).future);
    return repo;
  }

  Future<void> pump(WidgetTester tester, MockAuthRepository repo) {
    return pumpRiverpod(
      tester,
      const Scaffold(body: SocialAuthButtons(dividerLabel: 'atau')),
      authRepository: repo,
    );
  }

  testWidgets('pending -> spinner + tombol Batalkan muncul', (tester) async {
    final repo = hangingRepo();
    await pump(tester, repo);

    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Batalkan'), findsOneWidget);
  });

  testWidgets('tap Batalkan -> snackbar + pending reset', (tester) async {
    final repo = hangingRepo();
    await pump(tester, repo);

    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    await tester.tap(find.text('Batalkan'));
    await tester.pump();

    expect(find.text('Login dibatalkan.'), findsOneWidget);
    expect(find.text('Batalkan'), findsNothing);
  });

  testWidgets('pending -> tombol lain nonaktif, hanya Google dipanggil',
      (tester) async {
    final repo = hangingRepo();
    await pump(tester, repo);

    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    await tester.tap(find.text('Lanjutkan dengan Facebook'));
    await tester.pump();

    verifyNever(() => repo.signInWithOAuth(
          provider: OAuthProvider.facebook,
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        ));
  });

  testWidgets('timeout 120s -> snackbar waktu habis', (tester) async {
    final repo = hangingRepo();
    await pump(tester, repo);

    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 121));

    expect(find.textContaining('waktu habis'), findsOneWidget);
    expect(find.text('Batalkan'), findsNothing);
  });

  testWidgets('stream error saat pending -> snackbar pesan error',
      (tester) async {
    final events = StreamController<AuthState>.broadcast();
    addTearDown(events.close);
    final repo = hangingRepo(events: events);
    await pump(tester, repo);

    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    await tester.pump();

    events.addError(const AuthException('Email Facebook tidak terbaca'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(
      find.text('Login Google gagal: Email Facebook tidak terbaca'),
      findsOneWidget,
    );
    expect(find.text('Batalkan'), findsNothing);
  });
}
