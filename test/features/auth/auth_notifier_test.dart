import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

class FakeAuthRepository extends Fake implements AuthRepository {
  FakeAuthRepository({this.user});

  User? user;

  @override
  User? get currentUser => user;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();

  @override
  Future<({String fullName, String phone})?> getProfile(String userId) async =>
      null;

  @override
  Future<void> saveProfile({
    required String userId,
    required String fullName,
    required String phone,
  }) async {
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(UserAttributes());
  });

  ProviderContainer containerWith(AuthRepository repo) {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier state awal', () {
    test('tanpa user -> logged out', () {
      final container = containerWith(FakeAuthRepository());
      final state = container.read(authNotifierProvider);
      expect(state.isLoggedIn, isFalse);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
    });

    test('dengan currentUser -> AppUser terisi', () {
      final container = containerWith(
        FakeAuthRepository(user: buildUser(email: 'a@b.com')),
      );
      final state = container.read(authNotifierProvider);
      expect(state.isLoggedIn, isTrue);
      expect(state.user?.email, 'a@b.com');
      expect(state.user?.displayName, 'a');
    });
  });

  group('login', () {
    test('sukses', () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
          (_) async => AuthResponse(user: buildUser(email: 'x@y.com')));
      final container = containerWith(repo);
      final notifier = container.read(authNotifierProvider.notifier);

      expect(await notifier.login('x@y.com', 'pw'), isTrue);
      final state = container.read(authNotifierProvider);
      expect(state.user?.email, 'x@y.com');
      expect(state.lastMethod, 'password');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('gagal AuthApiException', () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthApiException('Salah'));
      final container = containerWith(repo);

      expect(
          await container
              .read(authNotifierProvider.notifier)
              .login('x@y.com', 'pw'),
          isFalse);
      expect(container.read(authNotifierProvider).error, 'Salah');
    });
  });

  group('register', () {
    test('needVerification', () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer(
          (_) async => AuthResponse(user: buildUser(), session: null));
      final container = containerWith(repo);

      expect(
          await container
              .read(authNotifierProvider.notifier)
              .register('a@b.com', 'pw', 'Nama'),
          RegisterResult.needVerification);
    });
  });

  group('logout', () {
    test('user dibersihkan', () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(buildUser());
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.signOut()).thenAnswer((_) async {});
      final container = containerWith(repo);
      expect(container.read(authNotifierProvider).isLoggedIn, isTrue);

      await container.read(authNotifierProvider.notifier).logout();

      expect(container.read(authNotifierProvider).isLoggedIn, isFalse);
      verify(() => repo.signOut()).called(1);
    });
  });

  group('stream event', () {
    test('signedIn memperbarui user', () async {
      final controller = StreamController<AuthState>.broadcast();
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => controller.stream);
      final container = containerWith(repo);
      // Daftarkan listener agar rebuild terpantau.
      final states = <AuthSessionState>[];
      container.listen(authNotifierProvider, (_, next) => states.add(next));

      controller.add(AuthState(
        AuthChangeEvent.signedIn,
        Session(
          accessToken: 't',
          tokenType: 'bearer',
          user: buildUser(email: 'oauth@mail.com'),
        ),
      ));
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authNotifierProvider).user?.email,
          'oauth@mail.com');
      await controller.close();
    });

    test('initialized selesai saat event pertama', () async {
      final controller = StreamController<AuthState>.broadcast();
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => controller.stream);
      final container = containerWith(repo);
      final notifier = container.read(authNotifierProvider.notifier);
      var done = false;
      notifier.initialized.then((_) => done = true);
      await Future<void>.delayed(Duration.zero);
      expect(done, isFalse);

      controller.add(const AuthState(AuthChangeEvent.initialSession, null));
      await Future<void>.delayed(Duration.zero);
      expect(done, isTrue);
      await controller.close();
    });
  });

  group('resetPassword + clearError', () {
    test('sukses true', () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.resetPasswordForEmail(any(),
          redirectTo: any(named: 'redirectTo'))).thenAnswer((_) async {});
      final container = containerWith(repo);

      expect(
          await container
              .read(authNotifierProvider.notifier)
              .resetPassword('a@b.com'),
          isTrue);
    });

    test('clearError menghapus error', () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthApiException('e'));
      final container = containerWith(repo);
      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login('a', 'b');
      expect(container.read(authNotifierProvider).error, isNotNull);
      notifier.clearError();
      expect(container.read(authNotifierProvider).error, isNull);
    });
  });
}
