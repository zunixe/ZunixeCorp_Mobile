import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    final isNetwork = product.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      isNetwork
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(Icons.image, size: 48, color: Colors.grey[300]),
                              ),
                            )
                          : Image.asset(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(Icons.image, size: 48, color: Colors.grey[300]),
                              ),
                            ),
                      if (discount > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8102E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-$discount%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  if (discount > 0)
                    Text(
                      'Rp ${NumberFormatPrice(product.originalPrice)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    'Rp ${NumberFormatPrice(product.price)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC8102E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      final cart = context.read<CartProvider>();
                      cart.addToCart(
                        productId: product.id,
                        productName: product.name,
                        productImage: product.imageUrl,
                        price: product.price.round(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ditambahkan ke keranjang'),
                          backgroundColor: const Color(0xFF1BA303),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0103),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Beli',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}

String NumberFormatPrice(double price) {
  return price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
