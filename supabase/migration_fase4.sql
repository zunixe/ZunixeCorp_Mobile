-- ============ Fase 4: bukti transfer + resi ============
-- 1. Kolom bukti transfer & nomor resi.
-- 2. RPC submit_payment_proof (validasi path + status).
-- 3. Storage bucket privat `payment-proofs` + policy per-user.
-- Rerunnable: IF NOT EXISTS / ON CONFLICT / DROP POLICY IF EXISTS.

alter table public.orders
  add column if not exists payment_proof_url text;
alter table public.orders
  add column if not exists tracking_number text;

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

  -- Path wajib di folder milik user: <user_id>/<order_id>-<ts>.<ext>
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

-- Storage: bucket privat, maksimal 5 MB, hanya gambar.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'payment-proofs',
  'payment-proofs',
  false,
  5242880,
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
