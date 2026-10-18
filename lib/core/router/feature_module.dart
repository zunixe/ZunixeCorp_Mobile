import 'package:go_router/go_router.dart';

/// Kontrak **modul fitur** — satu-satunya cara fitur menyumbang rute ke
/// aplikasi. `app_router.dart` menyusun router dari daftar modul, sehingga
/// menambah/menghapus fitur cukup mengubah satu baris di sana.
///
/// Modul TIDAK boleh mengimpor `app/**` (lihat `tool/check_imports.dart`);
/// bila butuh "pulang" ke beranda, gunakan `redirect` ke [AppRoutes.home].
abstract class FeatureModule {
  const FeatureModule();

  /// Nama modul (untuk log/diagnostik).
  String get name;

  /// Rute yang dimiliki fitur ini.
  List<RouteBase> get routes;
}
