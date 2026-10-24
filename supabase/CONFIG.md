# ZunixeStore — Konfigurasi Supabase

> Dokumen referensi untuk AI agent / developer. Terakhir diperbarui: 2026-10-22.
> ⚠️ File ini **tidak boleh memuat kredensial**. Nilai rahasia disimpan di
> `supabase/.env.local` (gitignored) dan password manager pemilik.

---

## 1. Project Info

| Item | Nilai |
|---|---|
| Project name | `ZunixeStore_db` |
| Organization | `zymanq Org` (Free plan, region Tokyo `ap-northeast-1`) |
| Project ref | `ahafaueeukvffkdzlkuv` |
| Dashboard | https://supabase.com/dashboard/project/ahafaueeukvffkdzlkuv |
| Postgres | 17.6 |
| Status | Healthy (compute nano) |

## 2. Kredensial & Keys

| Key | Nilai |
|---|---|
| Project URL | `https://ahafaueeukvffkdzlkuv.supabase.co` |
| Publishable key (anon/client) | `sb_publishable_wu-3jDpD-Bmld79QA1Oc6w_ROc9MDuo` |
| Secret key (server/admin) | lihat `supabase/.env.local` (`SUPABASE_SECRET_KEY`) |
| DB password | lihat password manager / `supabase/.env.local` |

### Koneksi Database (CLI / psql / migration)

**Gunakan session pooler (IPv4) — direct `db.` host tidak resolve dari Mac ini (IPv6-only):**

```bash
# PGPASSWORD diisi dari password manager (jangan tulis di dokumen ini).
export PGPASSWORD='<db-password>'
/opt/homebrew/opt/libpq/bin/psql \
  "postgresql://postgres.ahafaueeukvffkdzlkuv@aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres" \
  -f /path/to/query.sql
```

- psql tersedia di: `/opt/homebrew/opt/libpq/bin/psql` (PostgreSQL 18.3)
- Pooler host: `aws-0-ap-northeast-1.pooler.supabase.com:5432`
- Username pooler: `postgres.ahafaueeukvffkdzlkuv` (ref di-suffix)
- Direct (tidak jalan di sini): `postgresql://postgres:[PWD]@db.ahafaueeukvffkdzlkuv.supabase.co:5432/postgres`

### Login Dashboard (jika perlu browser/Playwright)

- Gunakan akun pemilik dari password manager. Jangan simpan email/password
  dashboard di dokumen repo.

## 3. Arsitektur (keputusan final)

```
Shopee → ZunixeCorp (Next.js, Postgres/Prisma, 268 produk)
       → scripts/sync-store-products-supabase.js (fetch bridge API + upsert)
       → Supabase products table
       → Flutter (supabase_flutter, query langsung)
```

- **Flutter → Supabase langsung** (auth, cart, orders, produk) — TANPA Express/SQLite.
- Express `ZunixeStore-Api` (SQLite) sudah TIDAK dipakai mobile lagi; biarkan sebagai legacy.
- Auth: **Supabase Auth** (email/password), fresh start — tidak migrasi user lama.
- RLS aktif di semua tabel; write produk hanya via service key (sync script).

## 4. Skema Database (public)

| Tabel | Kolom penting | Catatan |
|---|---|---|
| `profiles` | id (=auth.users.id), full_name, phone, avatar_url | auto-create via trigger `on_auth_user_created` → `handle_new_user()` |
| `products` | id TEXT PK (=itemId Shopee), name, price, original_price, stock, image_urls jsonb, category, description, is_active | index category + GIN tsvector name |
| `cart_items` | id, user_id, product_id, product_name, product_image, price, quantity | UNIQUE(user_id, product_id) |
| `orders` | id, user_id, order_code ('ZX-XXXXXXXX'), status, payment_status, subtotal, shipping_cost, total, customer_name/phone/email, shipping_address, notes, payment_proof_url, tracking_number | |
| `order_items` | id, order_id, product_id, product_name, price, quantity, total | |

### RLS Policies
- `products` → SELECT publik (anon+user), write hanya service_role
- `cart_items`, `orders`, `order_items` → hanya owner (`auth.uid() = user_id`)
- `profiles` → SELECT & UPDATE milik sendiri (`auth.uid() = id`)

### RPC Checkout (atomic)
```sql
select public.place_order(p_shipping_address, p_customer_name, p_customer_phone, p_notes);
```
- Validasi stok per item (`for update`), buat order + items, kurangi stok, kosongkan cart
- Return: `{order_id, order_code, total}`
- Raise exception jika stok kurang / cart kosong

## 5. File Terkait

| File | Fungsi |
|---|---|
| `supabase/schema.sql` | Full schema + RLS + trigger + RPC (sudah dieksekusi ✅) |
| `supabase/.env.local` | ENV untuk script (URL, keys, DB URL) |
| `ZunixeCorp/scripts/sync-store-products-supabase.js` | Sync 268 produk bridge → Supabase (belum dibuat) |

## 6. Checklist Migrasi (status)

- [x] Schema + RLS + trigger + RPC place_order di Supabase
- [x] Sync script produk ZunixeCorp → Supabase (261 produk, `ZunixeCorp/scripts/sync-store-products-supabase.js`)
- [x] Flutter: `supabase_flutter` init (URL + publishable key)
- [x] Flutter: AuthProvider → Supabase Auth
- [x] Flutter: CartProvider → tabel cart_items (fetchCart saat startup + onAuthStateChange)
- [x] Flutter: ProductService → query tabel products
- [x] Flutter: Checkout → RPC place_order + screen konfirmasi + riwayat pesanan (OrdersScreen)
- [x] Build APK + install Redmi (IP adb bisa berubah — cek `adb devices`)
- [x] Dashboard: "Confirm email" dimatikan (Authentication → Providers) → register langsung login
- [x] E2E API test pass: signup → insert cart_items (wajib sertakan user_id) → place_order → order+items+stok berkurang+cart clear
- [x] Fix UI: tombol Beli cek hasil nyata; belum login → dialog tawaran login; judul header dobel ("Keranjang Keranjang") diperbaiki di AppHeader
- [ ] Jalankan `supabase/migration_fase3.sql` (cancel lock, status pending, delete_account, expire_unpaid_orders)
- [ ] Jalankan `supabase/migration_fase4.sql` (bukti transfer, resi, bucket `payment-proofs`)
- [ ] Aktifkan "Confirm email" di Authentication → Providers untuk produksi
- [ ] Buat upload keystore + `android/key.properties` untuk build rilis

## 7. Catatan Bug/Perilaku Penting

- **Insert cart_items wajib sertakan `user_id`** (RLS `auth.uid() = user_id`) — sudah ditangani CartProvider.
- **Email confirmation OFF** → `signUp` langsung mengembalikan session. Jika dinyalakan lagi, app menampilkan alur `needVerification` dan mengarahkan ke login. Untuk produksi, nyalakan agar email tidak bisa dipakai orang lain (account squatting).
- **Fix AppHeader**: `_defaultLeading()` kini hanya logo "Z"; judul dirender sekali di Row. Sebelumnya judul tampil dobel di screen tanpa back/menu (cart, account, orders).
- Test/register data probe sudah dibersihkan; DB mulai dari: 261 produk, 0 user, 0 order.

---

## 8. Status Fitur (audit 2026-09-27)

### Berjalan (backend nyata)
- Auth email/password (register → langsung login, confirm email OFF)
- Katalog: 261 produk, 227 tampil (aktif + stok > 0), pencarian & filter kategori
- Keranjang (tabel `cart_items`, RPC `cart_add` cap stok)
- Checkout atomic (RPC `place_order`, idempotency key)
- Riwayat pesanan + batalkan (RPC `cancel_order`, stok kembali)
- Deep link auth (`zunixe://login-callback`) — ditangani otomatis
  `supabase_flutter` (app_links + WidgetsBindingObserver); intent-filter ada
  di `AndroidManifest.xml`. Reset password kembali ke layar password baru
  via event `passwordRecovery` (listener di `MainShell`).
- Support via WhatsApp (buka `wa.me`, tanpa backend chat)
- Hapus akun in-app (Akun → Hapus Akun) via RPC `delete_account` (Fase 3)
- Status pesanan `pending` sampai admin menandai pembayaran; `cancel_order`
  mengunci baris order (anti stok kembali dua kali)

### Belum berjalan / perlu aksi pemilik
| Fitur | Status | Aksi |
|---|---|---|
| **Rekening bank** | `StoreConfig.bankName/accountNumber/accountHolder` KOSONG | Isi `lib/core/config/store.dart` → blok rekening + tombol Salin otomatis muncul. Sampai itu, copy checkout mengarahkan ke WhatsApp (sudah konsisten) |
| **Tandai pesanan dibayar** | Belum ada dari app | Update manual di dashboard Supabase: `update orders set payment_status='paid', status='processing'` |
| **Update status kirim/selesai** | Belum ada dari app | Update manual: `update orders set status='shipped', tracking_number='RESI...'` lalu `'completed'` |
| **Job kedaluwarsa order** | Fungsi `expire_unpaid_orders(3)` tersedia | Jadwalkan via pg_cron / Edge Function harian |
| **Release signing** | Gradle siap membaca `android/key.properties` | Buat upload keystore + isi file (lihat `android/key.properties.example`) |
| **Kebijakan privasi publik** | Teks in-app sudah diperbarui | Sediakan URL publik untuk Play Console + Data Safety |
| **Google/Facebook OAuth** | Kode siap; aktif belum diverifikasi | Aktifkan provider + allowlist `zunixe://login-callback` di dashboard; daftarkan SHA-1 Android |
| **Notifikasi push** | Belum ada | Perlu FCM (belum di scope) |
| **Upload bukti transfer** | Kode + RPC + bucket privat siap | Jalankan `migration_fase4.sql`; admin verifikasi di dashboard lalu set `payment_status='paid'` |
| **Avatar / edit profil** | Belum ada UI | `profiles.avatar_url` ada, UI belum |

### Catatan teknis
- Migrasi terbaru: `supabase/migration_fase3.sql` dan
  `supabase/migration_fase4.sql` (idempoten) — wajib dijalankan sebelum build
  baru dipakai.
- Bukti transfer disimpan privat di bucket `payment-proofs` dengan folder
  `<user_id>/`; hanya pemilik yang bisa upload/lihat. Admin memakai service
  role/dashboard.
- Ongkir gratis (hardcode "Rp 0"); kolom `shipping_cost` ada di DB.
- `products.category` masih berisi ID Shopee numerik (35 kategori). App
  menyembunyikan chip kategori numerik sampai sync mengirim nama yang terbaca
  (mis. tambah kolom `category_name` atau map ID → nama).
- Semua URL gambar produk (`image_urls`, jsonb array) valid & bisa diakses (cek 2026-09-27).
- Nomor WA satu sumber di `StoreConfig` (`waNumber`/`waDisplay`); jangan hardcode di layar.
