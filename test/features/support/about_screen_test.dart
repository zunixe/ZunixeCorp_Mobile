import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

import '../../helpers/url_launcher_mock.dart';

/// Cari RichText yang teks gabungannya mengandung [part].
Finder richTextContaining(String part) => find.byWidgetPredicate((w) {
      if (w is! RichText) return false;
      final span = w.text;
      return span.toPlainText().contains(part);
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherMock urlLauncher;

  setUp(() => urlLauncher = UrlLauncherMock()..install());
  tearDown(() => urlLauncher.uninstall());

  Future<void> pump(WidgetTester tester) {
    // Viewport tinggi agar seluruh konten (termasuk kontak di bawah)
    // terlihat tanpa scroll.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    return tester.pumpWidget(
      const MaterialApp(home: AboutScreen()),
    );
  }

  testWidgets('konten utama tampil', (tester) async {
    await pump(tester);
    expect(find.text('Selamat Datang di Zunixe Store'), findsOneWidget);
    expect(find.textContaining('CV Zunixe Berkah Jaya'), findsWidgets);
    expect(find.text('Komitmen Layanan Kami:'), findsOneWidget);
  });

  testWidgets('3 item layanan tampil', (tester) async {
    await pump(tester);
    expect(find.text('Produk berkualitas dengan harga terbaik'), findsOneWidget);
    expect(find.text('Pengiriman cepat & aman ke seluruh Indonesia'),
        findsOneWidget);
    expect(find.text('Dukungan teknis responsif'), findsOneWidget);
  });

  testWidgets('kontak tampil', (tester) async {
    await pump(tester);
    expect(richTextContaining('Mukodar'), findsOneWidget);
    expect(richTextContaining('0877-7771-1056'), findsOneWidget);
  });

  testWidgets('tap WhatsApp -> buka wa.me', (tester) async {
    await pump(tester);
    final target = richTextContaining('0877-7771-1056');
    await tester.tap(find.ancestor(of: target, matching: find.byType(InkWell)));
    await tester.pump();
    expect(urlLauncher.launched.single, 'https://wa.me/6287777711056');
  });

  testWidgets('tap alamat -> buka Google Maps', (tester) async {
    await pump(tester);
    final target = richTextContaining('Mukodar');
    await tester.tap(find.ancestor(of: target, matching: find.byType(InkWell)));
    await tester.pump();
    expect(urlLauncher.launched.single, contains('google.com/maps'));
  });
}
