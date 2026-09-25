import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    String title = 'zunixe',
    String? subtitle,
    bool showBack = false,
    bool showMenu = false,
    bool showSearch = true,
    bool showCart = true,
    int cartCount = 0,
    bool showProfile = true,
    VoidCallback? onBack,
    VoidCallback? onSearch,
    VoidCallback? onCart,
    VoidCallback? onProfile,
    List<Widget>? trailing,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppHeader(
            title: title,
            subtitle: subtitle,
            showBack: showBack,
            onBack: onBack,
            showMenu: showMenu,
            showSearch: showSearch,
            onSearch: onSearch,
            showCart: showCart,
            cartCount: cartCount,
            onCart: onCart,
            showProfile: showProfile,
            onProfile: onProfile,
            trailing: trailing,
          ),
        ),
      ),
    );
  }

  testWidgets('title + subtitle tampil', (tester) async {
    await pump(tester, title: 'Keranjang', subtitle: 'Sub info');
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Sub info'), findsOneWidget);
  });

  testWidgets('ikon search/cart/profile tampil sesuai flag', (tester) async {
    await pump(tester);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('flag false menyembunyikan aksi', (tester) async {
    await pump(tester, showSearch: false, showCart: false, showProfile: false);
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsNothing);
    expect(find.byIcon(Icons.person_outline), findsNothing);
  });

  testWidgets('cartCount > 0 -> badge angka', (tester) async {
    await pump(tester, cartCount: 3);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('cartCount 0 -> tanpa badge', (tester) async {
    await pump(tester, cartCount: 0);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('showBack -> tombol kembali', (tester) async {
    await pump(tester,
        showBack: true, title: 'Detail', showSearch: false, showCart: false, showProfile: false);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
  });

  testWidgets('onSearch dipanggil saat tap cari', (tester) async {
    var called = false;
    await pump(tester, onSearch: () => called = true);
    await tester.tap(find.byIcon(Icons.search));
    expect(called, isTrue);
  });

  testWidgets('onCart dipanggil saat tap keranjang', (tester) async {
    var called = false;
    await pump(tester, onCart: () => called = true);
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    expect(called, isTrue);
  });

  testWidgets('showMenu -> tombol menu', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          drawer: Drawer(),
          body: AppHeader(title: 'Home', showMenu: true),
        ),
      ),
    );
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('trailing dirender', (tester) async {
    await pump(tester,
        showSearch: false,
        showCart: false,
        showProfile: false,
        trailing: [const Icon(Icons.call)]);
    expect(find.byIcon(Icons.call), findsOneWidget);
  });
}
