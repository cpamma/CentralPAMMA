create table if not exists app_profiles (
  email text primary key,
  role text not null default 'member',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists instructor_expected_classes (
  id uuid primary key default gen_random_uuid(),
  instructor_email text not null,
  day_label text not null,
  class_time text not null,
  class_title text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table if exists app_profiles enable row level security;
alter table if exists instructor_expected_classes enable row level security;

create policy if not exists "app_profiles_select_self" on app_profiles
for select using (lower(email) = lower(auth.jwt() ->> 'email'));

create policy if not exists "app_profiles_admin_all" on app_profiles
for all using (lower(auth.jwt() ->> 'email') in ('info@cpamma.com', 'ryangruhn@gmail.com'))
with check (lower(auth.jwt() ->> 'email') in ('info@cpamma.com', 'ryangruhn@gmail.com'));

create policy if not exists "expected_classes_select_staff" on instructor_expected_classes
for select using (lower(auth.jwt() ->> 'email') in ('info@cpamma.com', 'ryangruhn@gmail.com', 'frontdesk@cpamma.com') or lower(instructor_email) = lower(auth.jwt() ->> 'email'));

create policy if not exists "expected_classes_admin_manage" on instructor_expected_classes
for all using (lower(auth.jwt() ->> 'email') in ('info@cpamma.com', 'ryangruhn@gmail.com'))
with check (lower(auth.jwt() ->> 'email') in ('info@cpamma.com', 'ryangruhn@gmail.com'));
