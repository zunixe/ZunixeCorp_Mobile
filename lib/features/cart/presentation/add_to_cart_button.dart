import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Tombol tambah-ke-keranjang dengan state: idle -> loading -> sukses.
/// compact = pill kecil untuk kartu produk; full = lebar penuh untuk halaman detail.
class AddToCartButton extends ConsumerStatefulWidget {
  final Product product;
  final String? imageUrl;
  final bool compact;
  final bool expand;
  final String label;

  const AddToCartButton({
    super.key,
    required this.product,
    this.imageUrl,
    this.compact = false,
    this.expand = false,
    this.label = 'Beli',
  });

  @override
  ConsumerState<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<AddToCartButton> {
  bool _busy = false;
  bool _done = false;

  static const _gradRed = LinearGradient(
    colors: [AppColors.brandLight, AppColors.brand, AppColors.brandDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const _gradGreen = LinearGradient(
    colors: [AppColors.successBright, AppColors.success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> _onTap() async {
    if (_busy) return;
    final cart = ref.read(cartNotifierProvider.notifier);

    setState(() => _busy = true);
    final ok = await cart.addToCart(productId: widget.product.id);
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      setState(() => _done = true);
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => _done = false);
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.dark,
          content: Text(
            '${widget.product.name} masuk keranjang',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
          action: SnackBarAction(
            label: 'Lihat',
            textColor: AppColors.pinkLight,
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ),
      );
      return;
    }

    final needLogin = ref.read(cartNotifierProvider).needsLogin;
    if (needLogin) {
      final goLogin = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.brand),
              SizedBox(width: 10),
              Text('Belum Login', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text(
            'Login dulu yuk biar bisa menambah produk ke keranjang.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Nanti', style: TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
      if (goLogin == true && mounted) {
        context.push(AppRoutes.login);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(ref.read(cartNotifierProvider).error ??
              'Gagal menambah ke keranjang'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product.stock <= 0) return _buildOutOfStock();
    if (widget.compact) return _buildCompact();
    return _buildFull();
  }

  /// Tombol mati abu-abu saat stok habis (gagal cepat di UI, bukan saat RPC).
  Widget _buildOutOfStock() {
    const label = Text(
      'Stok Habis',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
    final box = Container(
      height: widget.compact ? 32 : 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.silver,
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 14),
      ),
      child: label,
    );
    if (widget.compact && widget.expand) {
      return SizedBox(width: double.infinity, child: box);
    }
    return box;
  }

  Widget _buildCompact() {
    final btn = _pill(height: 32, horizontalPad: 12, fontSize: 12.5, iconSize: 14);
    if (widget.expand) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }

  Widget _pill({
    required double height,
    required double horizontalPad,
    required double fontSize,
    required double iconSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _done ? _gradGreen : _gradRed,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: (_done ? AppColors.success : AppColors.brand).withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: _busy ? null : _onTap,
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: horizontalPad),
            child: Row(
              mainAxisAlignment: widget.expand
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                _buildLeadingIcon(size: iconSize),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _done ? 'OK' : widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFull() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: _done ? _gradGreen : _gradRed,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (_done ? AppColors.success : AppColors.brand).withValues(alpha: 0.40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _busy ? null : _onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLeadingIcon(size: 20),
              const SizedBox(width: 10),
              Text(
                _done ? 'Berhasil Ditambahkan' : widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon({double size = 15}) {
    if (_busy) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (_done) {
      return Icon(Icons.check_circle, size: size, color: Colors.white);
    }
    return Icon(Icons.add_shopping_cart, size: size, color: Colors.white);
  }
}
