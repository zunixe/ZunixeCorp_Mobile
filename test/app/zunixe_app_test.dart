import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/main.dart';

import '../helpers/riverpod_scope.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.newest);
  });

  testWidgets('ZunixeApp boot -> MaterialApp.router + theme brand tampil',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo()),
        cartRepositoryProvider.overrideWithValue(stubEmptyCart()),
        productRepositoryProvider.overrideWithValue(stubEmptyProducts()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ZunixeApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'zunixe.com');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.theme?.textTheme.bodyMedium?.fontFamily, 'Ubuntu');
    expect(app.theme?.primaryColor, AppColors.brand);
    expect(app.theme?.colorScheme.primary, AppColors.brand);
    expect(app.theme?.scaffoldBackgroundColor, AppColors.background);
  });
}