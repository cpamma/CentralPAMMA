-- CPAMMA v15 setup

create extension if not exists pgcrypto;

create table if not exists app_announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  audience text not null default 'all' check (audience in ('all','members','staff')),
  is_pinned boolean not null default false,
  is_active boolean not null default true,
  expires_at date null,
  created_by text null,
  created_at timestamptz not null default now()
);

create table if not exists employee_timesheets (
  id uuid primary key default gen_random_uuid(),
  employee_email text not null,
  class_date date not null,
  class_type text not null,
  duration_hours numeric(6,2) not null,
  students_count integer null,
  notes text null,
  created_at timestamptz not null default now()
);

create index if not exists idx_app_announcements_active on app_announcements(is_active, created_at desc);
create index if not exists idx_employee_timesheets_email_date on employee_timesheets(employee_email, class_date desc);

alter table app_announcements enable row level security;
alter table employee_timesheets enable row level security;

create policy if not exists announcements_read_active on app_announcements
for select using (is_active = true);

create policy if not exists announcements_admin_manage on app_announcements
for all using (lower(coalesce(auth.jwt()->>'email','')) in ('info@cpamma.com','ryangruhn@gmail.com','frontdesk@cpamma.com'))
with check (lower(coalesce(auth.jwt()->>'email','')) in ('info@cpamma.com','ryangruhn@gmail.com','frontdesk@cpamma.com'));

create policy if not exists employee_timesheets_insert_own on employee_timesheets
for insert with check (employee_email = lower(coalesce(auth.jwt()->>'email','')));

create policy if not exists employee_timesheets_read_own_or_admin on employee_timesheets
for select using (
  employee_email = lower(coalesce(auth.jwt()->>'email',''))
  or lower(coalesce(auth.jwt()->>'email','')) in ('info@cpamma.com','ryangruhn@gmail.com','frontdesk@cpamma.com')
);
