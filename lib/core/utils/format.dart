/// Format Rupiah tunggal: 1250500 -> 'Rp1.250.500'.
/// Nilai negatif -> '-Rp2.500' (tanda di depan).
String formatRupiah(num value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final p = rounded.abs().toString();
  final grouped = p.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '${negative ? '-' : ''}Rp$grouped';
}
