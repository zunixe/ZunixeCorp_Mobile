import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mock_supabase.dart';
import '../../helpers/supabase_test_client.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(UserAttributes());
    registerFallbackValue(OAuthProvider.google);
  });

  group('displayNameFor (murni)', () {
    test('full_name metadata', () {
      expect(
          displayNameFor(
              buildUser(userMetadata: {'full_name': 'Budi Santoso'})),
          'Budi Santoso');
    });

    test('fallback name metadata', () {
      expect(displayNameFor(buildUser(userMetadata: {'name': 'Ani'})), 'Ani');
    });

    test('fallback prefix email', () {
      expect(displayNameFor(buildUser(email: 'zunixe@mail.com')), 'zunixe');
    });

    test('null -> User', () {
      expect(displayNameFor(null), 'User');
    });

    test('whitespace diabaikan', () {
      expect(
          displayNameFor(buildUser(
              email: 'abc@mail.com', userMetadata: {'full_name': '   '})),
          'abc');
    });
  });

  group('AuthRepositorySupabase (passthrough)', () {
    test('currentUser + stream dari client', () async {
      final client = MockSupabaseClient();
      final user = buildUser();
      stubSupabaseAuth(client, currentUser: user);
      final repo = AuthRepositorySupabase(client: client);

      expect(repo.currentUser, same(user));
      await expectLater(repo.onAuthStateChange, emitsDone);
    });

    test('signInWithPassword terus ke client', () async {
      final client = MockSupabaseClient();
      final auth = stubSupabaseAuth(client);
      when(() => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(user: buildUser()));
      final repo = AuthRepositorySupabase(client: client);

      final res =
          await repo.signInWithPassword(email: 'a@b.com', password: 'pw');

      expect(res.user?.id, 'u1');
    });

    test('signOut terus ke client', () async {
      final client = MockSupabaseClient();
      final auth = stubSupabaseAuth(client);
      when(() => auth.signOut()).thenAnswer((_) async {});
      final repo = AuthRepositorySupabase(client: client);

      await repo.signOut();

      verify(() => auth.signOut()).called(1);
    });
  });

  group('AuthRepositorySupabase (delegasi lanjutan)', () {
    test('signUp terus ke client', () async {
      final client = MockSupabaseClient();
      final auth = stubSupabaseAuth(client);
      when(() => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => AuthResponse(user: buildUser()));
      final repo = AuthRepositorySupabase(client: client);

      final res = await repo
          .signUp(email: 'a@b.com', password: 'pw', data: {'full_name': 'A'});

      expect(res.user?.id, 'u1');
    });

    test('updateUser terus ke client', () async {
      final client = MockSupabaseClient();
      final auth = stubSupabaseAuth(client);
      when(() => auth.updateUser(any())).thenAnswer(
        (_) async => UserResponse.fromJson(<String, dynamic>{
          'id': 'u1',
          'aud': 'authenticated',
          'created_at': '2024-01-01T00:00:00Z',
        }),
      );
      final repo = AuthRepositorySupabase(client: client);

      final res = await repo.updateUser(UserAttributes(password: 'baru'));

      expect(res.user?.id, 'u1');
    });

    test('resetPasswordForEmail terus ke client', () async {
      final client = MockSupabaseClient();
      final auth = stubSupabaseAuth(client);
      when(() => auth.resetPasswordForEmail(any(),
          redirectTo: any(named: 'redirectTo'))).thenAnswer((_) async {});
      final repo = AuthRepositorySupabase(client: client);

      await repo.resetPasswordForEmail('a@b.com', redirectTo: 'zunixe://x');

      verify(() =>
              auth.resetPasswordForEmail('a@b.com', redirectTo: 'zunixe://x'))
          .called(1);
    });
  });

  group('AuthRepositorySupabase.getProfile', () {
    test('row ada -> record fullName/phone', () async {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      client.stubFrom('profiles',
          returning: <String, dynamic>{'full_name': 'Budi', 'phone': '0812'});
      final repo = AuthRepositorySupabase(client: client);

      final p = await repo.getProfile('u1');

      expect(p?.fullName, 'Budi');
      expect(p?.phone, '0812');
    });

    test('row null -> null', () async {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      client.stubFrom('profiles', returning: null);
      final repo = AuthRepositorySupabase(client: client);

      expect(await repo.getProfile('u1'), isNull);
    });

    test('field kosong -> string kosong', () async {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      client.stubFrom('profiles',
          returning: <String, dynamic>{'full_name': null, 'phone': null});
      final repo = AuthRepositorySupabase(client: client);

      final p = await repo.getProfile('u1');

      expect(p?.fullName, '');
      expect(p?.phone, '');
    });

    test('error diteruskan ke pemanggil (tidak ditelan)', () async {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      client.stubFrom('profiles', throws: Exception('net'));
      final repo = AuthRepositorySupabase(client: client);

      await expectLater(repo.getProfile('u1'), throwsA(isA<Exception>()));
    });
  });

  group('AuthRepositorySupabase.saveProfile', () {
    test('ok -> update dipanggil', () async {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      client.stubFrom('profiles', returning: <Map<String, dynamic>>[]);
      final repo = AuthRepositorySupabase(client: client);

      await repo.saveProfile(userId: 'u1', fullName: 'Budi', phone: '0812');

      final qb = client.queryBuilders['profiles']!.first;
      expect(qb.wasCalled('update'), isTrue);
    });

    test('error diteruskan ke pemanggil', () async {
      final client = MockSupabaseTestClient();
      stubSupabaseAuth(client);
      client.stubFrom('profiles', throws: Exception('net'));
      final repo = AuthRepositorySupabase(client: client);

      await expectLater(
        repo.saveProfile(userId: 'u1', fullName: 'B', phone: '0'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
