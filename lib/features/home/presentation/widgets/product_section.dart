import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:go_router/go_router.dart';

/// Grid section produk home (Rekomendasi / Produk Terbaru).
class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.productsFull),
                child: const Text('Lihat Semua',
                    style: TextStyle(color: AppColors.brand, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.53,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => context.pushNamed(
                  AppRouteNames.productDetail,
                  pathParameters: {'id': product.id},
                  extra: product,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
