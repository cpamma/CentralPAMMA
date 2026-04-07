-- CPAMMA v24 optional Supabase additions

create table if not exists app_events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text,
  event_date date not null,
  location text,
  audience text default 'all',
  registrations jsonb default '[]'::jsonb,
  is_active boolean default true,
  created_by text,
  created_at timestamptz default now()
);

create table if not exists notification_preferences (
  user_email text primary key,
  announcements boolean default true,
  class_updates boolean default true,
  payment_alerts boolean default true,
  support_replies boolean default true,
  smart_checkin_prompts boolean default true,
  updated_at timestamptz default now()
);
