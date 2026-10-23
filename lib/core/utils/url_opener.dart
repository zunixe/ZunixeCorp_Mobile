import 'package:url_launcher/url_launcher.dart';

/// Buka URL di aplikasi eksternal tanpa memanggil `canLaunchUrl`.
///
/// Sejak Android 11, `canLaunchUrl` dapat mengembalikan false walaupun ada
/// aplikasi yang bisa menangani URL (package visibility). `launchUrl` sendiri
/// tidak memerlukan izin tersebut, jadi kita coba langsung dan tangani
/// kegagalannya.
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
