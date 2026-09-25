import 'package:supabase_flutter/supabase_flutter.dart';

/// Kontrak operasi auth. Satu-satunya seam ke GoTrue.
///
/// Sengaja memakai tipe Supabase (`User`, `AuthResponse`, ...) agar adapter
/// [AuthProvider] lama tetap kompatibel selama strangler. Pemutusan total
/// (entity `AppUser`) dilakukan saat migrasi Riverpod (Fase 3).
/// Implementasi: Supabase (`data/`), fake (test).
abstract class AuthRepository {
  User? get currentUser;
  Stream<AuthState> get onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  /// Mengembalikan `true` bila browser OAuth berhasil dibuka.
  Future<bool> signInWithOAuth({
    required OAuthProvider provider,
    String? redirectTo,
    Map<String, String>? queryParams,
  });

  Future<UserResponse> updateUser(UserAttributes attributes);

  Future<void> resetPasswordForEmail(String email, {String? redirectTo});

  Future<void> signOut();

  /// Profil publik (nama + telepon) untuk prefill checkout.
  /// Mengembalikan `null` bila belum ada.
  Future<({String fullName, String phone})?> getProfile(String userId);

  /// Simpan profil (best-effort; error ditelan pemanggil).
  Future<void> saveProfile({
    required String userId,
    required String fullName,
    required String phone,
  });
}
