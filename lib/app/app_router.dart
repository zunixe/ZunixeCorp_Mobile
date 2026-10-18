import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/checkout/checkout.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

import 'main_shell.dart';

/// Daftar modul fitur yang dirangkai router. Menambah/menghapus fitur cukup
/// mengubah daftar ini (satu baris) — tidak perlu menyentuh logika router.
const List<FeatureModule> appModules = [
  AuthModule(),
  CatalogModule(),
  CartModule(),
  CheckoutModule(),
  OrdersModule(),
  SupportModule(),
];

/// Router aplikasi (go_router). Guard auth untuk checkout/orders via
/// [redirect] — menggantikan widget `RequireLogin` manual.
///
/// Rute fitur disumbang oleh [appModules]; shell `"/"` dan kebijakan redirect
/// tetap dimiliki lapisan `app`.
///
/// Di test, baca provider ini dari container dengan override repository.
final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    return GoRouter(
      initialLocation: AppRoutes.home,
      // Evaluasi ulang guard setiap ada event auth.
      refreshListenable: _StreamListenable(
        authRepo.onAuthStateChange,
      ),
      redirect: (context, state) {
        final loggedIn = authRepo.currentUser != null;
        final location = state.matchedLocation;
        const guarded = [AppRoutes.checkout, AppRoutes.orders];
        if (!loggedIn && guarded.contains(location)) {
          return AppRoutes.login;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: AppRouteNames.home,
          builder: (context, state) =>
              const AuthGate(child: MainShell()),
        ),
        for (final module in appModules) ...module.routes,
      ],
      // Fallback anti-crash untuk path tak dikenal.
      errorBuilder: (context, state) => const MainShell(),
    );
  },
  name: 'appRouterProvider',
);

/// Adaptor Stream -> Listenable untuk `refreshListenable` go_router.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen(
      (_) => notifyListeners(),
      onError: (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
