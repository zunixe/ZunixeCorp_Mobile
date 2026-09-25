/// Hasil operasi domain: sukses ([Ok]) atau gagal ([Err]).
///
/// Repository mengembalikan [Result] alih-alih melempar untuk kegagalan
/// yang dapat diprediksi (jaringan, server, auth). Presentation melipatnya
/// menjadi state UI (Riverpod `AsyncValue`).
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get value => (this as Ok<T>).value;
  Failure get failure => (this as Err<T>).failure;

  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    return switch (this) {
      Ok(:final value) => onOk(value),
      Err(:final failure) => onErr(failure),
    };
  }

  Result<R> map<R>(R Function(T value) f) {
    return fold<Result<R>>((v) => Result.ok(f(v)), (e) => Result.err(e));
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  @override
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  @override
  final Failure failure;
}

/// Kegagalan domain dengan pesan siap tampil (Bahasa Indonesia).
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType(message: $message)';

  /// Petakan exception tak dikenal (Supabase, socket, dsb.) menjadi [Failure].
  /// Pesan `raise EXCEPTION` server dipertahankan bila ada.
  factory Failure.from(Object e, {String fallback = 'Terjadi kesalahan.'}) {
    if (e is Failure) return e;
    final msg = _extractMessage(e);
    if (msg == null) return UnknownFailure(fallback);
    final lower = msg.toLowerCase();
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('timeout') ||
        lower.contains('koneksi')) {
      return NetworkFailure(msg);
    }
    if (e is AuthFailureMarker) return AuthFailure(msg);
    return ServerFailure(msg);
  }

  /// Ambil pesan semantik dari berbagai bentuk exception.
  static String? _extractMessage(Object e) {
    try {
      final m = (e as dynamic).message as String?;
      if (m != null && m.isNotEmpty) return m;
    } catch (_) {}
    final s = e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Function call error: ', '');
    if (s.isEmpty || s == 'null') return null;
    return s;
  }
}

/// Penanda internal: exception auth yang pesannya sudah ramah-pengguna.
abstract final class AuthFailureMarker {}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

extension ResultFutureX<T> on Future<Result<T>> {
  /// Lipat langsung menjadi nilai UI dalam satu langkah.
  Future<R> foldAsync<R>(
    R Function(T value) onOk,
    R Function(Failure failure) onErr,
  ) async {
    return (await this).fold(onOk, onErr);
  }
}
