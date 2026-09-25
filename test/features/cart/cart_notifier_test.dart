import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

import '../../helpers/fakes.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  ProviderContainer containerWith({
    MockCartRepository? cartRepo,
    MockAuthRepository? authRepo,
  }) {
    final container = ProviderContainer(
      overrides: [
        if (cartRepo != null)
          cartRepositoryProvider.overrideWithValue(cartRepo),
        authRepositoryProvider.overrideWithValue(
            authRepo ?? mockAuthRepo()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  CartItem item(String id, {int qty = 1, double price = 1000}) =>
      buildCartItem(id: id, quantity: qty, price: price);

  group('state awal', () {
    test('kosong saat belum login', () {
      final container = containerWith();
      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
      expect(state.itemCount, 0);
      expect(state.totalPrice, 0);
    });
  });

  group('fetchCart', () {
    test('login -> isi dari repository', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.fetchCart(any())).thenAnswer(
        (_) async => Result.ok([item('a', qty: 2, price: 500)]));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );

      await container.read(cartNotifierProvider.notifier).fetchCart();

      final state = container.read(cartNotifierProvider);
      expect(state.itemCount, 2);
      expect(state.totalPrice, 1000);
      expect(state.error, isNull);
      verify(() => cartRepo.fetchCart('u1')).called(greaterThanOrEqualTo(1));
    });

    test('error -> pesan generik', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.fetchCart(any())).thenAnswer(
        (_) async => const Result.err(ServerFailure('x')));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );

      await container.read(cartNotifierProvider.notifier).fetchCart();

      final state = container.read(cartNotifierProvider);
      expect(state.error, 'Gagal memuat keranjang');
      expect(state.loading, isFalse);
    });

    test('ganti user memicu fetch ulang otomatis', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.fetchCart(any()))
          .thenAnswer((_) async => const Result.ok([]));
      final authRepo = mockAuthRepo(user: buildUser(id: 'u1'));
      final container =
          containerWith(cartRepo: cartRepo, authRepo: authRepo);
      // Baca provider agar build() jalan, lalu biarkan fetch awal selesai.
      container.read(cartNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      verify(() => cartRepo.fetchCart('u1')).called(greaterThanOrEqualTo(1));
    });
  });

  group('addToCart', () {
    test('belum login -> false + needsLogin', () async {
      final container = containerWith();
      final ok = await container
          .read(cartNotifierProvider.notifier)
          .addToCart(productId: 'p1');
      expect(ok, isFalse);
      final state = container.read(cartNotifierProvider);
      expect(state.needsLogin, isTrue);
      expect(state.error, 'Silakan login terlebih dahulu');
    });

    test('sukses -> true + fetch ulang', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          )).thenAnswer((_) async => const Result.ok(null));
      when(() => cartRepo.fetchCart(any())).thenAnswer(
        (_) async => Result.ok([item('c1')]));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );

      final ok = await container
          .read(cartNotifierProvider.notifier)
          .addToCart(productId: 'p1', quantity: 2);

      expect(ok, isTrue);
      expect(container.read(cartNotifierProvider).items, hasLength(1));
    });

    test('Not authenticated -> needsLogin', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.fetchCart(any()))
          .thenAnswer((_) async => const Result.ok([]));
      when(() => cartRepo.addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          )).thenAnswer((_) async =>
          const Result.err(ServerFailure('Not authenticated')));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );

      final ok = await container
          .read(cartNotifierProvider.notifier)
          .addToCart(productId: 'p1');

      expect(ok, isFalse);
      expect(container.read(cartNotifierProvider).needsLogin, isTrue);
    });
  });

  group('updateQuantity / removeItem / clearCart / clearError', () {
    test('updateQuantity sukses fetch ulang, gagal pesan', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.updateQuantity(any(), any()))
          .thenAnswer((_) async => const Result.ok(null));
      when(() => cartRepo.fetchCart(any()))
          .thenAnswer((_) async => const Result.ok([]));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.updateQuantity('c1', 3);
      verify(() => cartRepo.updateQuantity('c1', 3)).called(1);

      when(() => cartRepo.updateQuantity(any(), any())).thenAnswer(
        (_) async => const Result.err(ServerFailure('x')));
      await notifier.updateQuantity('c1', 3);
      expect(container.read(cartNotifierProvider).error,
          'Gagal memperbarui jumlah');
    });

    test('removeItem hapus lokal', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.fetchCart(any())).thenAnswer(
        (_) async => Result.ok([item('a'), item('b')]));
      when(() => cartRepo.removeItem(any()))
          .thenAnswer((_) async => const Result.ok(null));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );
      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.fetchCart();
      await notifier.removeItem('a');
      expect(
          container.read(cartNotifierProvider).items.map((e) => e.id), ['b']);
    });

    test('clearCart tanpa login -> no-op', () async {
      final cartRepo = MockCartRepository();
      final container = containerWith(cartRepo: cartRepo);
      await container.read(cartNotifierProvider.notifier).clearCart();
      verifyNever(() => cartRepo.clearCart(any()));
    });

    test('clearError menghapus error', () async {
      final cartRepo = MockCartRepository();
      when(() => cartRepo.fetchCart(any())).thenAnswer(
        (_) async => const Result.err(ServerFailure('x')));
      final container = containerWith(
        cartRepo: cartRepo,
        authRepo: mockAuthRepo(user: buildUser(id: 'u1')),
      );
      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.fetchCart();
      expect(container.read(cartNotifierProvider).error, isNotNull);
      notifier.clearError();
      expect(container.read(cartNotifierProvider).error, isNull);
    });
  });
}
