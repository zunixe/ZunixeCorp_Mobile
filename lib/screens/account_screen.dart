import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFC8102E),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Masuk atau Daftar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Masuk untuk melihat pesanan dan wishlist Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8102E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Masuk', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC8102E),
                  side: const BorderSide(color: Color(0xFFC8102E)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Daftar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
