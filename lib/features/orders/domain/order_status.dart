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
