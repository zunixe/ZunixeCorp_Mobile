import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:go_router/go_router.dart';

/// Drawer navigasi home (tamu vs login).
class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: AppColors.brand,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: auth.isLoggedIn
                            ? CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Text(
                                  auth.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brand),
                                ),
                              )
                            : const ZunixeLogo(size: 44),
                      ),
                      const SizedBox(width: 12),
                      const Text('zunixe',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.isLoggedIn
                        ? auth.displayName
                        : 'Mitra Terpercaya Inovasi Elektronika Anda',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13),
                  ),
                  Text(
                    auth.isLoggedIn
                        ? auth.user?.email ?? ''
                        : ' elektronik · IoT · komponen',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.brand),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: AppColors.brand),
            title: const Text('Semua Produk'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.productsFull);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: AppColors.brand),
            title: const Text('Keranjang'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.cart);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.brand),
            title: const Text('Tentang Kami'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.about);
            },
          ),
          const Divider(),
          if (auth.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: AppColors.brand),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
        ],
      ),
    );
  }
}
