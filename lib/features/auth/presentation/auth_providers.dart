import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/network/supabase_client_provider.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import '../auth.dart';

/// Repository auth untuk graph Riverpod. Override di test dengan
/// mock/fake [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositorySupabase(
    client: ref.watch(supabaseClientProvider),
  ),
  name: 'authRepositoryProvider',
);

/// State sesi auth untuk UI.
class AuthSessionState {
  const AuthSessionState({
    this.user,
    this.isLoading = false,
    this.error,
    this.lastMethod,
  });

  final AppUser? user;
  final bool isLoading;
  final String? error;

  /// Metode login terakhir: 'password' | 'oauth:google' | 'oauth:facebook'.
  final String? lastMethod;

  bool get isLoggedIn => user != null;

  String get displayName => user?.displayName ?? 'User';

  AuthSessionState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    String? lastMethod,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthSessionState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastMethod: lastMethod ?? this.lastMethod,
    );
  }
}

/// Pengganti Riverpod untuk `AuthProvider` (ChangeNotifier).
///
/// API disamakan agar migrasi UI mekanis: `login`, `register`,
/// `signInWithGoogle/Facebook`, `logout`, `resetPassword`,
/// `updatePassword`, `clearError`, `initialized`.
class AuthNotifier extends Notifier<AuthSessionState> {
  StreamSubscription<AuthState>? _sub;
  final Completer<void> _ready = Completer<void>();

  /// Selesai saat event auth pertama tiba (splash gate anti-flash).
  Future<void> get initialized => _ready.future;

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthSessionState build() {
    final current = _repo.currentUser;
    _sub?.cancel();
    _sub = _repo.onAuthStateChange.listen(
      (data) {
        // Paritas AuthProvider lama: user selalu mengikuti sesi terakhir.
        final user = data.session?.user;
        state = state.copyWith(
          user: user == null ? null : AppUser.fromSupabase(user),
          clearUser: user == null,
        );
        if (!_ready.isCompleted) _ready.complete();
      },
      // Error OAuth ditampilkan SocialAuthButtons; cegah unhandled.
      onError: (_) {},
    );
    ref.onDispose(() => _sub?.cancel());

    return AuthSessionState(
      user: current == null ? null : AppUser.fromSupabase(current),
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(
        isLoading: true, clearError: true, lastMethod: 'password');
    try {
      final res = await _repo.signInWithPassword(
          email: email, password: password);
      final user =
          res.user == null ? null : AppUser.fromSupabase(res.user!);
      state = state.copyWith(user: user);
      return true;
    } on AuthApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(error: 'Login gagal. Periksa koneksi.');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<RegisterResult> register(
    String email,
    String password,
    String fullName, {
    String? phone,
  }) async {
    state = state.copyWith(
        isLoading: true, clearError: true, lastMethod: 'password');
    try {
      final res = await _repo.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, if (phone != null) 'phone': phone},
      );
      final user =
          res.user == null ? null : AppUser.fromSupabase(res.user!);
      state = state.copyWith(user: user);
      if (res.session == null) return RegisterResult.needVerification;
      return RegisterResult.loggedIn;
    } on AuthApiException catch (e) {
      state = state.copyWith(error: e.message);
      return RegisterResult.failed;
    } catch (_) {
      state = state.copyWith(error: 'Pendaftaran gagal. Periksa koneksi.');
      return RegisterResult.failed;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  static const _oauthRedirect = AppRoutes.oauthCallbackScheme;

  Future<bool> signInWithGoogle() =>
      _signInWithProvider(OAuthProvider.google, 'Google');
  Future<bool> signInWithFacebook() =>
      _signInWithProvider(OAuthProvider.facebook, 'Facebook');

  Future<bool> _signInWithProvider(
      OAuthProvider provider, String label) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      lastMethod: 'oauth:${provider.name}',
    );
    try {
      final launched = await _repo.signInWithOAuth(
        provider: provider,
        redirectTo: _oauthRedirect,
        queryParams: provider == OAuthProvider.google
            ? const {'prompt': 'select_account'}
            : null,
      );
      if (!launched) {
        state = state.copyWith(
            error: 'Login $label gagal. Tidak dapat membuka browser.');
      }
      return launched;
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(error: 'Login $label gagal. Periksa koneksi.');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = state.copyWith(clearUser: true);
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(clearError: true);
    try {
      await _repo.resetPasswordForEmail(email, redirectTo: _oauthRedirect);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
          error: 'Gagal mengirim email reset. Periksa koneksi.');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    state = state.copyWith(clearError: true);
    try {
      final res =
          await _repo.updateUser(UserAttributes(password: newPassword));
      final user =
          res.user == null ? null : AppUser.fromSupabase(res.user!);
      state = state.copyWith(user: user);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
          error: 'Gagal menyimpan password. Periksa koneksi.');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthSessionState>(
  AuthNotifier.new,
  name: 'authNotifierProvider',
);

/// Gate splash: selesai saat event auth pertama tiba.
final authInitializedProvider = FutureProvider<void>(
  (ref) => ref.watch(authNotifierProvider.notifier).initialized,
  name: 'authInitializedProvider',
);

/// Stream mentah event auth (untuk OAuth error, password-recovery, ...).
/// UI mendengarkan via `ref.listen(authEventsProvider, ...)`.
final authEventsProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).onAuthStateChange,
  name: 'authEventsProvider',
);
