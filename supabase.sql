-- Trading Journal database schema. Run only in a NEW, separate Supabase project.
create extension if not exists pgcrypto;
create table if not exists public.trades (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 instrument text not null default 'XAUUSD',
 direction text not null check(direction in ('Long','Short')),
 entry_at timestamptz not null, exit_at timestamptz, timeframe text,
 status text not null default 'open' check(status in ('open','win','loss','breakeven')),
 entry_price numeric, exit_price numeric, sl numeric, tp1 numeric, tp2 numeric,
 position_size numeric, risk_usd numeric not null default 0, pnl_usd numeric not null default 0,
 fees_usd numeric not null default 0, partial_tp text not null default 'none' check(partial_tp in ('none','tp1','tp2')),
 be_activated boolean not null default false, setup_notes text, emotion_notes text, lesson_notes text,
 screenshot_path text, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists trades_user_entry_idx on public.trades(user_id,entry_at desc);
alter table public.trades enable row level security;
drop policy if exists "Users can read own trades" on public.trades;
create policy "Users can read own trades" on public.trades for select to authenticated using(auth.uid()=user_id);
drop policy if exists "Users can insert own trades" on public.trades;
create policy "Users can insert own trades" on public.trades for insert to authenticated with check(auth.uid()=user_id);
drop policy if exists "Users can update own trades" on public.trades;
create policy "Users can update own trades" on public.trades for update to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists "Users can delete own trades" on public.trades;
create policy "Users can delete own trades" on public.trades for delete to authenticated using(auth.uid()=user_id);
create table if not exists public.trading_plan (
 user_id uuid primary key references auth.users(id) on delete cascade, strategy text, entry_rules text,
 risk_limit_usd numeric not null default 0, daily_loss_limit_usd numeric not null default 0,
 max_trades_per_day integer not null default 0, checklist text, updated_at timestamptz not null default now()
);
alter table public.trading_plan enable row level security;
drop policy if exists "Users can read own plan" on public.trading_plan;
create policy "Users can read own plan" on public.trading_plan for select to authenticated using(auth.uid()=user_id);
drop policy if exists "Users can insert own plan" on public.trading_plan;
create policy "Users can insert own plan" on public.trading_plan for insert to authenticated with check(auth.uid()=user_id);
drop policy if exists "Users can update own plan" on public.trading_plan;
create policy "Users can update own plan" on public.trading_plan for update to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('trade-screenshots','trade-screenshots',false,8388608,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict(id) do update set public=false,file_size_limit=8388608,allowed_mime_types=array['image/jpeg','image/png','image/webp','image/gif'];
drop policy if exists "Users can view own trade screenshots" on storage.objects;
create policy "Users can view own trade screenshots" on storage.objects for select to authenticated using(bucket_id='trade-screenshots' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users can upload own trade screenshots" on storage.objects;
create policy "Users can upload own trade screenshots" on storage.objects for insert to authenticated with check(bucket_id='trade-screenshots' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users can update own trade screenshots" on storage.objects;
create policy "Users can update own trade screenshots" on storage.objects for update to authenticated using(bucket_id='trade-screenshots' and (storage.foldername(name))[1]=auth.uid()::text) with check(bucket_id='trade-screenshots' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users can delete own trade screenshots" on storage.objects;
create policy "Users can delete own trade screenshots" on storage.objects for delete to authenticated using(bucket_id='trade-screenshots' and (storage.foldername(name))[1]=auth.uid()::text);
