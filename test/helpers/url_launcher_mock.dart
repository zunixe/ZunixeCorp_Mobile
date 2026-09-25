import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kontrol platform channel `url_launcher` di test.
///
/// Channel yang dipakai `url_launcher_platform_interface`:
/// `plugins.flutter.io/url_launcher` dengan method `canLaunch` dan `launch`.
/// (`launchUrl` versi 6.x langsung memanggil `launch` tanpa `canLaunch`.)
class UrlLauncherMock {
  UrlLauncherMock({this.canLaunchResult = true, this.launchResult = true});

  /// Hasil `canLaunch(url)`.
  bool canLaunchResult;

  /// Hasil `launch(url)` (dipakai juga oleh `launchUrl`).
  bool launchResult;

  /// URL yang pernah diminta diluncurkan (via method `launch`).
  final List<String> launched = [];

  static const _channel = MethodChannel('plugins.flutter.io/url_launcher');

  /// Pasang handler. Membutuhkan binding test
  /// (`TestWidgetsFlutterBinding.ensureInitialized()`).
  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      switch (call.method) {
        case 'canLaunch':
          return canLaunchResult;
        case 'launch':
          final args = (call.arguments as Map).cast<Object?, Object?>();
          launched.add(args['url']?.toString() ?? '');
          return launchResult;
      }
      return null;
    });
  }

  /// Lepas handler.
  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}
