import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

void main() {
  group('AppRoutes — path', () {
    test('path statis', () {
      expect(AppRoutes.home, '/');
      expect(AppRoutes.about, '/about');
      expect(AppRoutes.productsFull, '/products-full');
      expect(AppRoutes.cart, '/cart');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.checkout, '/checkout');
      expect(AppRoutes.orders, '/orders');
      expect(AppRoutes.chat, '/chat');
      expect(AppRoutes.account, '/account');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.resetPassword, '/reset-password');
      expect(AppRoutes.orderSuccess, '/order-success');
    });

    test('path berpola punya base yang konsisten', () {
      expect(AppRoutes.productDetail, '/product/:id');
      expect(AppRoutes.productDetailBase, '/product');
      expect(AppRoutes.productDetail, startsWith(AppRoutes.productDetailBase));

      expect(AppRoutes.legal, '/legal/:slug');
      expect(AppRoutes.legalBase, '/legal');
      expect(AppRoutes.legal, startsWith(AppRoutes.legalBase));
    });

    test('skema deep-link OAuth', () {
      expect(AppRoutes.oauthCallbackScheme, 'zunixe://login-callback');
    });

    test('tidak ada path duplikat', () {
      final paths = <String>[
        AppRoutes.home,
        AppRoutes.about,
        AppRoutes.productsFull,
        AppRoutes.cart,
        AppRoutes.login,
        AppRoutes.checkout,
        AppRoutes.orders,
        AppRoutes.chat,
        AppRoutes.account,
        AppRoutes.register,
        AppRoutes.resetPassword,
        AppRoutes.orderSuccess,
      ];
      expect(paths.toSet(), hasLength(paths.length));
    });
  });

  group('AppRouteNames — nama logis', () {
    test('nama route terdefinisi', () {
      expect(AppRouteNames.home, 'home');
      expect(AppRouteNames.about, 'about');
      expect(AppRouteNames.productsFull, 'productsFull');
      expect(AppRouteNames.cart, 'cart');
      expect(AppRouteNames.login, 'login');
      expect(AppRouteNames.checkout, 'checkout');
      expect(AppRouteNames.orders, 'orders');
      expect(AppRouteNames.chat, 'chat');
      expect(AppRouteNames.account, 'account');
      expect(AppRouteNames.register, 'register');
      expect(AppRouteNames.resetPassword, 'resetPassword');
      expect(AppRouteNames.orderSuccess, 'orderSuccess');
      expect(AppRouteNames.productDetail, 'productDetail');
      expect(AppRouteNames.legal, 'legal');
    });

    test('tidak ada nama duplikat', () {
      final names = <String>[
        AppRouteNames.home,
        AppRouteNames.about,
        AppRouteNames.productsFull,
        AppRouteNames.cart,
        AppRouteNames.login,
        AppRouteNames.checkout,
        AppRouteNames.orders,
        AppRouteNames.chat,
        AppRouteNames.account,
        AppRouteNames.register,
        AppRouteNames.resetPassword,
        AppRouteNames.orderSuccess,
        AppRouteNames.productDetail,
        AppRouteNames.legal,
      ];
      expect(names.toSet(), hasLength(names.length));
    });
  });
}