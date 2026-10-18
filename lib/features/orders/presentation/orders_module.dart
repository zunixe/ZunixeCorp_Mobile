import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/orders/presentation/orders_screen.dart';

/// Rute fitur pesanan.
class OrdersModule extends FeatureModule {
  const OrdersModule();

  @override
  String get name => 'orders';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.orders,
          name: AppRouteNames.orders,
          builder: (context, state) => const OrdersScreen(),
        ),
      ];
}
