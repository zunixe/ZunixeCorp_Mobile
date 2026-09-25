import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Gambar produk anti-crash: URL kosong → placeholder,
/// network gagal → ikon, saat load → spinner.
class ProductImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.inputFill,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: AppColors.brand, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return Image.asset(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.inputFill,
      alignment: Alignment.center,
      child: Icon(Icons.image, size: iconSize, color: Colors.grey[350]),
    );
  }
}
