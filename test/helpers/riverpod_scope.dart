import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/core/result.dart';
import 'package:zunixe_corp_mobile/app/app_router.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';

/// Mock [AuthRepository] bersama untuk widget/screen test Riverpod.
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock [CartRepository] bersama untuk widget/screen test Riverpod.
class MockCartRepository extends Mock implements CartRepository {}

/// Mock [ProductRepository] bersama untuk widget/screen test Riverpod.
class MockProductRepository extends Mock implements ProductRepository {}

/// Mock [OrderRepository] bersama untuk widget/screen test Riverpod.
class MockOrderRepository extends Mock implements OrderRepository {}

/// Cart repo kosong (fetch -> []) untuk test yang butuh shell/home.
MockCartRepository stubEmptyCart() {
  final repo = MockCartRepository();
  when(() => repo.fetchCart(any()))
      .thenAnswer((_) async => const Result.ok([]));
  return repo;
}

/// Product repo kosong untuk test yang butuh shell/home.
MockProductRepository stubEmptyProducts() {
  final repo = MockProductRepository();
  when(() => repo.getProducts(
        search: any(named: 'search'),
        category: any(named: 'category'),
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
      )).thenAnswer((_) async => const Result.ok([]));
  when(() => repo.getCategories())
      .thenAnswer((_) async => const Result.ok([]));
  return repo;
}

/// Buat mock repo dengan user + stream default (kosong).
MockAuthRepository mockAuthRepo({User? user, Stream<AuthState>? stream}) {
  final repo = MockAuthRepository();
  when(() => repo.currentUser).thenReturn(user);
  when(() => repo.onAuthStateChange)
      .thenAnswer((_) => stream ?? const Stream<AuthState>.empty());
  when(() => repo.getProfile(any())).thenAnswer((_) async => null);
  when(() => repo.saveProfile(
        userId: any(named: 'userId'),
        fullName: any(named: 'fullName'),
        phone: any(named: 'phone'),
      )).thenAnswer((_) async {});
  return repo;
}

/// Pump widget dalam `ProviderScope` dengan override repository auth.
Future<void> pumpRiverpod(
  WidgetTester tester,
  Widget child, {
  AuthRepository? authRepository,
  Map<String, WidgetBuilder>? routes,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (authRepository != null)
          authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: MaterialApp(home: child, routes: routes ?? const {}),
    ),
  );
}

/// Pump aplikasi dengan router nyata (go_router) + override repository.
///
/// [initialLocation] dinavigasikan setelah frame pertama. Mengembalikan
/// container agar test bisa memicu aksi lanjutan (mis. `container.read`).
Future<ProviderContainer> pumpRouter(
  WidgetTester tester, {
  MockAuthRepository? authRepo,
  MockCartRepository? cartRepo,
  MockProductRepository? productRepo,
  MockOrderRepository? orderRepo,
  String initialLocation = '/',
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
          authRepo ?? mockAuthRepo()),
      if (cartRepo != null)
        cartRepositoryProvider.overrideWithValue(cartRepo),
      if (productRepo != null)
        productRepositoryProvider.overrideWithValue(productRepo),
      if (orderRepo != null)
        orderRepositoryProvider.overrideWithValue(orderRepo),
    ],
  );
  addTearDown(container.dispose);
  final router = container.read(appRouterProvider);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  if (initialLocation != '/') {
    router.go(initialLocation);
    await tester.pump();
    await tester.pump();
  }
  return container;
}
