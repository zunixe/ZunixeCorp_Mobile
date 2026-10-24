/// Nama route terpusat — SATU-SATUNYA sumber kebenaran string route.
abstract final class AppRoutes {
  static const String home = '/';
  static const String about = '/about';
  static const String productsFull = '/products-full';
  static const String cart = '/cart';
  static const String login = '/login';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String chat = '/chat';
  static const String account = '/account';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String orderSuccess = '/order-success';

  /// Detail produk: deep-linkable via id, atau oper objek via `extra`.
  static const String productDetail = '/product/:id';
  static const String productDetailBase = '/product';

  /// Halaman legal statis via slug.
  static const String legal = '/legal/:slug';
  static const String legalBase = '/legal';

  /// Deep-link callback OAuth (harus terdaftar di Supabase dashboard).
  static const String oauthCallbackScheme = 'zunixe://login-callback';

  /// Validasi tujuan "kembali setelah login": hanya path internal.
  /// Menolak URL absolut/protocol-relative agar tidak jadi open redirect.
  static String? safeInternalPath(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (!raw.startsWith('/') || raw.startsWith('//')) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
    if (uri.path == login || uri.path == register) return null;
    return raw;
  }
}

/// Nama logis route untuk navigasi bertipe (`goNamed`/`pushNamed`).
abstract final class AppRouteNames {
  static const String home = 'home';
  static const String about = 'about';
  static const String productsFull = 'productsFull';
  static const String cart = 'cart';
  static const String login = 'login';
  static const String checkout = 'checkout';
  static const String orders = 'orders';
  static const String chat = 'chat';
  static const String productDetail = 'productDetail';
  static const String legal = 'legal';
  static const String account = 'account';
  static const String register = 'register';
  static const String resetPassword = 'resetPassword';
  static const String orderSuccess = 'orderSuccess';
}
