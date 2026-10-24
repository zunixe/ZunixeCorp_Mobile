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

  testWidgets('network loadingBuilder: progress null -> child', (tester) async {
    await pump(tester, 'https://example.com/a.png');
    final img = tester.widget<Image>(find.byType(Image));
    final ctx = tester.element(find.byType(Image));

    final rendered =
        img.loadingBuilder!(ctx, const SizedBox(key: Key('child')), null);

    await tester.pumpWidget(MaterialApp(home: rendered));
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets('network loadingBuilder: progress -> spinner', (tester) async {
    await pump(tester, 'https://example.com/a.png');
    final img = tester.widget<Image>(find.byType(Image));
    final ctx = tester.element(find.byType(Image));

    final rendered = img.loadingBuilder!(
      ctx,
      const SizedBox(),
      const ImageChunkEvent(cumulativeBytesLoaded: 1, expectedTotalBytes: 10),
    );

    await tester.pumpWidget(MaterialApp(home: rendered));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('network errorBuilder -> placeholder', (tester) async {
    await pump(tester, 'https://example.com/a.png');
    final img = tester.widget<Image>(find.byType(Image));
    final ctx = tester.element(find.byType(Image));

    final rendered =
        img.errorBuilder!(ctx, Exception('gagal'), StackTrace.empty);

    await tester.pumpWidget(MaterialApp(home: rendered));
    expect(find.byIcon(Icons.image), findsOneWidget);
  });

  testWidgets('asset errorBuilder -> placeholder', (tester) async {
    await pump(tester, 'assets/logo.png');
    final img = tester.widget<Image>(find.byType(Image));
    final ctx = tester.element(find.byType(Image));

    final rendered =
        img.errorBuilder!(ctx, Exception('gagal'), StackTrace.empty);

    await tester.pumpWidget(MaterialApp(home: rendered));
    expect(find.byIcon(Icons.image), findsOneWidget);
  });
}
