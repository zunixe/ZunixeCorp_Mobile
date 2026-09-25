import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Kartu produk unggulan statis (ESP32) di home.
class FeaturedProduct extends StatelessWidget {
  const FeaturedProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.memory, size: 40, color: AppColors.brand),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ESP32 Development Board',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Mulai proyek IoT Anda sekarang',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.productsFull),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brand,
                    side: const BorderSide(color: AppColors.brand),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('Lihat Produk', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
