-- ============ Fase 3: konsistensi order & hapus akun ============
-- 1. cancel_order mengunci baris order (anti double-restore stok).
-- 2. place_order tidak lagi menandai 'processing' sebelum dibayar.
-- 3. delete_account untuk kewajiban hapus akun (Play policy).
-- 4. expire_unpaid_orders untuk melepas stok order tak dibayar.
-- 5. Revoke EXECUTE dari PUBLIC/anon (fungsi hanya untuk user login).
-- Rerunnable: semua CREATE OR REPLACE / IF EXISTS.

-- 1. cancel_order: lock order + urutkan update stok (anti deadlock)
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

  -- FOR UPDATE: dua permintaan batal bersamaan akan antre; yang kedua
  -- membaca status 'cancelled' dan ditolak (stok tidak dikembalikan dua kali).
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

-- 2. place_order: status awal 'pending' sampai pembayaran dikonfirmasi
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

  -- Status tetap 'pending' (default) sampai admin mengonfirmasi pembayaran.
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

-- 3. delete_account: hapus user + data terkait (kewajiban Play policy)
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
  delete from public.orders where user_id = v_user;      -- order_items ON DELETE CASCADE
  delete from public.profiles where id = v_user;
  delete from auth.users where id = v_user;
end;
$$;

-- 4. expire_unpaid_orders: batalkan order tak dibayar & kembalikan stok.
--    Jadwalkan lewat pg_cron (harian) atau panggil dari admin/service role.
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
    select id
    from public.orders
    where payment_status = 'unpaid'
      and status = 'pending'
      and created_at < now() - (p_days || ' days')::interval
    order by id
    for update
  loop
    for v_item in
      select product_id, quantity
      from public.order_items
      where order_id = v_order.id
      order by product_id
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

-- 5. Hak eksekusi: hanya user login untuk RPC pelanggan.
revoke all on function public.place_order(text, text, text, text, text) from public;
revoke all on function public.cart_add(text, int) from public;
revoke all on function public.cancel_order(uuid) from public;
revoke all on function public.delete_account() from public;

grant execute on function public.place_order(text, text, text, text, text) to authenticated;
grant execute on function public.cart_add(text, int) to authenticated;
grant execute on function public.cancel_order(uuid) to authenticated;
grant execute on function public.delete_account() to authenticated;

-- Job internal: jangan bisa dipanggil klien.
revoke all on function public.expire_unpaid_orders(int) from public;
grant execute on function public.expire_unpaid_orders(int) to service_role;

-- Contoh jadwal harian (aktifkan pg_cron lebih dulu di dashboard):
-- select cron.schedule('expire-unpaid-orders', '0 3 * * *',
--   $$select public.expire_unpaid_orders(3)$$);
