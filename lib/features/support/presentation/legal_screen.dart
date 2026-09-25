import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';

/// Halaman teks statis untuk tautan legal footer.
class LegalScreen extends StatelessWidget {
  final String slug;
  const LegalScreen({super.key, required this.slug});

  static const _pages = <String, Map<String, String>>{
    'tos': {
      'title': 'Persyaratan Layanan',
      'body': 'Dengan menggunakan aplikasi Zunixe Store, Anda menyetujui:\n\n'
          '1. Harga dan stok dapat berubah sewaktu-waktu.\n'
          '2. Pesanan dibuat setelah data pengiriman lengkap.\n'
          '3. Pembayaran via transfer bank, dikonfirmasi via WhatsApp.\n'
          '4. Pesanan yang belum dibayar dapat dibatalkan.\n'
          '5. Penyalahgunaan akun berakibat penangguhan.',
    },
    'privacy': {
      'title': 'Kebijakan Privasi',
      'body': 'Kami menyimpan data yang Anda berikan (nama, email, no. HP, alamat) '
          'hanya untuk memproses pesanan dan layanan pelanggan.\n\n'
          'Data tidak dibagikan ke pihak ketiga kecuali jasa pengiriman untuk '
          'keperluan pengantaran. Anda dapat meminta penghapusan data via '
          'WhatsApp 0877-7771-1056.',
    },
    'shipping': {
      'title': 'Kebijakan Pengiriman',
      'body': 'Pengiriman ke seluruh Indonesia via ekspedisi rekanan.\n\n'
          'Estimasi 2-7 hari kerja tergantung lokasi. Nomor resi dikirim via '
          'WhatsApp/email setelah barang dikirim. Ongkos kirim saat ini GRATIS.',
    },
    'returns': {
      'title': 'Kebijakan Pengembalian',
      'body': 'Barang rusak/salah kirim dapat ditukar maksimal 3 hari setelah '
          'diterima (wajib video unboxing).\n\n'
          'Hubungi WhatsApp 0877-7771-1056 dengan nomor pesanan dan bukti foto/video. '
          'Dana dikembalikan via transfer setelah barang retur kami terima.',
    },
    'ip': {
      'title': 'Kebijakan KI',
      'body': 'Seluruh konten aplikasi (logo, teks, gambar) adalah milik '
          'CV Zunixe Berkah Jaya. Dilarang menyalin atau menggunakan untuk '
          'tujuan komersial tanpa izin tertulis.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final page = _pages[slug] ?? _pages['tos']!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: page['title']!,
              showBack: true,
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    page['body']!,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[800], height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
