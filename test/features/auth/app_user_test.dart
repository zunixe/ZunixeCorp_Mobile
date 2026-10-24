import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';

import '../../helpers/fakes.dart';

void main() {
  group('AppUser.fromSupabase', () {
    test('memetakan id, email, dan displayName', () {
      final user = AppUser.fromSupabase(buildUser(
        id: 'u9',
        email: 'budi@mail.com',
        userMetadata: {'full_name': 'Budi Santoso'},
      ));

      expect(user.id, 'u9');
      expect(user.email, 'budi@mail.com');
      expect(user.displayName, 'Budi Santoso');
    });

    test('fallback displayName dari prefix email', () {
      final user = AppUser.fromSupabase(
          buildUser(email: 'zunixe@mail.com', userMetadata: const {}));

      expect(user.displayName, 'zunixe');
    });

    test('email null -> displayName User', () {
      final user =
          AppUser.fromSupabase(buildUser(email: null, userMetadata: const {}));

      expect(user.email, isNull);
      expect(user.displayName, 'User');
    });
  });

  group('AppUser equality', () {
    test('nilai sama -> equal + hashCode sama', () {
      const a = AppUser(id: 'u1', email: 'a@b.com', displayName: 'A');
      const b = AppUser(id: 'u1', email: 'a@b.com', displayName: 'A');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('displayName beda -> tidak equal', () {
      const a = AppUser(id: 'u1', email: 'a@b.com', displayName: 'A');
      const b = AppUser(id: 'u1', email: 'a@b.com', displayName: 'B');

      expect(a, isNot(equals(b)));
    });

    test('id beda -> tidak equal', () {
      const a = AppUser(id: 'u1', email: 'a@b.com', displayName: 'A');
      const b = AppUser(id: 'u2', email: 'a@b.com', displayName: 'A');

      expect(a, isNot(equals(b)));
    });

    test('objek identik -> equal', () {
      const a = AppUser(id: 'u1', displayName: 'A');
      expect(a == a, isTrue);
    });
  });
}
