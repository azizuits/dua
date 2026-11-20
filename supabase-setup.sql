-- Supabase SQL Editor-এ পুরোটা কপি করে Run করুন
create table if not exists items (
  id text primary key,
  data jsonb not null,
  created_at timestamptz default now()
);
alter table items enable row level security;
create policy "সবাই দেখতে পারবে" on items for select using (true);
create policy "শুধু লগইন করা এডমিন বদলাতে পারবে" on items for all to authenticated using (true) with check (true);
alter publication supabase_realtime add table items;

insert into storage.buckets (id, name, public) values ('media','media', true) on conflict do nothing;
create policy "মিডিয়া সবাই দেখবে" on storage.objects for select using (bucket_id = 'media');
create policy "মিডিয়া শুধু এডমিন আপলোড/ডিলিট" on storage.objects for all to authenticated using (bucket_id = 'media') with check (bucket_id = 'media');
