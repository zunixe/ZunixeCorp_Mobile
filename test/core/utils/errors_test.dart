import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/utils/errors.dart';

/// Kelas tiruan mirip `PostgrestException` (punya properti `message`).
class _HasMessage {
  _HasMessage(this.message);
  final String message;
}

void main() {
  group('serverMessage', () {
    test('ambil message PostgrestException-like', () {
      expect(
        serverMessage('PostgrestException(message: Stok habis, code: P0001)'),
        contains('Stok habis'),
      );
    });

    test('objek dengan properti message dipakai apa adanya', () {
      expect(serverMessage(_HasMessage('Stok tidak cukup')), 'Stok tidak cukup');
    });

    test('objek message kosong diabaikan lalu fallback ke toString', () {
      final e = _HasMessage('');
      // toString default akan dipakai; bukan fallback bawaan karena tidak null.
      expect(serverMessage(e), isNot('Terjadi kesalahan.'));
    });

    test('fallback bawaan saat null string', () {
      expect(serverMessage('null'), 'Terjadi kesalahan.');
    });

    test('fallback kustom', () {
      expect(serverMessage('null', fallback: 'Gagal.'), 'Gagal.');
    });

    test('strip prefix Exception:', () {
      expect(serverMessage(Exception('boom')), 'boom');
    });

    test('strip prefix Function call error:', () {
      expect(
        serverMessage('Function call error: Stok habis'),
        'Stok habis',
      );
    });

    test('string kosong -> fallback', () {
      expect(serverMessage(''), 'Terjadi kesalahan.');
    });

    test('nilai non-string non-message -> toString', () {
      expect(serverMessage(42), '42');
    });

    test('fallback ketika jumlah char kosong', () {
      expect(serverMessage('', fallback: 'Kosong'), 'Kosong');
    });
  });
}
