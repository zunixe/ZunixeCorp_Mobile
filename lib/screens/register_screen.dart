import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil! Silakan masuk.'), backgroundColor: Color(0xFF1BA303)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Pendaftaran gagal'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Daftar',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C)),
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
                  if (v == null || v.trim().isEmpty) return 'Email harus diisi';
                  if (!v.contains('@') || !v.contains('.')) return 'Email tidak valid';
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8102E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun? ', style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Masuk', style: TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.w600)),
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
      prefixIcon: Icon(icon, color: const Color(0xFFC8102E)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC8102E), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
