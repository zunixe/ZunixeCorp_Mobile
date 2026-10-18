# Panduan Rilis — Zunixe Mobile (Flutter)

Dokumen ini menjelaskan alur dari development sampai unggah ke **Google Play**.

## Ringkas

- Semua pengembangan terjadi di branch **`develop-flutter`**.
- Rilis dibuat dengan **merge `develop-flutter` → `main`**.
- Artefak yang diunggah ke Play Store **wajib dibangun dari commit di `main`**.

## Langkah rilis

1. **Pastikan `develop-flutter` hijau**
   ```bash
   flutter analyze
   flutter test --coverage
   lcov --summary coverage/lcov.info   # target >= 80%
   ```
   CI pada branch harus lolos.

2. **Naikkan versi** di `pubspec.yaml`:
   ```yaml
   version: 1.1.0+2   # <semver>+<buildNumber> — buildNumber WAJIB naik setiap upload
   ```

3. **Commit & push** di `develop-flutter`.

4. **Merge ke `main`** (fast-forward atau merge commit):
   ```bash
   git checkout main
   git pull origin main
   git merge --no-ff develop-flutter
   git push origin main
   ```

5. **Build dari `main`** (pastikan berada di commit `main` terbaru):
   ```bash
   git checkout main && git pull
   flutter build appbundle --release        # Android App Bundle untuk Play Store
   # opsional: flutter build apk --release  # APK untuk distribusi langsung
   ```
   Hasil: `build/app/outputs/bundle/release/app-release.apk` (APK) atau
   `build/app/outputs/bundle/release/app-release.aab` (AAB).

6. **Unggah ke Play Console**
   - Buka Play Console → aplikasi Zunixe → Production → Create new release.
   - Upload `.aab` hasil build dari `main`.
   - Catatan rilis diisi, lalu review & roll out.

7. **Tag rilis** (opsional namun disarankan):
   ```bash
   git tag -a v1.1.0 -m "Rilis 1.1.0"
   git push origin v1.1.0
   ```

## Checklist

- [ ] `flutter analyze` tanpa issue
- [ ] `flutter test` hijau & coverage >= 80%
- [ ] `version` di `pubspec.yaml` sudah naik (buildNumber naik)
- [ ] `develop-flutter` sudah di-merge ke `main`
- [ ] Build `.aab` dibuat **dari commit `main`**
- [ ] Diunggah ke Play Console + catatan rilis
- [ ] (Opsional) tag `vX.Y.Z` dibuat & di-push

## Backend

Data & pembayaran bergantung pada Supabase (tabel & RPC). Detail konfigurasi
ada di `supabase/` (dokumen internal; kredensial tidak disimpan di repo publik).
Perubahan skema/RPC harus disiapkan sebelum fitur dirilis agar aplikasi versi
baru tidak menabrak backend lama.
