-- ============ Fase 2: checkout otoritatif ============
-- Anti price-spoofing (harga ikut products, bukan cart client),
-- anti oversell (lock baris stok), anti double-submit (idempotency key),
-- fail-fast keranjang kosong (tanpa order yatim).
-- Rerunnable: semua guard IF NOT EXISTS / CREATE OR REPLACE.

-- 1. CHECK constraints
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'cart_items_quantity_pos') then
    alter table public.cart_items add constraint cart_items_quantity_pos check (quantity > 0);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'cart_items_price_nonneg') then
    alter table public.cart_items add constraint cart_items_price_nonneg check (price >= 0);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'products_stock_nonneg') then
    alter table public.products add constraint products_stock_nonneg check (stock >= 0);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'products_price_nonneg') then
    alter table public.products add constraint products_price_nonneg check (price >= 0);
  end if;
end $$;

-- 2. Idempotency key untuk double-submit
alter table public.orders add column if not exists idempotency_key text;
create unique index if not exists idx_orders_idem
  on public.orders (user_id, idempotency_key)
  where idempotency_key is not null;

-- 3. RPC place_order otoritatif
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

  -- Retry aman: key yang sama kembalikan order yang sudah ada
  if p_idempotency_key is not null then
    select id, order_code, total into v_order_id, v_order_code, v_total
    from public.orders
    where user_id = v_user and idempotency_key = p_idempotency_key;
    if found then
      return json_build_object('order_id', v_order_id, 'order_code', v_order_code, 'total', v_total);
    end if;
  end if;

  -- Fail fast sebelum order dibuat (hindari order yatim)
  select count(*) into v_count from public.cart_items where user_id = v_user;
  if v_count = 0 then
    raise exception 'Keranjang kosong';
  end if;

  insert into public.orders (user_id, shipping_address, customer_name, customer_phone, customer_email, notes, idempotency_key)
  values (v_user, p_shipping_address, p_customer_name, p_customer_phone,
          (select email from auth.users where id = v_user), p_notes, p_idempotency_key)
  returning id, order_code into v_order_id, v_order_code;

  -- Kunci semua baris stok yang terlibat (urut untuk hindari deadlock)
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

  update public.orders
  set subtotal = v_subtotal, total = v_subtotal, status = 'processing'
  where id = v_order_id;

  delete from public.cart_items where user_id = v_user;

  return json_build_object('order_id', v_order_id, 'order_code', v_order_code, 'total', v_subtotal);
exception
  when unique_violation then
    -- Balapan double-submit key sama: kembalikan order pemenang
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

-- ============ Fase 3: RLS profiles (anti bocor PII) ============
drop policy if exists "profiles_select_all" on public.profiles;
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);

-- ============ Fase 5: cart_add atomik ============
-- Increment qty tanpa race + data otoritatif dari products + cap stok.
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

-- ============ Paket A: cancel_order (batal + kembalikan stok) ============
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
  select status, payment_status, order_code
    into v_status, v_pay, v_code
  from public.orders where id = p_order_id and user_id = v_user;
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
    select product_id, quantity from public.order_items where order_id = p_order_id
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
