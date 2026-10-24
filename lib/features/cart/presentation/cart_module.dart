import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_screen.dart';

/// Rute fitur keranjang.
class CartModule extends FeatureModule {
  const CartModule();

  @override
  String get name => 'cart';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.cart,
          name: AppRouteNames.cart,
          builder: (context, state) => CartScreen(
            onSwitchToProduk: () => context.pop(),
          ),
        ),
      ];
}
