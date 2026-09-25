import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/result.dart';

class _HasMessage {
  _HasMessage(this.message);
  final String message;
}

void main() {
  group('Result', () {
    test('ok: isOk, value, fold, map', () {
      const r = Result<int>.ok(41);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.value, 41);
      expect(r.fold((v) => v + 1, (_) => -1), 42);
      expect(r.map((v) => 'n$v'), isA<Ok<String>>());
      expect(r.map((v) => 'n$v').value, 'n41');
    });

    test('err: isErr, failure, fold, map', () {
      const r = Result<int>.err(ServerFailure('boom'));
      expect(r.isErr, isTrue);
      expect(r.isOk, isFalse);
      expect(r.failure, isA<ServerFailure>());
      expect(r.fold((_) => 'ok', (f) => f.message), 'boom');
      final mapped = r.map((v) => v + 1);
      expect(mapped.isErr, isTrue);
      expect(mapped.failure.message, 'boom');
    });
  });

  group('Failure.from', () {
    test('Failure dikembalikan apa adanya', () {
      const f = NetworkFailure('putus');
      expect(Failure.from(f), same(f));
    });

    test('objek bermessage dipakai', () {
      expect(Failure.from(_HasMessage('Stok habis')),
          isA<ServerFailure>());
      expect(Failure.from(_HasMessage('Stok habis')).message, 'Stok habis');
    });

    test('string Exception: di-strip', () {
      final f = Failure.from(Exception('meledak'));
      expect(f.message, 'meledak');
    });

    test('Function call error di-strip', () {
      final f = Failure.from('Function call error: Stok habis');
      expect(f.message, 'Stok habis');
    });

    test('null string -> UnknownFailure + fallback', () {
      final f = Failure.from('null');
      expect(f, isA<UnknownFailure>());
      expect(f.message, 'Terjadi kesalahan.');
    });

    test('fallback kustom', () {
      expect(Failure.from('null', fallback: 'Gagal.').message, 'Gagal.');
    });

    test('socket/timeout -> NetworkFailure', () {
      expect(Failure.from(Exception('SocketException: OS Error')),
          isA<NetworkFailure>());
      expect(Failure.from('connection timeout'), isA<NetworkFailure>());
      expect(Failure.from('Periksa koneksi'), isA<NetworkFailure>());
    });

    test('toString memuat tipe + pesan', () {
      expect(const AuthFailure('sesi habis').toString(),
          contains('sesi habis'));
    });
  });

  group('foldAsync', () {
    test('melipat future result', () async {
      final r = await Future.value(const Result<int>.ok(7))
          .foldAsync((v) => v * 2, (_) => -1);
      expect(r, 14);
    });
  });
}
