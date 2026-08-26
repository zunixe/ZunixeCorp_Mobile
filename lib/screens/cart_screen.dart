import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_header.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onSwitchToProduk;
  const CartScreen({super.key, required this.onSwitchToProduk});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Keranjang',
              showSearch: false,
              showCart: false,
              showProfile: false,
              cartCount: cart.itemCount,
            ),
            Expanded(
              child: cart.items.isEmpty ? _buildEmptyCart(context) : _buildCartList(context, cart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(BuildContext context, CartProvider cart) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Keranjang Saya',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(0xFF3C3C3C)),
        ),
        const SizedBox(height: 12),
        ...cart.items.map((item) => Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => cart.removeItem(item.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (item.productImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.productImage, width: 64, height: 64, fit: BoxFit.cover, cacheWidth: 200),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_formatPrice(item.price)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC8102E)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFC8102E), size: 28),
                      onPressed: () => cart.updateQuantity(item.id, item.quantity - 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC8102E), size: 28),
                      onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Flexible(
                child: Text(
                  'Rp ${_formatPrice(cart.totalPrice)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC8102E)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur checkout akan segera hadir!'), backgroundColor: Color(0xFFC8102E)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8102E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
