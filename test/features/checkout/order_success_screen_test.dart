import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/url_launcher_mock.dart';
import 'package:zunixe_corp_mobile/features/checkout/checkout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherMock urlLauncher;

  setUp(() {
    urlLauncher = UrlLauncherMock()..install();
    // Mock clipboard agar Clipboard.setData tidak MissingPluginException.
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

  Future<void> pump(WidgetTester tester,
      {String orderCode = 'INV-1', int total = 250000}) {
    return tester.pumpWidget(
      MaterialApp(
        home: OrderSuccessScreen(orderCode: orderCode, total: total),
      ),
    );
  }

  testWidgets('kode pesanan + total tampil', (tester) async {
    await pump(tester);
    expect(find.text('Terima kasih!'), findsOneWidget);
    expect(find.text('INV-1'), findsOneWidget);
    expect(find.text('Rp250.000'), findsWidgets);
  });

  testWidgets('PaymentInfo + tombol navigasi tampil', (tester) async {
    await pump(tester);
    expect(find.text('Cara Bayar'), findsOneWidget);
    expect(find.text('Lihat Pesanan Saya'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);
  });

  testWidgets('tap salin kode -> snackbar', (tester) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    expect(find.text('No. pesanan disalin'), findsOneWidget);
  });
}
