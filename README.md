# Zunixe Mobile

Aplikasi Flutter **Zunixe Store** — katalog produk elektronik/IoT dengan
keranjang, checkout transfer manual, pesanan, dan dukungan WhatsApp.
Backend: Supabase (PostgREST + RPC). State: Riverpod. Navigasi: go_router.

Arsitektur lengkap: lihat [ARCHITECTURE.md](ARCHITECTURE.md).

## Menjalankan

```bash
flutter pub get
flutter run
```

## Test & lint

```bash
flutter analyze                     # harus 0 issue
dart run tool/check_imports.dart    # batas modul antar-fitur
flutter test                        # seluruh unit + widget test
flutter test --coverage             # + laporan coverage (coverage/lcov.info)
bash tool/check_coverage.sh         # gate coverage baris >= 80%
```

CI (`.github/workflows/ci.yml`) menjalankan `analyze` + `test --coverage` untuk
setiap push/PR ke `main` dan `develop-flutter`, dan **gagal bila coverage baris
< 80%**.

## Alur branch & rilis

| Branch            | Peran                                                            |
| ----------------- | ---------------------------------------------------------------- |
| `develop-flutter` | **Kerja harian** — semua fitur & test ditulis di sini.           |
| `main`            | **Rilis** — hanya menerima merge dari `develop-flutter`.          |
| `native-android`  | Arsip rewrite native (Kotlin/Compose); tidak dikembangkan lagi.   |

Aturan:

1. Develop di `develop-flutter`.
2. Saat siap terbit, merge `develop-flutter` → `main`.
3. **Yang di-upload ke Google Play adalah build dari commit di `main`.**

Detail langkah rilis: [docs/RELEASE.md](docs/RELEASE.md).
