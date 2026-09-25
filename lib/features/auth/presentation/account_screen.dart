import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    // Belum login → langsung halaman login (tanpa pilihan Masuk/Daftar).
    if (!auth.isLoggedIn) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LoginForm(embedded: true),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Akun Saya',
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      auth.displayName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  _menuTile(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Pesanan Saya',
                    onTap: () => context.push(AppRoutes.orders),
                  ),
                  const SizedBox(height: 8),
                  _menuTile(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Keranjang',
                    onTap: () => context.push(AppRoutes.cart),
                  ),
                  const SizedBox(height: 8),
                  _menuTile(
                    context,
                    icon: Icons.chat,
                    title: 'Chat Support',
                    onTap: () => context.push(AppRoutes.chat),
                  ),
                  const SizedBox(height: 8),
                  _menuTile(
                    context,
                    icon: Icons.info,
                    title: 'Tentang Kami',
                    onTap: () => context.push(AppRoutes.about),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _confirmLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand,
                        side: const BorderSide(color: AppColors.brand),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Keluar', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(authNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar akun?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text('Anda harus masuk lagi untuk berbelanja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    try {
      await notifier.logout();
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Gagal keluar. Periksa koneksi.'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _menuTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    // Material (bukan Container berwarna) agar ink splash ListTile terlihat
    // dan tak memicu assertion debug Flutter.
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brand),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
