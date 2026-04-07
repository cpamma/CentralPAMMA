-- CPAMMA v25 auto payroll submission support

create table if not exists payroll_month_submissions (
  id uuid primary key default gen_random_uuid(),
  employee_email text not null,
  month_key text not null,
  sent_at timestamptz,
  delivery_status text default 'pending',
  entry_count integer default 0,
  detail text,
  automated boolean default true,
  created_at timestamptz default now(),
  unique(employee_email, month_key)
);

create index if not exists idx_payroll_month_submissions_month_key on payroll_month_submissions(month_key);
create index if not exists idx_payroll_month_submissions_employee on payroll_month_submissions(employee_email);

-- Optional: schedule the Edge Function every 15 minutes.
-- Before running this, store a service or anon key in Vault as 'cpamma_supabase_anon_key'
-- and confirm pg_cron / pg_net are enabled in your project.
--
-- select cron.schedule(
--   'cpamma-auto-submit-payroll',
--   '*/15 * * * *',
--   $$
--   select net.http_post(
--     url := current_setting('app.settings.supabase_url') || '/functions/v1/send-payroll-email',
--     headers := jsonb_build_object(
--       'Content-Type', 'application/json',
--       'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'cpamma_supabase_anon_key' limit 1)
--     ),
--     body := '{"mode":"auto_submit_due_months"}'::jsonb
--   );
--   $$
-- );
