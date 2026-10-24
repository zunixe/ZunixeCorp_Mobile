import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/url_launcher_mock.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherMock urlLauncher;
  final clip = <String?>[];

  setUp(() {
    urlLauncher = UrlLauncherMock()..install();
    clip.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clip.add((call.arguments as Map)['text']?.toString());
      }
      return null;
    });
  });

  tearDown(() {
    urlLauncher.uninstall();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pump(WidgetTester tester,
      {String orderCode = 'INV-1', int total = 1250500}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaymentInfo(orderCode: orderCode, total: total),
        ),
      ),
    );
  }

  testWidgets('judul + total terformat tampil', (tester) async {
    await pump(tester);
    expect(find.text('Cara Bayar'), findsOneWidget);
    expect(find.text('1. Transfer Rp1.250.500 ke:'), findsOneWidget);
  });

  testWidgets('tanpa bank -> teks hubungi WhatsApp', (tester) async {
    await pump(tester);
    expect(
      find.text('Hubungi WhatsApp 0877-7771-1056 untuk nomor rekening.'),
      findsOneWidget,
    );
    // Tidak ada tombol "Salin" nomor rekening.
    expect(find.text('Salin'), findsNothing);
  });

  testWidgets('langkah konfirmasi + tombol WA tampil', (tester) async {
    await pump(tester);
    expect(find.text('2. Konfirmasi via WhatsApp (sertakan kode pesanan).'),
        findsOneWidget);
    expect(find.text('Konfirmasi via WhatsApp'), findsOneWidget);
  });

  testWidgets('tap tombol WA -> launchUrl konfirmasi', (tester) async {
    await pump(tester, orderCode: 'INV-7', total: 50000);
    await tester.tap(find.text('Konfirmasi via WhatsApp'));
    await tester.pump();
    expect(urlLauncher.launched, hasLength(1));
    final launched = Uri.parse(urlLauncher.launched.single);
    expect(launched.host, 'wa.me');
    expect(launched.path, contains('6287777711056'));
    final decoded = Uri.decodeComponent(urlLauncher.launched.single);
    expect(decoded, contains('INV-7'));
    expect(decoded, contains('Rp50.000'));
  });

  testWidgets('WA gagal dibuka -> snackbar error', (tester) async {
    urlLauncher.canLaunchResult = false;
    urlLauncher.launchResult = false;
    await pump(tester);
    await tester.tap(find.text('Konfirmasi via WhatsApp'));
    await tester.pump();
    // canLaunchUrl false -> snackbar merah.
    expect(find.text('Tidak dapat membuka WhatsApp'), findsOneWidget);
  });

  group('dengan data bank', () {
    Future<void> pumpBank(WidgetTester tester) {
      return tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentInfo(
              orderCode: 'INV-9',
              total: 100000,
              bankName: 'BCA',
              accountNumber: '1234567890',
              accountHolder: 'Budi Santoso',
            ),
          ),
        ),
      );
    }

    testWidgets('menampilkan bank + nomor + a.n. + tombol Salin',
        (tester) async {
      await pumpBank(tester);

      expect(find.text('BCA'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('a.n. Budi Santoso'), findsOneWidget);
      expect(find.text('Salin'), findsOneWidget);
      // Bagian "hubungi WA" tersembunyi saat bank tersedia.
      expect(
        find.text('Hubungi WhatsApp 0877-7771-1056 untuk nomor rekening.'),
        findsNothing,
      );
    });

    testWidgets('tap Salin -> snackbar konfirmasi', (tester) async {
      await pumpBank(tester);

      await tester.tap(find.text('Salin'));
      await tester.pump();
      await tester.pump();

      expect(find.text('No. rekening disalin'), findsOneWidget);
      expect(clip, contains('1234567890'));
    });

    testWidgets('nomor kosong -> sembunyikan blok bank', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentInfo(
              orderCode: 'INV-9',
              total: 100000,
              bankName: 'BCA',
              accountNumber: '',
              accountHolder: 'Budi',
            ),
          ),
        ),
      );

      expect(find.text('Salin'), findsNothing);
      expect(
        find.text('Hubungi WhatsApp 0877-7771-1056 untuk nomor rekening.'),
        findsOneWidget,
      );
    });
  });
}
