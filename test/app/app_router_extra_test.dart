import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/app/main_shell.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/checkout/checkout.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

import '../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  testWidgets('order-success tanpa extra -> redirect ke home', (tester) async {
    final h = await pumpRouter(
      tester,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
    );

    h.router.go(AppRoutes.orderSuccess);
    await tester.pump();
    await tester.pump();

    expect(h.router.state.matchedLocation, AppRoutes.home);
    expect(find.byType(OrderSuccessScreen), findsNothing);
  });

  testWidgets('order-success dengan extra -> OrderSuccessScreen',
      (tester) async {
    final h = await pumpRouter(
      tester,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
    );

    h.router.push(
      AppRoutes.orderSuccess,
      extra: const OrderConfirmation(orderCode: 'INV-9', total: 75000),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(OrderSuccessScreen), findsOneWidget);
    expect(find.textContaining('INV-9'), findsWidgets);
  });

  testWidgets('product detail via path id -> ProductDetailScreen',
      (tester) async {
    final productRepo = stubEmptyProducts();
    when(() => productRepo.getProductById(any()))
        .thenAnswer((_) async => const Ok(null));
    final h = await pumpRouter(
      tester,
      cartRepo: stubEmptyCart(),
      productRepo: productRepo,
    );

    h.router.go('${AppRoutes.productDetailBase}/abc123');
    await tester.pump();
    await tester.pump();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
  });

  testWidgets('legal slug -> LegalScreen dengan slug dari path',
      (tester) async {
    final h = await pumpRouter(
      tester,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
    );

    h.router.go('${AppRoutes.legalBase}/privacy');
    await tester.pump();
    await tester.pump();

    expect(find.byType(LegalScreen), findsOneWidget);
  });

  testWidgets('path tak dikenal -> errorBuilder MainShell', (tester) async {
    final h = await pumpRouter(
      tester,
      cartRepo: stubEmptyCart(),
      productRepo: stubEmptyProducts(),
    );

    h.router.go('/route-yang-tidak-ada');
    await tester.pump();
    await tester.pump();

    expect(find.byType(MainShell), findsWidgets);
  });
}
