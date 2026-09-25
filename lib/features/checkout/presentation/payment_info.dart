import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zunixe_corp_mobile/core/config/store.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Kartu cara bayar manual: transfer + konfirmasi WhatsApp.
/// Dipakai di OrderSuccessScreen & detail pesanan (belum bayar).
class PaymentInfo extends StatelessWidget {
  final String orderCode;
  final int total;

  const PaymentInfo({
    super.key,
    required this.orderCode,
    required this.total,
  });

  Future<void> _copy(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$label disalin'),
          backgroundColor: AppColors.success),
    );
  }

  Future<void> _openWa(BuildContext context) async {
    final url = Uri.parse(StoreConfig.waConfirmUrl(orderCode, total));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak dapat membuka WhatsApp'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment, size: 18, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Cara Bayar',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '1. Transfer ${formatRupiah(total)} ke:',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (StoreConfig.hasBank)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(StoreConfig.bankName,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        const Text(StoreConfig.accountNumber,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        Text('a.n. ${StoreConfig.accountHolder}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _copy(context,
                        StoreConfig.accountNumber, 'No. rekening'),
                    icon: const Icon(Icons.copy,
                        size: 16, color: AppColors.brand),
                    label: const Text('Salin',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.brand)),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Hubungi WhatsApp ${StoreConfig.waDisplay} untuk nomor rekening.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            '2. Konfirmasi via WhatsApp (sertakan kode pesanan).',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openWa(context),
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Konfirmasi via WhatsApp',
                  style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whatsapp,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
