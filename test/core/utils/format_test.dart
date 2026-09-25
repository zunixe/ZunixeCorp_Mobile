import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';

void main() {
  group('formatRupiah', () {
    test('ribuan', () => expect(formatRupiah(2500), 'Rp2.500'));

    test('jutaan (bug lama Rp1.250000)', () {
      expect(formatRupiah(1250500), 'Rp1.250.500');
    });

    test('juta pas', () => expect(formatRupiah(2000000), 'Rp2.000.000'));

    test('di bawah seribu', () => expect(formatRupiah(500), 'Rp500'));

    test('nol', () => expect(formatRupiah(0), 'Rp0'));

    test('double dibulatkan ke atas', () {
      expect(formatRupiah(999.6), 'Rp1.000');
    });

    test('double dibulatkan ke bawah', () {
      expect(formatRupiah(999.4), 'Rp999');
    });

    test('tepat seribu', () => expect(formatRupiah(1000), 'Rp1.000'));

    test('puluhan ribu', () => expect(formatRupiah(10000), 'Rp10.000'));

    test('ratus ribu', () => expect(formatRupiah(100000), 'Rp100.000'));

    test('miliar', () => expect(formatRupiah(1000000000), 'Rp1.000.000.000'));

    test('triliun', () {
      expect(formatRupiah(1234567890123), 'Rp1.234.567.890.123');
    });

    test('angka double utuh tidak menambah desimal', () {
      expect(formatRupiah(1250500.0), 'Rp1.250.500');
    });

    test('dua digit', () => expect(formatRupiah(42), 'Rp42'));

    test('satu digit', () => expect(formatRupiah(7), 'Rp7'));

    test('negatif tetap diawali Rp', () {
      // Mendokumentasikan perilaku aktual: tanda minus dipertahankan.
      expect(formatRupiah(-2500), '-Rp2.500');
    });
  });
}
