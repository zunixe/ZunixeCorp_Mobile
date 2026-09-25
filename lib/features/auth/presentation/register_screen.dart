import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final result = await notifier.register(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    switch (result) {
      case RegisterResult.loggedIn:
        // Confirm OFF: sesi langsung ada → ke MainShell.
        messenger.showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Selamat datang.'), backgroundColor: AppColors.success),
        );
        context.go(AppRoutes.home);
      case RegisterResult.needVerification:
        // Confirm ON: jangan pop — arahkan ke login untuk verifikasi.
        messenger.showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Cek email untuk verifikasi.'), backgroundColor: AppColors.success),
        );
        context.pushReplacement(AppRoutes.login);
      case RegisterResult.failed:
        final error = ref.read(authNotifierProvider).error;
        messenger.showSnackBar(
          SnackBar(content: Text(error ?? 'Pendaftaran gagal'), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // OAuth kembali via deep link → tutup ke MainShell (tanpa snackbar ganda;
    // LoginScreen di bawahnya yang menampilkan "Login berhasil!").
    // Email-register ditangani form sendiri → hanya untuk event OAuth.
    ref.listen(authNotifierProvider, (prev, next) {
      if (!mounted) return;
      final wasOut = prev?.user == null;
      if (wasOut &&
          next.user != null &&
          next.lastMethod != 'password') {
        context.go(AppRoutes.home);
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'zunixe',
              showBack: true,
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 8),
                    const Center(child: ZunixeLogo(size: 72)),
                    const SizedBox(height: 20),
                    const Text(
                      'Daftar',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    Text('Buat akun baru di Zunixe', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Email', Icons.email_outlined),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Email harus diisi';
                  if (!t.contains('@') || !t.contains('.')) return 'Email tidak valid';
                  if (t.contains(' ')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Nomor WhatsApp (opsional)', Icons.phone_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Password', Icons.lock_outlined).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password harus diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration('Konfirmasi Password', Icons.lock_outlined),
                validator: (v) {
                  if (v != _passCtrl.text) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Daftar',
                height: 50,
                fontSize: 16,
                loading: _loading,
                onPressed: _register,
              ),
              const SizedBox(height: 24),
              const SocialAuthButtons(
                  dividerLabel: 'atau daftar dengan'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun? ', style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    // Selalu ke halaman login (pop salah dari jalur non-embedded).
                    onTap: () => context.pushReplacement(AppRoutes.login),
                    child: const Text('Masuk', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ],
    ),
  ),
);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.brand),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
