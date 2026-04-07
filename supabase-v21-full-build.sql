-- CPAMMA Full Build

create table if not exists member_profiles (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  full_name text,
  bjj_rank text,
  muay_thai_rank text,
  youth_mma_rank text,
  scheduled_day_1 text,
  scheduled_time_1 text,
  scheduled_day_2 text,
  scheduled_time_2 text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists instructor_expected_classes (
  id uuid primary key default gen_random_uuid(),
  instructor_email text not null,
  day_label text not null,
  time_label text not null,
  class_name text not null,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table if not exists support_messages (
  id uuid primary key default gen_random_uuid(),
  sender_email text not null,
  category text not null,
  subject text not null,
  body text not null,
  status text default 'open',
  created_at timestamptz default now()
);

create table if not exists employee_timesheets (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  class_date date not null,
  class_type text,
  duration_hours numeric,
  notes text,
  created_at timestamptz default now()
);

create table if not exists smart_checkin_events (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  mode text not null,
  prompt text not null,
  confirmed boolean default false,
  created_at timestamptz default now()
);
