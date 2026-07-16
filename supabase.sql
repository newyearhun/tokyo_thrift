create extension if not exists pgcrypto;

create table if not exists public.shopping_items (
  id uuid primary key default gen_random_uuid(),
  category_id text not null,
  owner_id text not null check (owner_id in ('junghun', 'siyeon')),
  text text not null,
  note text not null default '',
  photo_url text not null default '',
  photo_path text not null default '',
  done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists shopping_items_category_owner_idx
on public.shopping_items (category_id, owner_id);

create index if not exists shopping_items_created_at_idx
on public.shopping_items (created_at);

insert into storage.buckets (id, name, public)
values ('shopping-item-photos', 'shopping-item-photos', true)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;

drop policy if exists "Public read shopping-item-photos" on storage.objects;
drop policy if exists "Public insert shopping-item-photos" on storage.objects;
drop policy if exists "Public delete shopping-item-photos" on storage.objects;

create policy "Public read shopping-item-photos"
on storage.objects
for select
to public
using (bucket_id = 'shopping-item-photos');

create policy "Public insert shopping-item-photos"
on storage.objects
for insert
to public
with check (bucket_id = 'shopping-item-photos');

create policy "Public delete shopping-item-photos"
on storage.objects
for delete
to public
using (bucket_id = 'shopping-item-photos');

create or replace function public.set_shopping_items_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists shopping_items_set_updated_at on public.shopping_items;
create trigger shopping_items_set_updated_at
before update on public.shopping_items
for each row
execute function public.set_shopping_items_updated_at();

alter table public.shopping_items enable row level security;

drop policy if exists "Allow public read" on public.shopping_items;
drop policy if exists "Allow public insert" on public.shopping_items;
drop policy if exists "Allow public update" on public.shopping_items;
drop policy if exists "Allow public delete" on public.shopping_items;

create policy "Allow public read"
on public.shopping_items
for select
to public
using (true);

create policy "Allow public insert"
on public.shopping_items
for insert
to public
with check (true);

create policy "Allow public update"
on public.shopping_items
for update
to public
using (true)
with check (true);

create policy "Allow public delete"
on public.shopping_items
for delete
to public
using (true);
