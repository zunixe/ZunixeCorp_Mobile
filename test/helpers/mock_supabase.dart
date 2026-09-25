import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock `SupabaseClient` dasar (dengan `.auth` yang juga mock).
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock `GoTrueClient` untuk mengontrol `currentUser` & `onAuthStateChange`.
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Pasang stub dasar pada [client] agar konstruktor provider yang menyentuh
/// `client.auth.currentUser` dan `client.auth.onAuthStateChange` tidak gagal.
/// Menerima mock `SupabaseClient` apa pun (termasuk MockSupabaseTestClient).
MockGoTrueClient stubSupabaseAuth(
  SupabaseClient client, {
  User? currentUser,
  Stream<AuthState>? authStream,
}) {
  final auth = MockGoTrueClient();
  when(() => client.auth).thenReturn(auth);
  when(() => auth.currentUser).thenReturn(currentUser);
  when(() => auth.onAuthStateChange)
      .thenAnswer((_) => authStream ?? const Stream<AuthState>.empty());
  return auth;
}
