-- ============ ZunixeStore Schema ============

-- 1. profiles (linked ke auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  avatar_url text,
  created_at timestamptz default now()
);

-- 2. products (synced dari ZunixeCorp bridge)
create table if not exists public.products (
  id text primary key,
  name text not null,
  price numeric not null default 0 check (price >= 0),
  original_price numeric default 0,
  stock integer not null default 0 check (stock >= 0),
  image_urls jsonb not null default '[]',
  category text,
  description text,
  is_active boolean not null default true,
  updated_at timestamptz default now()
);
create index if not exists idx_products_category on public.products(category);
create index if not exists idx_products_name on public.products using gin (to_tsvector('simple', name));

-- 3. cart_items
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null references public.products(id) on delete cascade,
  product_name text not null,
  product_image text,
  price numeric not null check (price >= 0),
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz default now(),
  unique(user_id, product_id)
);

-- 4. orders
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  order_code text unique not null default 'ZX-' || upper(substr(md5(random()::text), 1, 8)),
  status text not null default 'pending',
  payment_status text not null default 'unpaid',
  subtotal numeric not null default 0,
  shipping_cost numeric not null default 0,
  total numeric not null default 0,
  customer_name text,
  customer_phone text,
  customer_email text,
  shipping_address text,
  notes text,
  idempotency_key text,
  payment_proof_url text,
  tracking_number text,
  created_at timestamptz default now()
);
create unique index if not exists idx_orders_idem
  on public.orders (user_id, idempotency_key)
  where idempotency_key is not null;

-- 5. order_items
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id text,
  product_name text,
  price numeric not null,
  quantity integer not null,
  total numeric not null
);

-- ============ RLS ============
alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- profiles (Fase 3: select hanya milik sendiri — cegah bocor nama/HP antar user)
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- products: public read, service_role only write
create policy "products_select_all" on public.products for select using (true);

-- cart_items: owner only
create policy "cart_select_own" on public.cart_items for select using (auth.uid() = user_id);
create policy "cart_insert_own" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "cart_update_own" on public.cart_items for update using (auth.uid() = user_id);
create policy "cart_delete_own" on public.cart_items for delete using (auth.uid() = user_id);

-- orders: owner only
create policy "orders_select_own" on public.orders for select using (auth.uid() = user_id);
create policy "orders_insert_own" on public.orders for insert with check (auth.uid() = user_id);

-- order_items: via order ownership
create policy "order_items_select_own" on public.order_items for select using (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);
create policy "order_items_insert_own" on public.order_items for insert with check (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);

-- ============ Trigger: auto-create profile on signup ============
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    null
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============ RPC: place_order (atomic checkout, otoritatif) ============
-- Harga/nama ikut products (bukan cart client) + lock stok + idempotency.
-- (Definisi penuh + migrasi: supabase/migration_fase2.sql)
create or replace function public.place_order(
  p_shipping_address text,
  p_customer_name text default null,
  p_customer_phone text default null,
  p_notes text default null,
  p_idempotency_key text default null
)
returns json
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_order_id uuid;
  v_order_code text;
  v_total bigint;
  v_item record;
  v_subtotal bigint := 0;
  v_count int;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;

  if p_idempotency_key is not null then
    select id, order_code, total into v_order_id, v_order_code, v_total
    from public.orders
    where user_id = v_user and idempotency_key = p_idempotency_key;
    if found then
      return json_build_object('order_id', v_order_id, 'order_code', v_order_code, 'total', v_total);
    end if;
  end if;

  select count(*) into v_count from public.cart_items where user_id = v_user;
  if v_count = 0 then
    raise exception 'Keranjang kosong';
  end if;

  insert into public.orders (user_id, shipping_address, customer_name, customer_phone, customer_email, notes, idempotency_key)
  values (v_user, p_shipping_address, p_customer_name, p_customer_phone,
          (select email from auth.users where id = v_user), p_notes, p_idempotency_key)
  returning id, order_code into v_order_id, v_order_code;

  perform 1
  from public.products p
  where p.id in (select product_id from public.cart_items where user_id = v_user)
  order by p.id
  for update of p;

  for v_item in
    select ci.product_id, ci.quantity,
           p.name as real_name, p.price as real_price, p.stock, p.is_active
    from public.cart_items ci
    left join public.products p on p.id = ci.product_id
    where ci.user_id = v_user
    order by ci.product_id
  loop
    if v_item.real_price is null then
      raise exception 'Produk tidak tersedia: %', v_item.product_id;
    end if;
    if not v_item.is_active then
      raise exception 'Produk sudah tidak aktif: %', v_item.real_name;
    end if;
    if v_item.quantity < 1 then
      raise exception 'Jumlah tidak valid untuk %', v_item.real_name;
    end if;
    if v_item.quantity > v_item.stock then
      raise exception 'Stok tidak cukup untuk %', v_item.real_name;
    end if;

    insert into public.order_items (order_id, product_id, product_name, price, quantity, total)
    values (v_order_id, v_item.product_id, v_item.real_name, v_item.real_price,
            v_item.quantity, (v_item.real_price * v_item.quantity)::bigint);

    update public.products set stock = stock - v_item.quantity where id = v_item.product_id;

    v_subtotal := v_subtotal + (v_item.real_price * v_item.quantity)::bigint;
  end loop;

  -- Status tetap 'pending' sampai pembayaran dikonfirmasi admin.
  update public.orders
  set subtotal = v_subtotal, total = v_subtotal
  where id = v_order_id;

  delete from public.cart_items where user_id = v_user;

  return json_build_object('order_id', v_order_id, 'order_code', v_order_code, 'total', v_subtotal);
exception
  when unique_violation then
    if p_idempotency_key is not null then
      select id, order_code, total into v_order_id, v_order_code, v_total
      from public.orders
      where user_id = v_user and idempotency_key = p_idempotency_key;
      if found then
        return json_build_object('order_id', v_order_id, 'order_code', v_order_code, 'total', v_total);
      end if;
    end if;
    raise;
end;
$$;

grant execute on function public.place_order(text, text, text, text, text) to authenticated;

-- ============ RPC: cart_add (tambah atomik, Fase 5) ============
-- (Definisi penuh: supabase/migration_fase2.sql)
create or replace function public.cart_add(p_product_id text, p_qty int default 1)
returns json
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_name text;
  v_price numeric;
  v_img text;
  v_stock int;
  v_active bool;
  v_qty int;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;
  if p_qty < 1 then
    raise exception 'Jumlah tidak valid';
  end if;
  select p.name, p.price, coalesce(p.image_urls->>0, ''), p.stock, p.is_active
    into v_name, v_price, v_img, v_stock, v_active
  from public.products p where p.id = p_product_id;
  if not found then
    raise exception 'Produk tidak tersedia';
  end if;
  if not v_active then
    raise exception 'Produk sudah tidak aktif: %', v_name;
  end if;
  if v_stock < 1 then
    raise exception 'Stok habis untuk %', v_name;
  end if;
  insert into public.cart_items (user_id, product_id, product_name, product_image, price, quantity)
  values (v_user, p_product_id, v_name, v_img, v_price, least(p_qty, v_stock))
  on conflict (user_id, product_id) do update set
    quantity = least(public.cart_items.quantity + excluded.quantity, v_stock),
    price = excluded.price,
    product_name = excluded.product_name,
    product_image = excluded.product_image
  returning public.cart_items.quantity into v_qty;
  return json_build_object('quantity', v_qty);
end;
$$;

grant execute on function public.cart_add(text, int) to authenticated;

-- ============ RPC: cancel_order (Paket A) ============
-- (Definisi penuh: supabase/migration_fase2.sql)
create or replace function public.cancel_order(p_order_id uuid)
returns json
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_status text;
  v_pay text;
  v_code text;
  v_item record;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;
  -- FOR UPDATE: cegah dua pembatalan bersamaan mengembalikan stok dua kali.
  select status, payment_status, order_code
    into v_status, v_pay, v_code
  from public.orders
  where id = p_order_id and user_id = v_user
  for update;
  if not found then
    raise exception 'Pesanan tidak ditemukan';
  end if;
  if v_pay = 'paid' then
    raise exception 'Pesanan sudah dibayar, hubungi admin untuk refund';
  end if;
  if v_status not in ('pending', 'processing') then
    raise exception 'Pesanan tidak bisa dibatalkan';
  end if;
  for v_item in
    select product_id, quantity
    from public.order_items
    where order_id = p_order_id
    order by product_id
  loop
    update public.products
    set stock = stock + v_item.quantity
    where id = v_item.product_id;
  end loop;
  update public.orders set status = 'cancelled' where id = p_order_id;
  return json_build_object('order_code', v_code);
end;
$$;

grant execute on function public.cancel_order(uuid) to authenticated;

-- ============ RPC: delete_account (Fase 3) ============
create or replace function public.delete_account()
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;
  delete from public.cart_items where user_id = v_user;
  delete from public.orders where user_id = v_user;
  delete from public.profiles where id = v_user;
  delete from auth.users where id = v_user;
end;
$$;

-- ============ RPC: expire_unpaid_orders (Fase 3) ============
create or replace function public.expire_unpaid_orders(p_days int default 3)
returns int
language plpgsql
security definer set search_path = public
as $$
declare
  v_order record;
  v_item record;
  v_count int := 0;
begin
  if p_days < 1 then
    raise exception 'p_days minimal 1';
  end if;
  for v_order in
    select id from public.orders
    where payment_status = 'unpaid'
      and status = 'pending'
      and created_at < now() - (p_days || ' days')::interval
    order by id
    for update
  loop
    for v_item in
      select product_id, quantity from public.order_items
      where order_id = v_order.id order by product_id
    loop
      update public.products
      set stock = stock + v_item.quantity
      where id = v_item.product_id;
    end loop;
    update public.orders set status = 'cancelled' where id = v_order.id;
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

-- Hanya user login untuk RPC pelanggan; job expiry hanya service_role.
revoke all on function public.place_order(text, text, text, text, text) from public;
revoke all on function public.cart_add(text, int) from public;
revoke all on function public.cancel_order(uuid) from public;
revoke all on function public.delete_account() from public;
grant execute on function public.place_order(text, text, text, text, text) to authenticated;
grant execute on function public.cart_add(text, int) to authenticated;
grant execute on function public.cancel_order(uuid) to authenticated;
grant execute on function public.delete_account() to authenticated;
revoke all on function public.expire_unpaid_orders(int) from public;
grant execute on function public.expire_unpaid_orders(int) to service_role;

-- ============ RPC: submit_payment_proof (Fase 4) ============
create or replace function public.submit_payment_proof(
  p_order_id uuid,
  p_path text
)
returns json
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_code text;
  v_pay text;
  v_status text;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;
  if p_path is null
     or p_path not like (v_user::text || '/%')
     or p_path like '%..%' then
    raise exception 'Path bukti transfer tidak valid';
  end if;
  select order_code, payment_status, status
    into v_code, v_pay, v_status
  from public.orders
  where id = p_order_id and user_id = v_user
  for update;
  if not found then
    raise exception 'Pesanan tidak ditemukan';
  end if;
  if v_pay = 'paid' then
    raise exception 'Pesanan sudah dibayar';
  end if;
  if v_status = 'cancelled' then
    raise exception 'Pesanan sudah dibatalkan';
  end if;
  update public.orders
  set payment_proof_url = p_path,
      payment_status = 'waiting_confirmation'
  where id = p_order_id;
  return json_build_object(
    'order_code', v_code,
    'payment_status', 'waiting_confirmation'
  );
end;
$$;

revoke all on function public.submit_payment_proof(uuid, text) from public;
grant execute on function public.submit_payment_proof(uuid, text) to authenticated;

-- Storage bukti transfer (privat, per-user folder).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'payment-proofs', 'payment-proofs', false, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = false,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

drop policy if exists "payment_proofs_insert_own" on storage.objects;
create policy "payment_proofs_insert_own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'payment-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "payment_proofs_select_own" on storage.objects;
create policy "payment_proofs_select_own" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'payment-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "payment_proofs_delete_own" on storage.objects;
create policy "payment_proofs_delete_own" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'payment-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
