import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'payment_info.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderCode;
  final int total;

  const OrderSuccessScreen({super.key, required this.orderCode, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Pesanan Berhasil',
              showBack: false,
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const ZunixeLogo(size: 96),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 20, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Terima kasih!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pesanan Anda berhasil dibuat.\nTim kami akan segera memproses.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('No. Pesanan', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                                Row(
                                  children: [
                                    Text(orderCode,
                                        style: const TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.brand)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(text: orderCode));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('No. pesanan disalin'),
                                                backgroundColor: AppColors.success),
                                          );
                                        }
                                      },
                                      child: const Icon(Icons.copy, size: 16, color: AppColors.brand),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                                Text(formatRupiah(total),
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PaymentInfo(orderCode: orderCode, total: total),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Lihat Pesanan Saya',
                        height: 48,
                        fontSize: 15,
                        icon: Icons.receipt_long,
                        onPressed: () => context.pushReplacement(AppRoutes.orders),
                      ),
                      const SizedBox(height: 12),
                      GradientButton(
                        label: 'Kembali ke Beranda',
                        height: 48,
                        fontSize: 15,
                        icon: Icons.home_outlined,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
