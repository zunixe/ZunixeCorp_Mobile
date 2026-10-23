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
   Hasil: `build/app/outputs/bundle/release/app-release.aab` (AAB) atau
   `build/app/outputs/flutter-apk/app-release.apk` (APK).

   > **Signing:** build rilis memakai `android/key.properties` (lihat
   > `android/key.properties.example`). Tanpa file itu build **gagal** dengan
   > pesan jelas. Untuk build verifikasi lokal saja, jalankan
   > `ALLOW_DEBUG_SIGNING=true flutter build appbundle --release`; AAB debug
   > **ditolak** Play Console, jadi jangan diunggah.

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

- [ ] `dart format --output=none --set-exit-if-changed lib test tool`
- [ ] `flutter analyze` tanpa issue
- [ ] `dart run tool/check_imports.dart` lolos
- [ ] `flutter test` hijau & coverage >= 80%
- [ ] `version` di `pubspec.yaml` sudah naik (buildNumber naik)
- [ ] `develop-flutter` sudah di-merge ke `main`
- [ ] Build `.aab` dibuat **dari commit `main`**
- [ ] `android/key.properties` + keystore upload tersedia (bukan debug key)
- [ ] Migrasi Supabase terbaru sudah dijalankan (`migration_fase3.sql`, `migration_fase4.sql`)
- [ ] Bucket `payment-proofs` ada dan policy per-user aktif
- [ ] Upload bukti transfer + status "Menunggu verifikasi" diuji
- [ ] Deep link `zunixe://login-callback` diuji di perangkat (reset password + OAuth)
- [ ] Buka WhatsApp dari Chat, PaymentInfo, dan Tentang Kami di Android 11+
- [ ] Hapus akun diuji (Akun → Hapus Akun) dan data benar-benar hilang
- [ ] Kebijakan privasi punya URL publik untuk Play Console + Data Safety
- [ ] Diunggah ke Play Console + catatan rilis
- [ ] (Opsional) tag `vX.Y.Z` dibuat & di-push (memicu workflow Release)

## Backend

Data & pembayaran bergantung pada Supabase (tabel & RPC). Detail konfigurasi
ada di `supabase/CONFIG.md` (tanpa kredensial; nilai rahasia di
`supabase/.env.local` yang gitignored). Perubahan skema/RPC harus disiapkan
sebelum fitur dirilis agar aplikasi versi baru tidak menabrak backend lama.

RPC yang harus ada sebelum rilis: `place_order`, `cart_add`, `cancel_order`,
`delete_account`, `submit_payment_proof`. Jalankan
`supabase/migration_fase3.sql` (lock pembatalan, status `pending` sampai
dibayar, hapus akun, job `expire_unpaid_orders`) dan `migration_fase4.sql`
(kolom bukti transfer/resi, RPC, bucket `payment-proofs`).
