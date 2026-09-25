import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

void main() {
  Future<void> pump(WidgetTester tester, String slug) {
    return tester.pumpWidget(
      MaterialApp(home: LegalScreen(slug: slug)),
    );
  }

  testWidgets('tos -> judul + body', (tester) async {
    await pump(tester, 'tos');
    expect(find.text('Persyaratan Layanan'), findsOneWidget);
    expect(find.textContaining('Harga dan stok dapat berubah'), findsOneWidget);
  });

  testWidgets('privacy', (tester) async {
    await pump(tester, 'privacy');
    expect(find.text('Kebijakan Privasi'), findsOneWidget);
    expect(find.textContaining('tidak dibagikan ke pihak ketiga'),
        findsOneWidget);
  });

  testWidgets('shipping', (tester) async {
    await pump(tester, 'shipping');
    expect(find.text('Kebijakan Pengiriman'), findsOneWidget);
    expect(find.textContaining('GRATIS'), findsOneWidget);
  });

  testWidgets('returns', (tester) async {
    await pump(tester, 'returns');
    expect(find.text('Kebijakan Pengembalian'), findsOneWidget);
  });

  testWidgets('ip', (tester) async {
    await pump(tester, 'ip');
    expect(find.text('Kebijakan KI'), findsOneWidget);
  });

  testWidgets('slug tak dikenal -> fallback tos', (tester) async {
    await pump(tester, 'ngawur');
    expect(find.text('Persyaratan Layanan'), findsOneWidget);
  });

  testWidgets('AppHeader tampil dengan tombol kembali', (tester) async {
    await pump(tester, 'tos');
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
