import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Section FAQ "Tanya Kami" di home.
class HelpSection extends StatelessWidget {
  const HelpSection({super.key});

  static const _items = [
    (
      'Mengapa membeli dari Kami',
      Icons.verified,
      'Zunixe adalah mitra terpercaya sejak 2017. Kami menyediakan komponen mikrokontroler dan elektronika berkualitas dengan harga kompetitif. Semua produk kami diuji sebelum dikirim untuk memastikan kualitas terbaik. Didukung oleh tim support yang responsif siap membantu Anda.',
    ),
    (
      'Cara Berbelanja',
      Icons.shopping_cart,
      '1. Telusuri produk di katalog kami.\n2. Klik "Beli" pada produk yang diinginkan (masuk keranjang).\n3. Atur jumlah di keranjang, lalu lanjutkan ke checkout.\n4. Isi data pengiriman dan buat pesanan.\n5. Lakukan pembayaran via transfer, lalu konfirmasi via WhatsApp.\n6. Pesanan Anda akan segera diproses!',
    ),
    (
      'Melacak Order Kamu',
      Icons.local_shipping,
      'Setelah pesanan dikirim, Anda akan menerima nomor resi melalui WhatsApp atau email. Gunakan nomor resi tersebut untuk melacak status pengiriman di situs jasa ekspedisi terkait. Estimasi pengiriman 2-7 hari kerja tergantung lokasi.',
    ),
    (
      'Hubungi Dukungan',
      Icons.headset_mic,
      'Tim support kami siap membantu Anda:\n\nWhatsApp: 0877-7771-1056\nEmail: support@zunixe.com\nAlamat: Jl. Mukodar Tengah No. 247, Cibeureum, Cimahi 40535\n\nJam operasional: Senin - Sabtu, 08:00 - 17:00 WIB',
    ),
    (
      'Tips Keamanan Akun',
      Icons.security,
      '1. Gunakan password yang kuat dan unik.\n2. Jangan bagikan kode OTP ke siapa pun.\n3. Selalu periksa URL sebelum login (pastikan zunixe.com).\n4. Aktifkan verifikasi dua langkah jika tersedia.\n5. Laporkan aktivitas mencurigakan ke tim kami.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanya Kami',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          ..._items.map((item) => FaqItem(
              title: item.$1, icon: item.$2, content: item.$3)),
        ],
      ),
    );
  }
}

/// Satu baris FAQ expandable.
class FaqItem extends StatelessWidget {
  const FaqItem({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    // Material (bukan Container berwarna) agar ink splash ExpansionTile
    // terlihat dan tak memicu assertion debug Flutter.
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, color: AppColors.brand, size: 24),
            title: Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[700], height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
