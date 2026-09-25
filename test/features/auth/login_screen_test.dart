import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(OAuthProvider.google);
    registerFallbackValue(ProductSort.newest);
  });

  testWidgets('render form login', (tester) async {
    await pumpRiverpod(tester, const LoginScreen(),
        authRepository: mockAuthRepo());
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('OAuth login -> snackbar sukses', (tester) async {
    final controller = StreamController<AuthState>.broadcast();
    final repo = mockAuthRepo(stream: controller.stream);
    when(() => repo.signInWithOAuth(
          provider: any(named: 'provider'),
          redirectTo: any(named: 'redirectTo'),
          queryParams: any(named: 'queryParams'),
        )).thenAnswer((_) async => true);
    await pumpRouter(
      tester,
      authRepo: repo,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
      initialLocation: AppRoutes.login,
    );
    // Simulasi tap Google: lastMethod oauth + browser terbuka.
    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump();
    // Deep link kembali: event signedIn dengan sesi.
    controller.add(AuthState(
      AuthChangeEvent.signedIn,
      Session(
        accessToken: 't',
        tokenType: 'bearer',
        user: buildUser(email: 'oauth@mail.com'),
      ),
    ));
    await tester.pump();
    await tester.pump();
    expect(find.text('Login berhasil!'), findsOneWidget);
    await controller.close();
  });

  testWidgets('event password-login diabaikan (tanpa double-pop)',
      (tester) async {
    final controller = StreamController<AuthState>.broadcast();
    final repo = mockAuthRepo(stream: controller.stream);
    when(() => repo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer(
        (_) async => AuthResponse(user: buildUser(email: 'a@b.com')));
    await pumpRiverpod(tester, const LoginScreen(), authRepository: repo);
    // Login email via form: lastMethod password.
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'secret');
    await tester.tap(find.widgetWithText(GradientButton, 'Masuk'));
    await tester.pump();
    await tester.pump();
    // Snackbar form muncul sekali; listener OAuth tidak menambah lagi.
    expect(find.text('Login berhasil!'), findsOneWidget);
    await controller.close();
  });
}
