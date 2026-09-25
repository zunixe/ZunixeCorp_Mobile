import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/config/store.dart';

void main() {
  group('StoreConfig', () {
    test('nomor WA sesuai', () {
      expect(StoreConfig.waNumber, '6287777711056');
      expect(StoreConfig.waDisplay, '0877-7771-1056');
    });

    test('hasBank false ketika bank kosong', () {
      expect(StoreConfig.hasBank, isFalse);
    });

    test('waChatUrl', () {
      expect(StoreConfig.waChatUrl, 'https://wa.me/6287777711056');
    });

    test('waConfirmUrl memuat nomor, kode, dan total terformat', () {
      final url = StoreConfig.waConfirmUrl('INV-001', 1250500);
      expect(url, startsWith('https://wa.me/6287777711056?text='));
      expect(Uri.decodeComponent(url), contains('INV-001'));
      expect(Uri.decodeComponent(url), contains('Rp1.250.500'));
      expect(Uri.decodeComponent(url), contains('Halo Zunixe'));
    });

    test('waConfirmUrl ter-encode (spasi jadi %20 atau +)', () {
      final url = StoreConfig.waConfirmUrl('INV-2', 1000);
      final text = url.substring(url.indexOf('?text=') + 6);
      expect(text.contains(' '), isFalse);
    });

    test('waConfirmUrl total nol tetap valid', () {
      final url = StoreConfig.waConfirmUrl('X', 0);
      expect(Uri.decodeComponent(url), contains('Rp0'));
    });
  });
}
