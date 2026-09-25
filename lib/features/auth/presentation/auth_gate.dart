import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';

/// Gerbang startup: tampilkan splash sampai sesi auth pulih
/// (initialSession), agar tab Akun tak flash login→profil.
class AuthGate extends ConsumerWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialized = ref.watch(authInitializedProvider);
    return initialized.when(
      data: (_) => child,
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZunixeLogo(size: 72),
                SizedBox(height: 24),
                CircularProgressIndicator(color: AppColors.brand),
              ],
            ),
          ),
        ),
      ),
      error: (_, __) => child,
    );
  }
}
