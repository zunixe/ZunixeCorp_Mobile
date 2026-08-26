import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../widgets/app_header.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final String? productId;

  const ProductDetailScreen({super.key, this.product, this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _product = widget.product;
      _loading = false;
    } else if (widget.productId != null) {
      _fetchProduct(widget.productId!);
    }
  }

  Future<void> _fetchProduct(String id) async {
    try {
      final product = await ProductService.fetchProduct(id);
      if (mounted) setState(() { _product = product; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatPrice(double price) {
    final p = price.round();
    if (p >= 1000000) {
      final mil = p ~/ 1000000;
      final sisa = p % 1000000;
      if (sisa == 0) return 'Rp${mil}M';
      return 'Rp${mil},${(sisa ~/ 1000)}Rb';
    }
    if (p >= 1000) return 'Rp${(p ~/ 1000)}Rb';
    return 'Rp$p';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC8102E))),
      );
    }

    final p = _product;
    if (p == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Produk',
                showBack: true,
                showSearch: false,
                showCart: true,
                showProfile: false,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Produk tidak ditemukan', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8102E),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Kembali'),
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

    final imageUrl = p.imageList.isNotEmpty
        ? p.imageList.first
        : p.imageUrl;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: p.name,
              showBack: true,
              showSearch: false,
              showCart: true,
              onCart: () => Navigator.pushNamed(context, '/cart'),
              cartCount: cart.itemCount,
            ),
            Expanded(
              child: ListView(
                children: [
                  if (imageUrl.isNotEmpty)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          cacheWidth: 600,
                        ),
                      ),
                    ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatPrice(p.price),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC8102E)),
                            ),
                            if (p.originalPrice > p.price) ...[
                              const SizedBox(width: 10),
                              Text(
                                _formatPrice(p.originalPrice),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('Stok: ${p.stock}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(width: 16),
                            if (p.sku.isNotEmpty) ...[
                              Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('SKU: ${p.sku}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ],
                        ),
                        if (p.description != null && p.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3C3C3C))),
                          const SizedBox(height: 6),
                          Text(p.description!, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                        ],
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              cart.addToCart(
                productId: p.id,
                productName: p.name,
                productImage: imageUrl,
                price: p.price.round(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${p.name} ditambahkan ke keranjang'),
                  backgroundColor: const Color(0xFF1BA303),
                  action: SnackBarAction(
                    label: 'Lihat',
                    textColor: Colors.white,
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Tambah ke Keranjang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8102E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
