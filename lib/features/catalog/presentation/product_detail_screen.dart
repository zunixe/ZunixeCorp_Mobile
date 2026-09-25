import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product? product;
  final String? productId;

  const ProductDetailScreen({super.key, this.product, this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  int _imgIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _product = widget.product;
      _loading = false;
    } else if (widget.productId != null) {
      _fetchProduct(widget.productId!);
    } else {
      _loading = false;
    }
  }

  Future<void> _fetchProduct(String id) async {
    final res =
        await ref.read(productRepositoryProvider).getProductById(id);
    if (!mounted) return;
    setState(() {
      _product = res.fold((p) => p, (_) => null);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount =
        ref.watch(cartNotifierProvider.select((s) => s.itemCount));

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }

    final p = _product;
    if (p == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: 'Produk',
                showBack: true,
                showSearch: false,
                showCart: false,
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
                          backgroundColor: AppColors.brand,
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

    final gallery = <String>[
      if (p.imageList.isNotEmpty) ...p.imageList else if (p.imageUrl.isNotEmpty) p.imageUrl,
    ];
    final hasImage = gallery.isNotEmpty;
    final currentImg = hasImage ? gallery[_imgIndex.clamp(0, gallery.length - 1)] : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Detail Produk',
              showBack: true,
              showSearch: false,
              showCart: true,
              onCart: () => context.push(AppRoutes.cart),
              cartCount: itemCount,
            ),
            Expanded(
              child: ListView(
                children: [
                  if (hasImage) ...[
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentImg,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          cacheWidth: 800,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.inputFill,
                              height: 260,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: AppColors.brand, strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.inputFill,
                            height: 260,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 56, color: Colors.grey[350]),
                                const SizedBox(height: 8),
                                Text('Gambar tidak tersedia',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (gallery.length > 1)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: SizedBox(
                          height: 56,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: gallery.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) => GestureDetector(
                              onTap: () => setState(() => _imgIndex = i),
                              child: Container(
                                width: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: i == _imgIndex ? AppColors.brand : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    gallery[i],
                                    fit: BoxFit.cover,
                                    cacheWidth: 200,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.inputFill,
                                      child: Icon(Icons.image, size: 20, color: Colors.grey[350]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatRupiah(p.price),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brand),
                            ),
                            if (p.originalPrice > p.price) ...[
                              const SizedBox(width: 10),
                              Text(
                                formatRupiah(p.originalPrice),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${p.discountPercent}%',
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brand),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (p.stock > 0 ? AppColors.successBg : AppColors.errorBg),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    p.stock > 0 ? Icons.check_circle : Icons.cancel,
                                    size: 13,
                                    color: p.stock > 0 ? AppColors.success : Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    p.stock > 0 ? 'Stok ${p.stock}' : 'Stok Habis',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: p.stock > 0 ? AppColors.success : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (p.category.isNotEmpty && p.category != '0') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.chipFillAlt,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.category,
                                  style: const TextStyle(fontSize: 12, color: AppColors.chipText),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (p.description != null && p.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text('Deskripsi Produk',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
                          const SizedBox(height: 8),
                          Text(
                            p.description!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
                          ),
                        ],
                        const SizedBox(height: 110),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: AddToCartButton(
          product: p,
          imageUrl: currentImg,
          label: 'Tambah ke Keranjang',
        ),
      ),
    );
  }
}
