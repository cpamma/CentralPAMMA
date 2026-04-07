alter table if exists public.employee_timesheets add column if not exists start_time text;
alter table if exists public.employee_timesheets add column if not exists submitted_at timestamptz;
alter table if exists public.employee_timesheets add column if not exists submitted_month text;
create index if not exists employee_timesheets_employee_month_idx on public.employee_timesheets (employee_email, class_date);
