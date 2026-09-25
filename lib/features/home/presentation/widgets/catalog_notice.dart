import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Status katalog home: loading / error + retry / kosong.
/// Section produk disembunyikan saat tak ada data (tanpa dummy fiktif).
class CatalogNotice extends StatelessWidget {
  const CatalogNotice({
    super.key,
    required this.loading,
    this.error,
    required this.isEmpty,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final bool isEmpty;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 40, color: AppColors.muted),
              const SizedBox(height: 8),
              Text(error!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Belum ada produk tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
