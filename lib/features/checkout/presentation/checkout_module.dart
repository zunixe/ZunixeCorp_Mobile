import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/checkout/presentation/checkout_screen.dart';
import 'package:zunixe_corp_mobile/features/checkout/presentation/order_success_screen.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';

/// Rute fitur checkout + layar sukses pesanan.
class CheckoutModule extends FeatureModule {
  const CheckoutModule();

  @override
  String get name => 'checkout';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.checkout,
          name: AppRouteNames.checkout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: AppRoutes.orderSuccess,
          name: AppRouteNames.orderSuccess,
          // Tanpa data konfirmasi → pulang ke beranda (bukan render shell).
          redirect: (context, state) =>
              state.extra is OrderConfirmation ? null : AppRoutes.home,
          builder: (context, state) {
            final extra = state.extra as OrderConfirmation;
            return OrderSuccessScreen(
              orderCode: extra.orderCode,
              total: extra.total,
            );
          },
        ),
      ];
}
