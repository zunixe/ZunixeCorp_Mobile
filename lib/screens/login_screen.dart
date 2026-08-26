import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C)),
                  ),
            const SizedBox(height: 8),
            Text(
              'Masuk ke akun Zunixe Anda',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'contoh@email.com',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFC8102E)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC8102E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFFC8102E)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC8102E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur lupa password akan segera hadir'), backgroundColor: Color(0xFFC8102E)),
                  );
                },
                child: const Text('Lupa password?', style: TextStyle(color: Color(0xFFC8102E))),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : () async {
                setState(() => _loading = true);
                final auth = context.read<AuthProvider>();
                final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
                setState(() => _loading = false);
                if (!mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login berhasil!'), backgroundColor: Color(0xFF1BA303)),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(auth.error ?? 'Login gagal'), backgroundColor: Colors.red),
                  );
                }
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8102E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Belum punya akun? ', style: TextStyle(color: Colors.grey[600])),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('Daftar', style: TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
),
);
  }
}
