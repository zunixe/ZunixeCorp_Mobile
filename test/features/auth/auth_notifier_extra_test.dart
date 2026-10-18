import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(UserAttributes());
    registerFallbackValue(OAuthProvider.google);
  });

  ProviderContainer containerWith(AuthRepository repo) {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  MockAuthRepository baseRepo() {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    when(() => repo.onAuthStateChange)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    return repo;
  }

  group('login — jaringan gagal', () {
    test('exception umum -> pesan koneksi', () async {
      final repo = baseRepo();
      when(() => repo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('boom'));
      final container = containerWith(repo);

      final ok = await container
          .read(authNotifierProvider.notifier)
          .login('a@b.com', 'pw');

      expect(ok, isFalse);
      expect(container.read(authNotifierProvider).error,
          'Login gagal. Periksa koneksi.');
    });
  });

  group('register — jalur lain', () {
    test('session ada -> loggedIn', () async {
      final repo = baseRepo();
      when(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => AuthResponse(
            user: buildUser(),
            session: Session(
              accessToken: 't',
              tokenType: 'bearer',
              user: buildUser(),
            ),
          ));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .register('a@b.com', 'pw', 'Nama'),
        RegisterResult.loggedIn,
      );
    });

    test('AuthApiException -> failed + pesan', () async {
      final repo = baseRepo();
      when(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenThrow(const AuthApiException('Email sudah dipakai'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .register('a@b.com', 'pw', 'Nama'),
        RegisterResult.failed,
      );
      expect(container.read(authNotifierProvider).error,
          'Email sudah dipakai');
    });

    test('exception umum -> pesan koneksi', () async {
      final repo = baseRepo();
      when(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenThrow(Exception('boom'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .register('a@b.com', 'pw', 'Nama'),
        RegisterResult.failed,
      );
      expect(container.read(authNotifierProvider).error,
          'Pendaftaran gagal. Periksa koneksi.');
    });

    test('phone diteruskan ke metadata signUp', () async {
      final repo = baseRepo();
      when(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer(
          (_) async => AuthResponse(user: buildUser(), session: null));
      final container = containerWith(repo);

      await container
          .read(authNotifierProvider.notifier)
          .register('a@b.com', 'pw', 'Nama', phone: '0812');

      final captured = verify(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: captureAny(named: 'data'),
          )).captured.single as Map;
      expect(captured['full_name'], 'Nama');
      expect(captured['phone'], '0812');
    });
  });

  group('OAuth', () {
    test('signInWithGoogle sukses -> launched + lastMethod oauth:google',
        () async {
      final repo = baseRepo();
      when(() => repo.signInWithOAuth(
            provider: any(named: 'provider'),
            redirectTo: any(named: 'redirectTo'),
            queryParams: any(named: 'queryParams'),
          )).thenAnswer((_) async => true);
      final container = containerWith(repo);

      final ok = await container
          .read(authNotifierProvider.notifier)
          .signInWithGoogle();

      expect(ok, isTrue);
      expect(container.read(authNotifierProvider).lastMethod, 'oauth:google');
      expect(container.read(authNotifierProvider).error, isNull);
    });

    test('signInWithFacebook launched=false -> pesan browser', () async {
      final repo = baseRepo();
      when(() => repo.signInWithOAuth(
            provider: any(named: 'provider'),
            redirectTo: any(named: 'redirectTo'),
            queryParams: any(named: 'queryParams'),
          )).thenAnswer((_) async => false);
      final container = containerWith(repo);

      final ok = await container
          .read(authNotifierProvider.notifier)
          .signInWithFacebook();

      expect(ok, isFalse);
      expect(container.read(authNotifierProvider).lastMethod,
          'oauth:facebook');
      expect(container.read(authNotifierProvider).error,
          'Login Facebook gagal. Tidak dapat membuka browser.');
    });

    test('AuthException -> pesan dari server', () async {
      final repo = baseRepo();
      when(() => repo.signInWithOAuth(
            provider: any(named: 'provider'),
            redirectTo: any(named: 'redirectTo'),
            queryParams: any(named: 'queryParams'),
          )).thenThrow(const AuthException('provider dimatikan'));
      final container = containerWith(repo);

      final ok = await container
          .read(authNotifierProvider.notifier)
          .signInWithGoogle();

      expect(ok, isFalse);
      expect(container.read(authNotifierProvider).error, 'provider dimatikan');
    });

    test('exception umum -> pesan koneksi', () async {
      final repo = baseRepo();
      when(() => repo.signInWithOAuth(
            provider: any(named: 'provider'),
            redirectTo: any(named: 'redirectTo'),
            queryParams: any(named: 'queryParams'),
          )).thenThrow(Exception('boom'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .signInWithGoogle(),
        isFalse,
      );
      expect(container.read(authNotifierProvider).error,
          'Login Google gagal. Periksa koneksi.');
    });
  });

  group('resetPassword — gagal', () {
    test('AuthException -> pesan + false', () async {
      final repo = baseRepo();
      when(() => repo.resetPasswordForEmail(any(),
              redirectTo: any(named: 'redirectTo')))
          .thenThrow(const AuthException('email tidak valid'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .resetPassword('bad'),
        isFalse,
      );
      expect(container.read(authNotifierProvider).error, 'email tidak valid');
    });

    test('exception umum -> pesan koneksi', () async {
      final repo = baseRepo();
      when(() => repo.resetPasswordForEmail(any(),
              redirectTo: any(named: 'redirectTo')))
          .thenThrow(Exception('boom'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .resetPassword('a@b.com'),
        isFalse,
      );
      expect(container.read(authNotifierProvider).error,
          'Gagal mengirim email reset. Periksa koneksi.');
    });
  });

  group('updatePassword', () {
    test('sukses -> true + user diperbarui', () async {
      final repo = baseRepo();
      when(() => repo.updateUser(any())).thenAnswer((_) async =>
          UserResponse.fromJson(<String, dynamic>{
            'id': 'u1',
            'email': 'baru@mail.com',
            'aud': 'authenticated',
            'created_at': '2024-01-01T00:00:00Z',
            'user_metadata': {'full_name': 'Baru'},
          }));
      final container = containerWith(repo);

      final ok = await container
          .read(authNotifierProvider.notifier)
          .updatePassword('rahasia');

      expect(ok, isTrue);
      expect(container.read(authNotifierProvider).user?.displayName, 'Baru');
    });

    test('AuthException -> false + pesan', () async {
      final repo = baseRepo();
      when(() => repo.updateUser(any()))
          .thenThrow(const AuthException('password terlalu pendek'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .updatePassword('x'),
        isFalse,
      );
      expect(container.read(authNotifierProvider).error,
          'password terlalu pendek');
    });

    test('exception umum -> pesan koneksi', () async {
      final repo = baseRepo();
      when(() => repo.updateUser(any())).thenThrow(Exception('boom'));
      final container = containerWith(repo);

      expect(
        await container
            .read(authNotifierProvider.notifier)
            .updatePassword('x'),
        isFalse,
      );
      expect(container.read(authNotifierProvider).error,
          'Gagal menyimpan password. Periksa koneksi.');
    });
  });

  group('stream event — signedOut', () {
    test('user dibersihkan saat event signedOut', () async {
      final controller = StreamController<AuthState>.broadcast();
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(buildUser());
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => controller.stream);
      final container = containerWith(repo);
      container.listen(authNotifierProvider, (_, __) {});
      expect(container.read(authNotifierProvider).isLoggedIn, isTrue);

      controller.add(const AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authNotifierProvider).isLoggedIn, isFalse);
      await controller.close();
    });
  });
}