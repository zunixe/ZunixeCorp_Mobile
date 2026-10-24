import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/catalog_notice.dart';
import 'widgets/featured_product.dart';
import 'widgets/help_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/home_drawer.dart';
import 'widgets/home_footer.dart';
import 'widgets/product_section.dart';
import 'widgets/promo_banner.dart';
import 'widgets/super_promo.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Product> _products = [];
  bool _loadingProducts = true;
  String? _productsError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _productsError = null;
    });
    final res = await ref.read(productRepositoryProvider).getProducts();
    // Tanpa fallback dummy: harga/stok fiktif berbahaya (tombol Beli aktif).
    if (!mounted) return;
    res.fold(
      (products) => setState(() {
        _products = products;
        _loadingProducts = false;
      }),
      (f) => setState(() {
        _loadingProducts = false;
        _productsError = f.message.isEmpty
            ? 'Gagal memuat produk. Periksa koneksi.'
            : f.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const PromoBanner(),
            AppHeader(
              showMenu: true,
              showSearch: true,
              showCart: true,
              showProfile: true,
              cartCount: cart.itemCount,
              onSearch: () => context.push(AppRoutes.productsFull),
              onCart: () => context.push(AppRoutes.cart),
              onProfile: () {
                if (auth.isLoggedIn) {
                  context.push(AppRoutes.account);
                } else {
                  context.push(AppRoutes.login);
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  const HeroSection(),
                  const BannerCarousel(),
                  const FeaturedProduct(),
                  const SuperPromo(),
                  ProductSection(
                      title: 'Rekomendasi',
                      products: _products.take(4).toList()),
                  ProductSection(title: 'Produk Terbaru', products: _products),
                  CatalogNotice(
                    loading: _loadingProducts,
                    error: _productsError,
                    isEmpty: _products.isEmpty,
                    onRetry: _loadProducts,
                  ),
                  const HelpSection(),
                  const HomeFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
