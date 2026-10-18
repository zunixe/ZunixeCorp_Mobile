import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/home/home.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(isTab: true),
    CartScreen(onSwitchToProduk: () => setState(() => _currentIndex = 1)),
    const AccountScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Selalu mounted (root): tangkap sesi recovery password dari deep link
    // email kapan pun datangnya.
    ref.listen(authEventsProvider, (_, next) {
      next.whenData((data) {
        if (!mounted) return;
        if (data.event == AuthChangeEvent.passwordRecovery &&
            data.session != null) {
          context.push(AppRoutes.resetPassword);
        }
      });
    });

    final itemCount =
        ref.watch(cartNotifierProvider.select((s) => s.itemCount));
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.brand,
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Produk'),
            BottomNavigationBarItem(
              icon: itemCount > 0
                  ? Badge(label: Text('$itemCount'), child: const Icon(Icons.shopping_cart))
                  : const Icon(Icons.shopping_cart),
              label: 'Keranjang',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
            const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          ],
        ),
      ),
    );
  }
}
