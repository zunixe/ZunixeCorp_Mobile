import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/catalog/presentation/product_detail_screen.dart';
import 'package:zunixe_corp_mobile/features/catalog/presentation/products_screen.dart';
import 'package:zunixe_corp_mobile/features/catalog/domain/entities/product.dart';

/// Rute fitur katalog: daftar produk penuh + detail produk.
class CatalogModule extends FeatureModule {
  const CatalogModule();

  @override
  String get name => 'catalog';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.productsFull,
          name: AppRouteNames.productsFull,
          builder: (context, state) => const ProductsScreen(isTab: false),
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
      ];
}
