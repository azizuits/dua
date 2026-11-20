-- এটি একাধিকবার চালালেও সমস্যা নেই। পুরোটা কপি করে Run করুন।
create table if not exists items (
  id text primary key,
  data jsonb not null,
  created_at timestamptz default now()
);
alter table items enable row level security;

drop policy if exists "সবাই দেখতে পারবে" on items;
drop policy if exists "শুধু লগইন করা এডমিন বদলাতে পারবে" on items;
drop policy if exists "items_read_all" on items;
drop policy if exists "items_admin_write" on items;
create policy "items_read_all" on items for select using (true);
create policy "items_admin_write" on items for all to authenticated using (true) with check (true);

do $$ begin
  alter publication supabase_realtime add table items;
exception when duplicate_object then null;
end $$;

insert into storage.buckets (id, name, public) values ('media','media', true) on conflict (id) do nothing;

drop policy if exists "মিডিয়া সবাই দেখবে" on storage.objects;
drop policy if exists "মিডিয়া শুধু এডমিন আপলোড/ডিলিট" on storage.objects;
drop policy if exists "media_read_all" on storage.objects;
drop policy if exists "media_admin_write" on storage.objects;
create policy "media_read_all" on storage.objects for select using (bucket_id = 'media');
create policy "media_admin_write" on storage.objects for all to authenticated using (bucket_id = 'media') with check (bucket_id = 'media');
