import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

/// Halaman login mandiri (di-push dari Orders / Checkout / tombol lain).
/// OAuth Google/Facebook kembali via deep link → tutup otomatis ke MainShell.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // OAuth signedIn (bukan password) → snackbar + tutup ke MainShell.
    // Email-login ditangani LoginForm (pop sekali) → lewati agar tak double-pop.
    // Hanya saat transisi logout→login agar tak bereaksi pada build awal.
    ref.listen(authNotifierProvider, (prev, next) {
      if (!mounted) return;
      final wasOut = prev?.user == null;
      if (wasOut &&
          next.user != null &&
          next.lastMethod != 'password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login berhasil!'),
              backgroundColor: AppColors.success),
        );
        context.go(AppRoutes.home);
      }
    });
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LoginForm(embedded: false),
      ),
    );
  }
}

/// Helper transisi: event auth mentah bila dibutuhkan (mis. test).
@visibleForTesting
bool shouldHandleOAuthSignIn(AuthChangeEvent event, bool hasSession) =>
    event == AuthChangeEvent.signedIn && hasSession;
