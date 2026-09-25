import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

/// Form login lengkap (email + Google + Facebook).
/// Dipakai di dua tempat dengan perilaku sukses yang berbeda:
/// - [embedded]=false (LoginScreen mandiri, di-push): sukses → pop.
/// - [embedded]=true (tab Akun): sukses → diam (AccountScreen rebuild
///   otomatis via watch AuthProvider); link Daftar → push biasa.
class LoginForm extends ConsumerStatefulWidget {
  final bool embedded;

  const LoginForm({super.key, this.embedded = false});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, IconData icon, Widget? suffix) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.brand, size: 20),
      suffixIcon: suffix,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
      ),
    );
  }

  Future<void> _submit() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (ref.read(authNotifierProvider).isLoading) return;
    final ok =
        await notifier.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!context.mounted) return;
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: AppColors.success),
      );
      if (!widget.embedded) navigator.pop();
    } else {
      final error = ref.read(authNotifierProvider).error;
      messenger.showSnackBar(
        SnackBar(
            content: Text(error ?? 'Login gagal'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl =
        TextEditingController(text: _emailCtrl.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lupa password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email akun',
            hintText: 'contoh@email.com',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.brand)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                ctx, emailCtrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim Link'),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
    if (email == null || email.isEmpty || !mounted) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await notifier.resetPassword(email);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Link reset terkirim ke $email. Cek inbox/spam.'
            : (ref.read(authNotifierProvider).error ??
                'Gagal mengirim email reset.')),
        backgroundColor:
            ok ? AppColors.success : Colors.red,
      ),
    );
  }

  void _goRegister() {
    if (widget.embedded) {
      context.push(AppRoutes.register);
    } else {
      // pushReplacement: context tetap valid (tanpa pop dulu).
      context.pushReplacement(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.isLoading),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ZunixeLogo(size: 48),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'zunixe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brand,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Zunixe Electronics',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Masuk',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.ink),
        ),
        const SizedBox(height: 4),
        Text(
          'Masuk ke akun Zunixe Anda',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _deco('Email', Icons.email_outlined, null),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: _deco(
            'Password',
            Icons.lock_outlined,
            IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 2),
              minimumSize: const Size(0, 30),
            ),
            onPressed: () => _forgotPassword(),
            child: const Text('Lupa password?',
                style: TextStyle(color: AppColors.brand, fontSize: 12.5)),
          ),
        ),
        const SizedBox(height: 10),
        GradientButton(
          label: 'Masuk',
          height: 48,
          fontSize: 15.5,
          loading: isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 24),
        const SocialAuthButtons(
            dividerLabel: 'atau masuk dengan'),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Belum punya akun? ',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            GestureDetector(
              onTap: _goRegister,
              child: const Text('Daftar',
                  style: TextStyle(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
