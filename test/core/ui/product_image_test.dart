import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/ui/product_image.dart';

void main() {
  Future<void> pump(WidgetTester tester, String url) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductImage(url: url, iconSize: 24)),
      ),
    );
  }

  testWidgets('url kosong -> placeholder icon', (tester) async {
    await pump(tester, '');
    expect(find.byIcon(Icons.image), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('url http -> Image widget dirender', (tester) async {
    await pump(tester, 'https://example.com/a.png');
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('url asset -> Image.asset dirender', (tester) async {
    await pump(tester, 'assets/logo.png');
    // Image.asset dengan file tak ada akan errorBuilder -> placeholder.
    await tester.pump();
    expect(find.byType(ProductImage), findsOneWidget);
  });
}
