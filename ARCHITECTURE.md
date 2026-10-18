# Arsitektur Zunixe Mobile

Aplikasi Flutter (Zunixe Store) dengan **modularitas per fitur** (clean
architecture), **Riverpod** untuk state, **go_router** untuk navigasi, dan
**Supabase** sebagai backend.

Batas antar-modul **ditegakkan otomatis** oleh `tool/check_imports.dart`
(dijalankan di CI) — bukan sekadar konvensi.

## Struktur

```
lib/
  main.dart                # bootstrap (Supabase.initialize + runApp)
  app/                     # COMPOSITION ROOT (satu-satunya tempat yang
    app_router.dart        #   boleh merangkai semua fitur)
    main_shell.dart        # shell tab (Home/Produk/Keranjang/Akun/Chat)
  core/                    # kode bersama; TIDAK boleh impor features/ atau app/
    config/                # StoreConfig (kontak & pembayaran toko)
    network/               # supabaseClientProvider (satu-satunya akses singleton)
    result.dart            # Result<T> (Ok/Err) + Failure berpesan ID
    router/                # AppRoutes, AppRouteNames, FeatureModule (kontrak modul)
    theme/                 # AppColors — satu-satunya sumber warna
    ui/                    # design system: button, header, image, logo
    utils/                 # formatRupiah, serverMessage
  features/<fitur>/
    <fitur>.dart           # BARREL — satu-satunya API publik fitur
    domain/                # entities, repository interface, logika murni
    data/                  # implementasi Supabase dari interface domain
    presentation/          # screens, widgets, notifiers/providers, <fitur>_module.dart
```

Fitur: `auth`, `catalog`, `cart`, `checkout`, `orders`, `home`, `support`.

## Kontrak modul

Setiap fitur yang punya rute menyediakan satu `FeatureModule`
(`lib/core/router/feature_module.dart`) di `presentation/<fitur>_module.dart`:

```dart
class CartModule extends FeatureModule {
  const CartModule();
  @override String get name => 'cart';
  @override List<RouteBase> get routes => [ /* GoRoute... */ ];
}
```

`app_router.dart` merangkai semuanya dari satu daftar:

```dart
const appModules = [
  AuthModule(), CatalogModule(), CartModule(),
  CheckoutModule(), OrdersModule(), SupportModule(),
];
```

Menambah/menghapus fitur = ubah daftar itu (satu baris). Rute `"/"` (shell) dan
kebijakan `redirect` (guard auth) tetap dimiliki lapisan `app`.

## Aturan dependensi (ditegakkan `tool/check_imports.dart`)

1. **Lintas-fitur hanya lewat barrel** (`features/<b>/<b>.dart`), dilarang
   menembus `features/<b>/{domain,data,presentation}/**`.
2. **`core/**` tidak boleh impor `features/**` maupun `app/**`.**
3. **`features/**` tidak boleh impor `app/**`.** Butuh "pulang" ke beranda?
   Pakai `redirect` ke `AppRoutes.home`.
4. **Graf impor antar-fitur wajib bebas siklus (asiklik).**
5. **`**/domain/**` tidak boleh impor `**/data/**` atau `**/presentation/**`.**

Graf target (asiklik):

```
core → (tidak ada)
auth → core
catalog → core, cart
cart → core, auth
orders → core
checkout → core, auth, cart, orders
support → core
home → core, auth, cart, catalog
app (shell + router) → semua barrel
```

Jalankan pemeriksa kapan saja:

```bash
dart run tool/check_imports.dart
```

## State (Riverpod)

```
supabaseClientProvider
  -> authRepositoryProvider -> authNotifierProvider (AuthSessionState)
  -> cartRepositoryProvider -> cartNotifierProvider (CartState, auto-sync user)
  -> productRepositoryProvider (dipakai langsung oleh UI katalog/home)
  -> orderRepositoryProvider (dipakai langsung oleh UI orders/checkout)
appRouterProvider (redirect guard checkout/orders + refresh saat event auth)
```

- `AuthSessionState`: user (`AppUser?`), isLoading, error, lastMethod.
- `CartState`: items, loading, error, needsLogin + `itemCount`/`totalPrice`.
- Test: `ProviderContainer` + `*.overrideWithValue(mock)`;
  navigasi: helper `pumpRouter` (`test/helpers/riverpod_scope.dart`).

## Menambah fitur baru

1. Buat `lib/features/<nama>/{<nama>.dart,domain,data,presentation}`.
2. Definisikan entity + repository interface di `domain/`.
3. Implementasikan di `data/` (`*_supabase.dart`, ctor `({SupabaseClient? client})`).
4. Daftarkan `XxxRepositoryProvider` di `presentation/` + export di barrel.
5. Bila punya layar: buat `presentation/<nama>_module.dart` (`FeatureModule`),
   export di barrel, lalu tambahkan modulnya ke `appModules` di `app/app_router.dart`.
6. Tulis test di `test/features/<nama>/` memakai mock interface
   (lihat `MockAuthRepository` di `test/helpers/riverpod_scope.dart`).
7. `dart run tool/check_imports.dart` harus lolos.

## Catatan penempatan

- **`MainShell` ada di `app/`** (bukan `home`) karena ia merangkai tab dari
  beberapa fitur — itu tanggung jawab composition root.
- **`PaymentInfo` ada di `orders/`** (dipakai `orders` dan `checkout`); ini
  yang membuat `orders` tidak lagi bergantung pada `checkout`.
- **`AddToCartButton` (di `cart`) tidak tahu tipe `Product`** — cukup
  `productId`/`productName`/`stock`. Ini yang membuat `cart` tidak bergantung
  pada `catalog` (memutus siklus `catalog ↔ cart`).

## Verifikasi wajib

```bash
flutter analyze                    # 0 issue
dart run tool/check_imports.dart   # batas modul lolos
flutter test --coverage            # semua hijau
bash tool/check_coverage.sh        # coverage baris >= 80%
```
