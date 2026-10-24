/// Label Bahasa Indonesia untuk status pesanan — fungsi murni.
String orderStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'Menunggu';
    case 'processing':
      return 'Diproses';
    case 'shipped':
      return 'Dikirim';
    case 'completed':
      return 'Selesai';
    case 'cancelled':
      return 'Dibatalkan';
    default:
      return status;
  }
}

/// Label status pembayaran (terpisah dari status pengiriman).
String paymentStatusLabel(String status) {
  switch (status) {
    case 'unpaid':
      return 'Belum bayar';
    case 'waiting_confirmation':
      return 'Menunggu verifikasi';
    case 'paid':
      return 'Lunas';
    case 'refunded':
      return 'Dikembalikan';
    default:
      return status;
  }
}
