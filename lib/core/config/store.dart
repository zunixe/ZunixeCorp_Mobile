import '../utils/format.dart';

/// Data kontak & pembayaran toko — SATU sumber kebenaran.
/// Rekening diisi setelah owner kirim; bagian bank otomatis sembunyi bila kosong.
class StoreConfig {
  static const waNumber = '6287777711056';
  static const waDisplay = '0877-7771-1056';

  static const bankName = '';
  static const accountNumber = '';
  static const accountHolder = '';

  static bool get hasBank =>
      bankName.isNotEmpty && accountNumber.isNotEmpty;

  /// Link WA dengan pesan konfirmasi transfer terisi otomatis.
  static String waConfirmUrl(String orderCode, int total) {
    final text = Uri.encodeComponent(
      'Halo Zunixe, saya sudah transfer untuk pesanan $orderCode '
      'sebesar ${formatRupiah(total)}. Terima kasih.',
    );
    return 'https://wa.me/$waNumber?text=$text';
  }

  static String get waChatUrl => 'https://wa.me/$waNumber';
}
