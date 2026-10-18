# Arsitektur Zunixe Mobile — Android Native

Aplikasi Android **native** (Kotlin + Jetpack Compose) untuk Zunixe Store.
Branch: `native-android`. Versi Flutter lama diarsipkan di branch `main`.

## Stack

| Lapis | Teknologi |
|---|---|
| UI | Jetpack Compose + Material 3 |
| State | ViewModel + StateFlow |
| DI | Hilt (KSP) |
| Navigasi | Navigation Compose (14 rute, guard auth) |
| Backend | Supabase (supabase-kt 3.1.4: `postgrest-kt`, `auth-kt`) |
| Gambar | Coil 3 |
| Test | JUnit4 + MockK + kotlinx-coroutines-test |

Toolchain: Kotlin 2.0.21, AGP 8.7.3, compileSdk 36, minSdk 26, Java 17.

## Struktur

```
app/src/main/kotlin/com/zunixe/zunixe_store/
  ZunixeApp.kt                 # @HiltAndroidApp
  MainActivity.kt              # @AndroidEntryPoint + setContent
  di/
    SupabaseConfig.kt          # URL + publishable key + redirect
    SupabaseModule.kt          # SupabaseClient (Postgrest + Auth)
    RepositoryModule.kt        # @Binds 4 repository
  core/
    Result.kt, Failure.kt      # Result<T> Ok/Err + Failure berpesan ID
    format/Format.kt           # formatRupiah, formatOrderDate
    config/StoreConfig.kt      # WA + bank + alamat + jam support
    theme/AppColors.kt, Theme.kt (Ubuntu)
    ui/AppHeader, GradientButton, ProductImage, ZunixeLogo
    navigation/Routes.kt, ZunixeNavHost.kt
  feature/
    auth/     data/ AuthRepositoryImpl   domain/ AppUser, AuthRepository
              ui/ AuthViewModel, LoginForm, LoginScreen, RegisterScreen,
                  ResetPasswordScreen, AccountScreen, ForgotPasswordDialog
    catalog/  data/ ProductRepositoryImpl (+JsonRowMapper)
              domain/ Product, ProductSort, ProductRepository
              ui/ ProductsViewModel, ProductDetailViewModel,
                  ProductsScreen, ProductCard, ProductDetailScreen
    cart/     data/ CartRepositoryImpl   domain/ CartItem, CartRepository
              ui/ CartViewModel, AddToCartButton, CartScreen
    checkout/ ui/ CheckoutViewModel, CheckoutScreen, OrderSuccessScreen(+PaymentInfo)
    orders/   data/ OrderRepositoryImpl  domain/ Order, OrderRepository
              ui/ OrdersViewModel, OrdersScreen
    home/     ui/ HomeViewModel (countdown), HomeScreen, MainShell
    support/  ui/ ChatScreen, AboutScreen, LegalScreen
app/src/test/                  # 85 unit test
```

## Aturan

1. **UI tidak pernah menyentuh `SupabaseClient` langsung** — hanya lewat repository.
2. Repository interface di `domain/`, implementasi di `data/`, di-bind lewat Hilt.
3. Warna **hanya** via `AppColors`; rute hanya via `Routes`.
4. Nomor WA **hanya** via `StoreConfig` (jangan hardcode di layar).
5. Guard auth (checkout/orders/account) via `if (!auth.isLoggedIn)` di NavHost.

## Backend (tidak berubah dari versi Flutter)

- Tabel: `products`, `cart_items`, `orders`, `order_items`, `profiles`
- RPC: `cart_add`, `place_order`, `cancel_order`
- Auth: email/password + OAuth (Google/Facebook)
- Deep link: `zunixe://login-callback` (intent-filter di AndroidManifest)

## Alur utama

```
Login → Home (5 tab) → Katalog → Detail → +Keranjang
      → Keranjang → Checkout → OrderSuccess → Pesanan Saya
```

## Animasi (permintaan klien)

- **AddToCartButton**: ikon **berputar** (infinite rotation 700ms) saat proses →
  **centang hijau** + `HapticFeedback` saat sukses, label via `AnimatedContent`.
- **CartScreen qty**: `AnimatedContent` slide vertikal + fade saat angka berubah.

## Menjalankan

```bash
cd android
./gradlew assembleDebug          # build APK
./gradlew testDebugUnitTest      # 85 unit test
./gradlew lintDebug              # lint
```

Install: `adb install -r app/build/outputs/apk/debug/app-debug.apk`

## Status fitur (audit)

| Fitur | Status |
|---|---|
| Auth email/password, register, reset | ✅ |
| Katalog (cari, filter kategori, sort, pagination) | ✅ |
| Detail produk (galeri, diskon, stok) | ✅ |
| Keranjang (qty, hapus, total) | ✅ |
| Checkout (validasi, idempotency, RPC place_order) | ✅ |
| Pesanan (riwayat, detail, batalkan) | ✅ |
| Home (promo, countdown, FAQ, footer, legal) | ✅ |
| Support via WhatsApp | ✅ |
| Rekening bank | ⚠️ `StoreConfig` kosong — isi agar muncul |
| Tandai dibayar / status kirim | ⚠️ manual di Supabase |
| Notifikasi push, bukti transfer, avatar | ❌ belum ada |
