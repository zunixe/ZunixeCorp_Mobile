import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/features/support/support.dart';

import '../../helpers/url_launcher_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherMock urlLauncher;

  setUp(() {
    urlLauncher = UrlLauncherMock()..install();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') return null;
      return null;
    });
  });

  tearDown(() {
    urlLauncher.uninstall();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(home: ChatScreen()),
    );
  }

  testWidgets('pesan sambutan tampil', (tester) async {
    await pump(tester);
    expect(find.text('Halo! Selamat datang di Zunixe Store.'), findsOneWidget);
    expect(find.text('Ada yang bisa kami bantu?'), findsOneWidget);
    expect(find.text('Ketik pesan...'), findsOneWidget);
  });

  testWidgets('kirim pesan -> bubble kanan + auto-reply 2 detik', (tester) async {
    await pump(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Ketik pesan...'), 'Halo admin');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text('Halo admin'), findsOneWidget);

    // Auto-reply datang setelah 2 detik.
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Terima kasih! Pesan Anda tercatat'),
        findsOneWidget);
  });

  testWidgets('pesan kosong tidak terkirim', (tester) async {
    await pump(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Ketik pesan...'), '   ');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    // Hanya 2 pesan awal.
    expect(find.text('Halo admin'), findsNothing);
  });

  testWidgets('tap tombol WA hijau -> buka wa.me', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Chat via WhatsApp  0877-7771-1056'));
    await tester.pump();
    expect(urlLauncher.launched.single, 'https://wa.me/6287777711056');
  });

  testWidgets('waktu tampil format HH:MM', (tester) async {
    await pump(tester);
    // Setiap bubble punya timestamp dua digit.
    expect(find.textContaining(RegExp(r'^\d{2}:\d{2}$')), findsWidgets);
  });
}
