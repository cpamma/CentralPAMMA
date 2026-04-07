-- CPAMMA v16 support inbox and payroll review additions

create table if not exists public.support_messages (
  id uuid primary key default gen_random_uuid(),
  sender_email text not null,
  category text not null check (category in ('gym', 'payment')),
  subject text not null,
  body text not null,
  status text not null default 'open' check (status in ('open', 'archived')),
  created_at timestamptz not null default now()
);

create index if not exists idx_support_messages_status_created_at
  on public.support_messages (status, created_at desc);

alter table public.support_messages enable row level security;

create policy if not exists "support_messages_select_own"
  on public.support_messages
  for select
  to authenticated
  using (
    lower(sender_email) = lower(coalesce(auth.jwt() ->> 'email', ''))
    or lower(coalesce(auth.jwt() ->> 'email', '')) in ('info@cpamma.com', 'ryangruhn@gmail.com', 'frontdesk@cpamma.com')
  );

create policy if not exists "support_messages_insert_own"
  on public.support_messages
  for insert
  to authenticated
  with check (lower(sender_email) = lower(coalesce(auth.jwt() ->> 'email', '')));

create policy if not exists "support_messages_update_admin"
  on public.support_messages
  for update
  to authenticated
  using (lower(coalesce(auth.jwt() ->> 'email', '')) in ('info@cpamma.com', 'ryangruhn@gmail.com', 'frontdesk@cpamma.com'))
  with check (lower(coalesce(auth.jwt() ->> 'email', '')) in ('info@cpamma.com', 'ryangruhn@gmail.com', 'frontdesk@cpamma.com'));
