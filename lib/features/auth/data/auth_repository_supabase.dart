import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/domain/repositories/auth_repository.dart';

/// [AuthRepository] yang meneruskan ke GoTrue client Supabase.
///
/// Error TIDAK ditelan di sini — dibiarkan merambat agar pemanggil
/// (provider/notifier) memetakan pesannya sendiri seperti perilaku lama.
class AuthRepositorySupabase implements AuthRepository {
  /// [client] dapat di-inject untuk pengujian; default ke singleton global.
  AuthRepositorySupabase({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) =>
      _client.auth.signUp(email: email, password: password, data: data);

  @override
  Future<bool> signInWithOAuth({
    required OAuthProvider provider,
    String? redirectTo,
    Map<String, String>? queryParams,
  }) =>
      _client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectTo,
        queryParams: queryParams,
      );

  @override
  Future<UserResponse> updateUser(UserAttributes attributes) =>
      _client.auth.updateUser(attributes);

  @override
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) =>
      _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<({String fullName, String phone})?> getProfile(
      String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select('full_name, phone')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return (
        fullName: (row['full_name'] ?? '').toString(),
        phone: (row['phone'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile({
    required String userId,
    required String fullName,
    required String phone,
  }) async {
    try {
      await _client.from('profiles').update({
        'full_name': fullName,
        'phone': phone,
      }).eq('id', userId);
    } catch (_) {}
  }
}
