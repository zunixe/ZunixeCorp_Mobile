import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart';
import 'chat_screen.dart';
import '../providers/cart_provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(isTab: true),
    CartScreen(onSwitchToProduk: () {}),
    const AccountScreen(),
    const ChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _screens[2] = CartScreen(onSwitchToProduk: () => setState(() => _currentIndex = 1));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
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
          selectedItemColor: const Color(0xFFC8102E),
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Produk'),
            BottomNavigationBarItem(
              icon: cart.itemCount > 0
                  ? Badge(label: Text('${cart.itemCount}'), child: const Icon(Icons.shopping_cart))
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
