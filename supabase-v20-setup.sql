create table if not exists member_profiles (
  id uuid primary key default gen_random_uuid(),
  user_email text not null unique,
  full_name text,
  bjj_rank text,
  muay_thai_rank text,
  youth_mma_rank text,
  youth_day_1 text,
  youth_time_1 text,
  youth_day_2 text,
  youth_time_2 text,
  updated_at timestamptz not null default now(),
  updated_by text
);

create table if not exists instructor_expected_classes (
  id uuid primary key default gen_random_uuid(),
  instructor_email text not null,
  day_label text not null,
  class_time text not null,
  class_title text not null,
  is_active boolean not null default true,
  updated_at timestamptz not null default now(),
  updated_by text
);

create index if not exists idx_member_profiles_user_email on member_profiles (user_email);
create index if not exists idx_instructor_expected_classes_email on instructor_expected_classes (instructor_email);
