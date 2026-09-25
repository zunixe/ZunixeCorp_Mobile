# Arsitektur Zunixe Mobile

Aplikasi Flutter (Zunixe Store) dengan **clean architecture per fitur**,
**Riverpod** untuk state, **go_router** untuk navigasi, dan **Supabase**
sebagai backend.

## Struktur

```
lib/
  main.dart                # bootstrap (Supabase.initialize + runApp)
  app/
    app_router.dart        # go_router: rute + guard auth (redirect)
  core/                    # kode bersama; TIDAK boleh impor features/
    config/                # StoreConfig (kontak & pembayaran toko)
    network/               # supabaseClientProvider (satu-satunya akses singleton)
    result.dart            # Result<T> (Ok/Err) + Failure berpesan ID
    router/                # AppRoutes (path) + AppRouteNames (nama)
    theme/                 # AppColors — satu-satunya sumber warna
    ui/                    # design system: button, header, image, logo
    utils/                 # formatRupiah, serverMessage
  features/<fitur>/
    <fitur>.dart           # BARREL — satu-satunya API publik fitur
    domain/                # entities, repository interface, logika murni
    data/                  # implementasi Supabase dari interface domain
    presentation/          # screens, widgets, notifiers/providers Riverpod
```

Fitur: `auth`, `catalog`, `cart`, `checkout`, `orders`, `home`, `support`.

## Aturan dependensi

1. **Fitur lain hanya boleh mengimpor barrel** (`features/cart/cart.dart`),
   bukan file di `domain/`, `data/`, atau `presentation/` fitur lain.
2. **Domain tidak mengimpor Flutter UI maupun Supabase** — kecuali
   `auth` yang sementara memakai tipe GoTrue agar adapter lama kompatibel
   (target akhir: entity `AppUser` penuh).
3. **Singleton `Supabase.instance` hanya di** `core/network` dan
   konstruktor default `*_repository_supabase.dart`. UI dan domain
   dilarang menyentuhnya langsung.
4. **Navigasi antar-fitur hanya lewat router** (`context.push/go` +
   `AppRoutes`); dilarang mengimpor screen fitur lain.
5. **Warna hanya via `AppColors`**; route hanya via `AppRoutes`.

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
5. Tambahkan rute di `app_router.dart` bila perlu layar.
6. Tulis test di `test/features/<nama>/` memakai mock interface
   (lihat `MockAuthRepository` di `test/helpers/riverpod_scope.dart`).

## Catatan migrasi (strangler, selesai)

- Dihapus: `providers/` (ChangeNotifier), `services/` (adapter lama),
  `screens/`, `widgets/`, `models/`, paket `provider`,
  widget `RequireLogin` (diganti redirect router).
- `serverMessage` (`core/utils/errors.dart`) dipertahankan untuk kompatibilitas;
  kode baru memakai `Failure.from`.
