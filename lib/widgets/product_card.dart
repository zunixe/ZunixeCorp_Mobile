import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        cacheWidth: 256,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey[300]),
                        ),
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
                  Container(
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
