import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mock_supabase.dart';

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
          displayNameFor(buildUser(
              userMetadata: {'full_name': 'Budi Santoso'})),
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
}
