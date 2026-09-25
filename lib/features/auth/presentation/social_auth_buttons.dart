import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';

/// Tombol "Lanjutkan dengan Google / Facebook" (Supabase OAuth via browser).
/// Mandiri: mengatur state loading sendiri + snackbar saat gagal dibuka.
/// Sesi yang berhasil masuk via deep link ditangani layar induk
/// (LoginScreen / RegisterScreen lewat auth state).
class SocialAuthButtons extends ConsumerStatefulWidget {
  final String dividerLabel;

  const SocialAuthButtons({
    super.key,
    this.dividerLabel = 'atau masuk dengan',
  });

  @override
  ConsumerState<SocialAuthButtons> createState() =>
      _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends ConsumerState<SocialAuthButtons> {
  static const _timeout = Duration(seconds: 120);
  String? _pending; // 'google' | 'facebook' | null
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fail(String label, String msg) {
    if (!mounted) return;
    _timer?.cancel();
    setState(() => _pending = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Login $label gagal: $msg'),
          backgroundColor: Colors.red),
    );
  }

  void _cancel() {
    if (_pending == null) return;
    _timer?.cancel();
    setState(() => _pending = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Login dibatalkan.'),
          backgroundColor: AppColors.brand),
    );
  }

  Future<void> _go(
      Future<bool> Function() action, String key, String label) async {
    // Satu alur dalam satu waktu; tombol lain disabled saat pending.
    if (_pending != null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _pending = key);
    // Pengaman: browser ditutup tanpa hasil → reset otomatis.
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      if (!mounted || _pending != key) return;
      _fail(label, 'waktu habis. Silakan coba lagi.');
    });
    final launched = await action();
    if (!context.mounted) return;
    if (!launched) {
      _timer?.cancel();
      setState(() => _pending = null);
      final error = ref.read(authNotifierProvider).error;
      messenger.showSnackBar(
        SnackBar(
            content: Text(error ?? 'Login $label gagal'),
            backgroundColor: Colors.red),
      );
    }
    // launched=true → browser terbuka; sukses login datang via deep link.
  }

  @override
  Widget build(BuildContext context) {
    // Gagal tukar OAuth code (mis. email FB tak terbaca) datang sebagai
    // stream error → reset spinner + tampilkan pesan, jangan muter terus.
    ref.listen(authEventsProvider, (_, next) {
      next.whenData((_) {});
    }, onError: (Object e, _) {
      if (!mounted || _pending == null) return;
      _fail(_pending == 'google' ? 'Google' : 'Facebook',
          e is AuthException ? e.message : 'coba lagi.');
    });

    final notifier = ref.read(authNotifierProvider.notifier);
    final busy = _pending != null;
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.borderAlt)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(widget.dividerLabel,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
            const Expanded(child: Divider(color: AppColors.borderAlt)),
          ],
        ),
        const SizedBox(height: 16),
        _btn(
          label: 'Lanjutkan dengan Google',
          iconAsset: 'assets/google_icon.png',
          border: AppColors.borderInput,
          busy: _pending == 'google',
          onTap: busy
              ? null
              : () => _go(notifier.signInWithGoogle, 'google', 'Google'),
        ),
        const SizedBox(height: 12),
        _btn(
          label: 'Lanjutkan dengan Facebook',
          iconAsset: 'assets/facebook_icon.png',
          backgroundColor: AppColors.facebook,
          foreground: Colors.white,
          busy: _pending == 'facebook',
          onTap: busy
              ? null
              : () =>
                  _go(notifier.signInWithFacebook, 'facebook', 'Facebook'),
        ),
        if (busy)
          TextButton(
            onPressed: _cancel,
            child: const Text('Batalkan',
                style: TextStyle(color: AppColors.brand, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _btn({
    required String label,
    required String iconAsset,
    required VoidCallback? onTap,
    required bool busy,
    Color? backgroundColor,
    Color foreground = AppColors.ink,
    Color? border,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.brand))
            : Image.asset(iconAsset, width: 22, height: 22),
        label: Text(label,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: foreground)),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: foreground,
          side: BorderSide(color: border ?? Colors.transparent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
