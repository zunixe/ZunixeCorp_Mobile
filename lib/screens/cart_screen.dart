import 'package:flutter/material.dart';
import '../models/product.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onSwitchToProduk;
  const CartScreen({super.key, required this.onSwitchToProduk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  const Text(
                    'Keranjang Saya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(0xFF3C3C3C)),
                  ),
                  const SizedBox(height: 16),
                  _buildEmptyCart(context),
                  const SizedBox(height: 20),
                  _buildRecentOrders(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          const Text('zunixe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, size: 20, color: Color(0xFF3C3C3C)),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF3C3C3C)),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3C3C3C)),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah produk atau masuk untuk melanjutkan belanja',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSwitchToProduk,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8102E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lanjutkan berbelanja', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC8102E),
                side: const BorderSide(color: Color(0xFFC8102E)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Baru Saja Dipesan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color(0xFF3C3C3C)),
        ),
        const SizedBox(height: 12),
        ...dummyProducts.take(5).map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(p.imageUrl, width: 56, height: 56, fit: BoxFit.cover, cacheWidth: 128),
            ),
            title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
            subtitle: Row(
              children: [
                Text('Rp ${NumberFormatPrice(p.originalPrice)}', style: TextStyle(fontSize: 12, color: Colors.grey[400], decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 6),
                Text('Rp ${NumberFormatPrice(p.price)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

String NumberFormatPrice(double price) {
  return price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
