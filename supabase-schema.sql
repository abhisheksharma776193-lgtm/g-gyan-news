-- G Gyan News: Supabase SQL Editor में पूरा script Run करें
create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'reader' check (role in ('reader','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.news (
 id uuid primary key default gen_random_uuid(),
 title text not null check (char_length(title) between 1 and 180),
 category text not null default 'बिहार' check (category in ('बिहार','देश','राजनीति','वायरल','फोटो-वीडियो')),
 summary text not null check (char_length(summary) between 1 and 30000),
 image_url text, video_url text,
 is_published boolean not null default false,
 created_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists news_published_created_idx on public.news(is_published,created_at desc);
alter table public.profiles enable row level security;
alter table public.news enable row level security;

create or replace function public.is_ggyan_admin()
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin'); $$;
revoke all on function public.is_ggyan_admin() from public;
grant execute on function public.is_ggyan_admin() to anon, authenticated;

drop policy if exists "profile read own" on public.profiles;
create policy "profile read own" on public.profiles for select to authenticated using(id=(select auth.uid()));
drop policy if exists "public read published news" on public.news;
create policy "public read published news" on public.news for select to anon,authenticated using(is_published=true or public.is_ggyan_admin());
drop policy if exists "admin insert news" on public.news;
create policy "admin insert news" on public.news for insert to authenticated with check(public.is_ggyan_admin());
drop policy if exists "admin update news" on public.news;
create policy "admin update news" on public.news for update to authenticated using(public.is_ggyan_admin()) with check(public.is_ggyan_admin());
drop policy if exists "admin delete news" on public.news;
create policy "admin delete news" on public.news for delete to authenticated using(public.is_ggyan_admin());

grant select on public.news to anon,authenticated;
grant insert,update,delete on public.news to authenticated;
grant select on public.profiles to authenticated;

-- 1) पहले Supabase Dashboard > Authentication > Users > Add user से अपना admin user बनाएं।
-- 2) उस user की UUID कॉपी करें। नीचे USER_UUID_HERE को वास्तविक UUID से बदलकर अलग query के रूप में Run करें:
-- insert into public.profiles(id,role) values('USER_UUID_HERE','admin')
-- on conflict(id) do update set role='admin';
-- Frontend में केवल public anon/publishable key रखें। service_role/secret key कभी नहीं।
