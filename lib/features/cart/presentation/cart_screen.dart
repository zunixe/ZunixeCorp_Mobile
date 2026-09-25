import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/core/ui/product_image.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  final VoidCallback onSwitchToProduk;
  const CartScreen({super.key, required this.onSwitchToProduk});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
              child: _buildBody(context, ref, cart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CartState cart) {
    // Loading awal (bukan flash "Kosong").
    if (cart.loading && cart.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }
    // Error load + retry.
    if (cart.error != null && cart.items.isEmpty) {
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
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(
                  cart.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Coba Lagi',
                  height: 44,
                  fontSize: 14,
                  onPressed: () {
                    final notifier = ref.read(cartNotifierProvider.notifier);
                    notifier.clearError();
                    notifier.fetchCart();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (cart.items.isEmpty) return _buildEmptyCart(context);
    return _buildCartList(context, ref, cart);
  }

  /// Hapus dengan opsi Urungkan (tambah ulang via RPC yang sama).
  Future<void> _dismissItem(
      BuildContext context, WidgetRef ref, CartItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final cart = ref.read(cartNotifierProvider.notifier);
    await cart.removeItem(item.id);
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('${item.productName} dihapus dari keranjang',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: AppColors.pinkLight,
          onPressed: () => ref.read(cartNotifierProvider.notifier).addToCart(
            productId: item.productId,
            quantity: item.quantity,
          ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambah produk atau masuk untuk melanjutkan belanja',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Lanjutkan berbelanja',
                height: 44,
                fontSize: 14,
                onPressed: onSwitchToProduk,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(BuildContext context, WidgetRef ref, CartState cart) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
          onDismissed: (_) => _dismissItem(context, ref, item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(
                    url: item.productImage,
                    width: 64,
                    height: 64,
                    cacheWidth: 200,
                    iconSize: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(item.price.round()),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brand),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.brand, size: 28),
                      onPressed: () => ref.read(cartNotifierProvider.notifier).updateQuantity(item.id, item.quantity - 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: item.quantity >= item.stock
                            ? Colors.grey[300]
                            : AppColors.brand,
                        size: 28,
                      ),
                      // Cap di stok terkini (server tetap validasi ulang saat checkout).
                      onPressed: item.quantity >= item.stock
                          ? null
                          : () => ref.read(cartNotifierProvider.notifier).updateQuantity(item.id, item.quantity + 1),
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
                  formatRupiah(cart.totalPrice),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brand),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GradientButton(
          label: 'Checkout',
          height: 48,
          fontSize: 16,
          onPressed: cart.items.isEmpty ? null : () => context.push(AppRoutes.checkout),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
