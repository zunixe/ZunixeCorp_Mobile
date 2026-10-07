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

  testWidgets('intro support + field pesan tampil', (tester) async {
    await pump(tester);
    expect(find.text('Zunixe Support'), findsOneWidget);
    expect(find.text('Butuh bantuan?'), findsOneWidget);
    expect(find.textContaining('Senin – Sabtu'), findsOneWidget);
    expect(find.text('Ketik pesan…'), findsOneWidget);
  });

  testWidgets('kirim pesan -> buka WhatsApp dengan teks terisi',
      (tester) async {
    await pump(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Ketik pesan…'), 'Halo admin');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(urlLauncher.launched, hasLength(1));
    final launched = urlLauncher.launched.single;
    expect(launched, startsWith('https://wa.me/6287777711056?text='));
    expect(Uri.decodeComponent(launched), contains('Halo admin'));
  });

  testWidgets('pesan kosong -> buka WhatsApp tanpa teks', (tester) async {
    await pump(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Ketik pesan…'), '   ');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(urlLauncher.launched.single, 'https://wa.me/6287777711056');
  });

  testWidgets('tap tombol WA hijau -> buka wa.me', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Chat via WhatsApp  0877-7771-1056'));
    await tester.pump();
    expect(urlLauncher.launched.single, 'https://wa.me/6287777711056');
  });

  testWidgets('tidak ada riwayat chat palsu (jujur)', (tester) async {
    await pump(tester);
    expect(find.textContaining('Terima kasih! Pesan Anda tercatat'),
        findsNothing);
    expect(find.textContaining('tidak menyimpan riwayat chat'), findsOneWidget);
  });
}
