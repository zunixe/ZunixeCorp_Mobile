import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

/// Layar password baru — dibuka dari event passwordRecovery
/// (user mengetuk link reset di email → deep link ke app).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final ok = await notifier.updatePassword(_passCtrl.text);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Password berhasil diubah. Silakan masuk.'),
            backgroundColor: AppColors.success),
      );
      await notifier.logout();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(authNotifierProvider).error;
      messenger.showSnackBar(
        SnackBar(
            content: Text(error ?? 'Gagal menyimpan password.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),
              const Text(
                'Password Baru',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                'Masukkan password baru untuk akun Anda',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password baru',
                  prefixIcon: const Icon(Icons.lock_outlined,
                      color: AppColors.brand, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.brand, width: 1.6),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password harus diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi password baru',
                  prefixIcon: const Icon(Icons.lock_outlined,
                      color: AppColors.brand, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.brand, width: 1.6),
                  ),
                ),
                validator: (v) =>
                    v != _passCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Simpan Password',
                height: 48,
                fontSize: 15.5,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
