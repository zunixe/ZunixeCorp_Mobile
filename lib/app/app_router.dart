import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/checkout/checkout.dart';
import 'package:zunixe_corp_mobile/features/home/home.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

/// Router aplikasi (go_router). Guard auth untuk checkout/orders via
/// [redirect] — menggantikan widget `RequireLogin` manual.
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
        GoRoute(
          path: AppRoutes.about,
          name: AppRouteNames.about,
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: AppRoutes.productsFull,
          name: AppRouteNames.productsFull,
          builder: (context, state) =>
              const ProductsScreen(isTab: false),
        ),
        GoRoute(
          path: AppRoutes.cart,
          name: AppRouteNames.cart,
          builder: (context, state) => CartScreen(
            onSwitchToProduk: () => context.pop(),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.checkout,
          name: AppRouteNames.checkout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: AppRoutes.orders,
          name: AppRouteNames.orders,
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          name: AppRouteNames.chat,
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: AppRoutes.account,
          name: AppRouteNames.account,
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: AppRouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          name: AppRouteNames.resetPassword,
          builder: (context, state) => const ResetPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.orderSuccess,
          name: AppRouteNames.orderSuccess,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is OrderConfirmation) {
              return OrderSuccessScreen(
                orderCode: extra.orderCode,
                total: extra.total,
              );
            }
            // Tanpa data konfirmasi: kembali ke home.
            return const MainShell();
          },
        ),
        GoRoute(
          path: AppRoutes.productDetail,
          name: AppRouteNames.productDetail,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Product) {
              return ProductDetailScreen(product: extra);
            }
            return ProductDetailScreen(
              productId: state.pathParameters['id'],
            );
          },
        ),
        GoRoute(
          path: AppRoutes.legal,
          name: AppRouteNames.legal,
          builder: (context, state) => LegalScreen(
            slug: state.pathParameters['slug'] ?? 'tos',
          ),
        ),
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
