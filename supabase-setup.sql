-- AKCIEBI.GE current database setup
-- Safe to run in Supabase SQL Editor. Existing offers are preserved.
create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  description text default '',
  store_name text,
  category text,
  price numeric(12,2),
  old_price numeric(12,2),
  image_url text,
  start_date date,
  end_date date,
  is_active boolean default true,
  location_text text,
  latitude double precision,
  longitude double precision,
  contact_phone text,
  created_at timestamptz default now()
);
alter table public.offers
  add column if not exists location_text text,
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists contact_phone text;
alter table public.offers enable row level security;
drop policy if exists "Public can read offers" on public.offers;
drop policy if exists "Public can view offers" on public.offers;
drop policy if exists "Enable read access for all users" on public.offers;
drop policy if exists "Users can insert own offers" on public.offers;
drop policy if exists "Users can update own offers" on public.offers;
drop policy if exists "Users can delete own offers" on public.offers;
create policy "Public can view offers" on public.offers for select to anon, authenticated using (true);
create policy "Users can insert own offers" on public.offers for insert to authenticated with check (auth.uid() = user_id);
create policy "Users can update own offers" on public.offers for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own offers" on public.offers for delete to authenticated using (auth.uid() = user_id);

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('offer-images','offer-images',true,5242880,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=excluded.allowed_mime_types;
drop policy if exists "Public can view offer images" on storage.objects;
drop policy if exists "Users can upload own offer images" on storage.objects;
drop policy if exists "Users can update own offer images" on storage.objects;
drop policy if exists "Users can delete own offer images" on storage.objects;
create policy "Public can view offer images" on storage.objects for select to public using (bucket_id='offer-images');
create policy "Users can upload own offer images" on storage.objects for insert to authenticated with check (bucket_id='offer-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "Users can update own offer images" on storage.objects for update to authenticated using (bucket_id='offer-images' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='offer-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "Users can delete own offer images" on storage.objects for delete to authenticated using (bucket_id='offer-images' and (storage.foldername(name))[1]=auth.uid()::text);
