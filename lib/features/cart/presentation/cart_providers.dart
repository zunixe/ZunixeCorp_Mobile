import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/network/supabase_client_provider.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

/// Repository keranjang untuk graph Riverpod. Override di test dengan
/// mock/fake [CartRepository].
final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositorySupabase(
    client: ref.watch(supabaseClientProvider),
  ),
  name: 'cartRepositoryProvider',
);

/// State keranjang untuk UI.
class CartState {
  const CartState({
    this.items = const [],
    this.loading = false,
    this.error,
    this.needsLogin = false,
  });

  final List<CartItem> items;
  final bool loading;
  final String? error;

  /// True bila kegagalan terakhir karena belum login (tampilkan dialog login).
  final bool needsLogin;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  int get totalPrice =>
      items.fold(0, (sum, i) => sum + (i.price * i.quantity).round());

  CartState copyWith({
    List<CartItem>? items,
    bool? loading,
    String? error,
    bool? needsLogin,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      needsLogin: needsLogin ?? this.needsLogin,
    );
  }
}

/// Pengganti Riverpod untuk `CartProvider` (ChangeNotifier).
///
/// Sinkronisasi user mengikuti `authNotifierProvider`: ganti user (termasuk
/// logout → null) otomatis memuat ulang keranjang — menggantikan
/// `ChangeNotifierProxyProvider` + `syncUser` di main.dart.
class CartNotifier extends Notifier<CartState> {
  String? _lastUserId;

  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  CartState build() {
    final userId =
        ref.watch(authNotifierProvider.select((s) => s.user?.id));
    if (userId != _lastUserId) {
      _lastUserId = userId;
      // Jadwalkan setelah build agar tak ada side-effect sinkron di build.
      Future.microtask(fetchCart);
    }
    return const CartState();
  }

  bool get _isLoggedIn =>
      ref.read(authNotifierProvider).user != null;

  Future<void> fetchCart() async {
    if (!_isLoggedIn) {
      state = state.copyWith(items: const []);
      return;
    }
    state = state.copyWith(loading: true);
    final userId = ref.read(authNotifierProvider).user!.id;
    final res = await _repo.fetchCart(userId);
    res.fold(
      (items) => state = state.copyWith(items: items, clearError: true),
      (_) => state = state.copyWith(error: 'Gagal memuat keranjang'),
    );
    state = state.copyWith(loading: false);
  }

  /// Tambah atomik via RPC cart_add. Pesan error server sudah ramah-pengguna.
  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    state = state.copyWith(needsLogin: false);
    if (!_isLoggedIn) {
      state = state.copyWith(
        error: 'Silakan login terlebih dahulu',
        needsLogin: true,
      );
      return false;
    }
    final res = await _repo.addToCart(
      productId: productId,
      quantity: quantity,
    );
    if (res.isErr) {
      final msg = res.failure.message;
      if (msg == 'Not authenticated') {
        state = state.copyWith(
          error: 'Silakan login terlebih dahulu',
          needsLogin: true,
        );
      } else {
        state = state.copyWith(error: msg);
      }
      return false;
    }
    state = state.copyWith(clearError: true);
    await fetchCart();
    return true;
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final res = await _repo.updateQuantity(itemId, quantity);
    if (res.isErr) {
      state = state.copyWith(error: 'Gagal memperbarui jumlah');
      return;
    }
    state = state.copyWith(clearError: true);
    await fetchCart();
  }

  Future<void> removeItem(String itemId) async {
    final res = await _repo.removeItem(itemId);
    if (res.isErr) {
      state = state.copyWith(error: 'Gagal menghapus item');
      return;
    }
    final items = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: items, clearError: true);
  }

  Future<void> clearCart() async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId == null) return;
    final res = await _repo.clearCart(userId);
    res.fold(
      (_) => state = state.copyWith(items: const []),
      (_) {},
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
  name: 'cartNotifierProvider',
);
