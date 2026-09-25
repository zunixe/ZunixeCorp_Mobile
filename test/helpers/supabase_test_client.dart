import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rekaman satu pemanggilan method pada builder palsu.
class RecordedCall {
  RecordedCall(this.method, this.args);
  final String method;
  final List<Object?> args;
  @override
  String toString() => '$method($args)';
}

/// Builder filter palsu yang dapat di-await.
///
/// `PostgrestFilterBuilder` mengimplementasikan `Future`, jadi kita sediakan
/// `then`/`catchError`/`whenComplete`/`asStream`/`timeout` yang menyelesaikan
/// ke [resolve] (atau melempar [throws]). Semua method chain lain ditangani
/// [noSuchMethod] → mengembalikan `this` (sehingga chain panjang lolos) dan
/// direkam ke [calls].
// ignore: must_be_immutable
class FakeFilterBuilder<T> extends Fake
    implements Future<T>, PostgrestFilterBuilder<T> {
  FakeFilterBuilder({this.resolve, this.throws});

  /// Nilai mentah; di-cast ke `T` saat di-await.
  Object? resolve;
  Object? throws;

  final List<RecordedCall> calls = [];

  Object? argOf(String method) {
    for (final c in calls) {
      if (c.method == method && c.args.isNotEmpty) return c.args.first;
    }
    return null;
  }

  bool wasCalled(String method) => calls.any((c) => c.method == method);

  Future<T> _value() async {
    if (throws != null) throw throws!;
    return resolve as T;
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue,
          {Function? onError}) =>
      _value().then(onValue, onError: onError);

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _value().catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _value().whenComplete(action);

  @override
  Stream<T> asStream() => _value().asStream();

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _value().timeout(timeLimit, onTimeout: onTimeout);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName
        .toString()
        .replaceFirst('Symbol("', '')
        .replaceAll('")', '');
    calls.add(RecordedCall(name, invocation.positionalArguments.toList()));
    if (invocation.isMethod) {
      // maybeSingle/single mengubah tipe hasil menjadi satu baris
      // (PostgrestMap?) — kembalikan filter baru bertipe sesuai agar cast
      // aman, dengan daftar rekaman yang sama agar verifikasi tetap utuh.
      if (name == 'maybeSingle' || name == 'single') {
        final single = FakeFilterBuilder<PostgrestMap?>(
          resolve: resolve,
          throws: throws,
        );
        single.calls.addAll(calls);
        return single;
      }
      return this;
    }
    return null;
  }
}

/// Builder query palsu (hasil `client.from(table)`).
/// `select` mengembalikan [filter] bertipe `PostgrestList`; method chain lain
/// juga mengembalikan [filter] lewat [noSuchMethod].
class FakeQueryBuilder implements SupabaseQueryBuilder {
  FakeQueryBuilder(this.filter);

  final FakeFilterBuilder<PostgrestList> filter;
  final List<RecordedCall> calls = [];

  bool wasCalled(String method) => calls.any((c) => c.method == method);

  Object? argOf(String method) {
    for (final c in calls) {
      if (c.method == method && c.args.isNotEmpty) return c.args.first;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName
        .toString()
        .replaceFirst('Symbol("', '')
        .replaceAll('")', '');
    calls.add(RecordedCall(name, invocation.positionalArguments.toList()));
    return filter;
  }
}

/// Mock `SupabaseClient` dengan helper penataan (stubbing) ringkas.
class MockSupabaseTestClient extends Mock implements SupabaseClient {
  final Map<String, FakeFilterBuilder<PostgrestList>> _fromStubs = {};
  final Map<String, FakeFilterBuilder<dynamic>> _rpcStubs = {};

  /// Query builder yang pernah dibuat per tabel (untuk verifikasi method
  /// seperti `update`/`delete` yang terekam di level query builder).
  final Map<String, List<FakeQueryBuilder>> queryBuilders = {};

  /// Daftarkan respons untuk `from(table)`. Seluruh chain mengembalikan
  /// [returning] saat di-await, atau melempar [throws].
  FakeFilterBuilder<PostgrestList> stubFrom(String table,
      {Object? returning, Object? throws}) {
    final fb = FakeFilterBuilder<PostgrestList>(
        resolve: returning, throws: throws);
    _fromStubs[table] = fb;
    when(() => from(table)).thenAnswer((_) {
      final qb = FakeQueryBuilder(fb);
      queryBuilders.putIfAbsent(table, () => []).add(qb);
      return qb;
    });
    return fb;
  }

  /// Daftarkan respons untuk `rpc(fn)`.
  FakeFilterBuilder<dynamic> stubRpc(String fn,
      {Object? returning, Object? throws}) {
    final fb = FakeFilterBuilder<dynamic>(resolve: returning, throws: throws);
    _rpcStubs[fn] = fb;
    when(() => rpc<dynamic>(fn, params: any(named: 'params')))
        .thenAnswer((_) => fb);
    return fb;
  }

  FakeFilterBuilder<PostgrestList>? fromStub(String table) =>
      _fromStubs[table];
  FakeFilterBuilder<dynamic>? rpcStub(String fn) => _rpcStubs[fn];
}
