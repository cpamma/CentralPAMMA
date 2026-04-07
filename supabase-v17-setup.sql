-- CPAMMA v17 smart check-in foundation
create table if not exists smart_checkin_events (
  id uuid primary key default gen_random_uuid(),
  user_email text not null,
  mode text not null check (mode in ('employee','student')),
  event_type text not null check (event_type in ('arrival','prompt','confirmed','dismissed')),
  title text not null,
  detail text not null,
  class_title text,
  class_time text,
  created_at timestamptz not null default now()
);

create index if not exists smart_checkin_events_user_email_idx on smart_checkin_events(user_email);
create index if not exists smart_checkin_events_created_at_idx on smart_checkin_events(created_at desc);

alter table smart_checkin_events enable row level security;

create policy if not exists "smart checkin own rows"
  on smart_checkin_events for select
  using (lower(user_email) = lower(auth.email()));

create policy if not exists "smart checkin own inserts"
  on smart_checkin_events for insert
  with check (lower(user_email) = lower(auth.email()));
