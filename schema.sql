-- PISA SCHOOL 360 database foundation
-- Run in Supabase SQL Editor. Review and adapt before production deployment.
create extension if not exists pgcrypto;

create type public.app_role as enum (
  'super_admin','school_admin','director','deputy_director','teacher',
  'student','parent','psychologist','mahalla','analyst'
);
create type public.respondent_group as enum ('student','parent','teacher','director','psychologist','mahalla');
create type public.question_type as enum ('single_choice','multiple_choice','yes_no','likert','scale_1_5','scale_1_10','text','table','matrix','image');
create type public.collection_status as enum ('draft','published','paused','closed');

create table public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  region text,
  district text,
  school_type text,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role public.app_role not null default 'student',
  school_id uuid references public.schools(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.respondents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  school_id uuid references public.schools(id) on delete cascade,
  respondent_group public.respondent_group not null,
  anonymous boolean not null default false,
  consent_recorded boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.student_profiles (
  respondent_id uuid primary key references public.respondents(id) on delete cascade,
  age int, gender text, grade text, language_of_instruction text,
  urban_rural text, siblings_count int, books_at_home text,
  computer_access boolean, internet_access boolean
);
create table public.teacher_profiles (
  respondent_id uuid primary key references public.respondents(id) on delete cascade,
  age int, gender text, subject text, experience_years int,
  education text, qualification_category text, weekly_workload numeric,
  digital_literacy text
);
create table public.parent_profiles (
  respondent_id uuid primary key references public.respondents(id) on delete cascade,
  age int, gender text, education text, occupation text,
  children_count int, digital_access text
);
create table public.director_profiles (
  respondent_id uuid primary key references public.respondents(id) on delete cascade,
  age int, gender text, leadership_years int, specialty text,
  manager_certificate boolean, management_training text,
  school_type text, student_count int, teacher_count int
);
create table public.psychologist_profiles (
  respondent_id uuid primary key references public.respondents(id) on delete cascade,
  experience_years int, education text
);
create table public.mahalla_profiles (
  respondent_id uuid primary key references public.respondents(id) on delete cascade,
  position_title text, experience_years int
);

create table public.questionnaires (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  title text not null,
  description text,
  respondent_group public.respondent_group not null,
  status public.collection_status not null default 'draft',
  starts_at timestamptz, ends_at timestamptz,
  anonymous_allowed boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create table public.questionnaire_sections (
  id uuid primary key default gen_random_uuid(),
  questionnaire_id uuid not null references public.questionnaires(id) on delete cascade,
  title text not null, sort_order int not null default 0
);
create table public.questions (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.questionnaire_sections(id) on delete cascade,
  prompt text not null,
  question_type public.question_type not null,
  required boolean not null default true,
  sort_order int not null default 0,
  metadata jsonb not null default '{}'::jsonb
);
create table public.answer_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  label text not null, value text not null, score numeric,
  sort_order int not null default 0
);
create table public.responses (
  id uuid primary key default gen_random_uuid(),
  questionnaire_id uuid not null references public.questionnaires(id) on delete cascade,
  respondent_id uuid references public.respondents(id) on delete set null,
  school_id uuid references public.schools(id) on delete cascade,
  submitted_at timestamptz,
  status text not null default 'in_progress',
  created_at timestamptz not null default now()
);
create table public.answers (
  id uuid primary key default gen_random_uuid(),
  response_id uuid not null references public.responses(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  answer_text text, selected_option_ids uuid[] not null default '{}',
  numeric_value numeric, created_at timestamptz not null default now(),
  unique(response_id, question_id)
);

create table public.assessment_periods (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  title text not null, starts_at timestamptz, ends_at timestamptz,
  status public.collection_status not null default 'draft'
);
create table public.test_categories (
  id uuid primary key default gen_random_uuid(),
  code text unique not null, title text not null, description text
);
create table public.test_competencies (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.test_categories(id) on delete cascade,
  title text not null, description text
);
create table public.test_levels (
  id uuid primary key default gen_random_uuid(),
  label text not null, sort_order int not null unique
);
create table public.tests (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  title text not null, category_id uuid references public.test_categories(id),
  duration_minutes int, status public.collection_status not null default 'draft',
  created_by uuid references auth.users(id), created_at timestamptz not null default now()
);
create table public.test_questions (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  competency_id uuid references public.test_competencies(id),
  level_id uuid references public.test_levels(id),
  prompt text not null, item_type text not null default 'single_choice',
  points numeric not null default 1, rubric jsonb not null default '{}'::jsonb,
  sort_order int not null default 0
);
create table public.test_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.test_questions(id) on delete cascade,
  label text not null, is_correct boolean not null default false, sort_order int not null default 0
);
create table public.test_sessions (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  respondent_id uuid references public.respondents(id) on delete set null,
  school_id uuid references public.schools(id) on delete cascade,
  started_at timestamptz not null default now(), submitted_at timestamptz,
  status text not null default 'in_progress', saved_state jsonb not null default '{}'::jsonb
);
create table public.test_answers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.test_sessions(id) on delete cascade,
  question_id uuid not null references public.test_questions(id) on delete cascade,
  answer_text text, selected_option_ids uuid[] not null default '{}',
  points_awarded numeric, reviewed_by uuid references auth.users(id),
  unique(session_id, question_id)
);
create table public.scoring_rubrics (
  id uuid primary key default gen_random_uuid(),
  test_question_id uuid not null references public.test_questions(id) on delete cascade,
  rubric jsonb not null, version int not null default 1
);
create table public.test_results (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique references public.test_sessions(id) on delete cascade,
  total_points numeric, max_points numeric, percent_score numeric,
  correct_count int, incorrect_count int, unanswered_count int,
  duration_seconds int, calculated_at timestamptz not null default now()
);
create table public.competency_results (
  id uuid primary key default gen_random_uuid(),
  test_result_id uuid not null references public.test_results(id) on delete cascade,
  competency_id uuid not null references public.test_competencies(id) on delete cascade,
  earned_points numeric, max_points numeric, percent_score numeric
);

create table public.analysis_results (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  period_id uuid references public.assessment_periods(id) on delete set null,
  analysis_type text not null, evidence jsonb not null default '{}'::jsonb,
  findings jsonb not null default '{}'::jsonb,
  generated_by text not null default 'statistics',
  created_at timestamptz not null default now()
);
create table public.analytics_snapshots (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  period_id uuid references public.assessment_periods(id) on delete set null,
  metric_key text not null, metric_value numeric,
  sample_size int not null default 0, dimensions jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  period_id uuid references public.assessment_periods(id) on delete set null,
  title text not null, version int not null default 1,
  status text not null default 'draft', pdf_path text, xlsx_path text,
  methodology_version text, generated_at timestamptz
);
create table public.recommendations (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  report_id uuid references public.reports(id) on delete cascade,
  priority text, problem text, action text, expected_outcome text,
  evidence jsonb not null default '{}'::jsonb
);
create table public.development_plans (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  title text not null, duration_days int not null,
  starts_on date, status text not null default 'draft'
);
create table public.development_tasks (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.development_plans(id) on delete cascade,
  problem text, action text not null, responsible_person text,
  deadline date, expected_result text, indicator text,
  reassessment_date date, status text not null default 'planned'
);
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  school_id uuid references public.schools(id) on delete set null,
  action text not null, entity_type text, entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Role and school helpers
create or replace function public.current_app_role()
returns public.app_role language sql stable security definer
set search_path = public as $$
  select role from public.profiles where id = auth.uid()
$$;
create or replace function public.current_school_id()
returns uuid language sql stable security definer
set search_path = public as $$
  select school_id from public.profiles where id = auth.uid()
$$;
create or replace function public.is_platform_admin()
returns boolean language sql stable security definer
set search_path = public as $$
  select coalesce(public.current_app_role() = 'super_admin', false)
$$;

alter table public.schools enable row level security;
alter table public.profiles enable row level security;
alter table public.respondents enable row level security;
alter table public.student_profiles enable row level security;
alter table public.teacher_profiles enable row level security;
alter table public.parent_profiles enable row level security;
alter table public.director_profiles enable row level security;
alter table public.psychologist_profiles enable row level security;
alter table public.mahalla_profiles enable row level security;
alter table public.questionnaires enable row level security;
alter table public.questionnaire_sections enable row level security;
alter table public.questions enable row level security;
alter table public.answer_options enable row level security;
alter table public.responses enable row level security;
alter table public.answers enable row level security;
alter table public.assessment_periods enable row level security;
alter table public.test_categories enable row level security;
alter table public.test_competencies enable row level security;
alter table public.test_levels enable row level security;
alter table public.tests enable row level security;
alter table public.test_questions enable row level security;
alter table public.test_options enable row level security;
alter table public.test_sessions enable row level security;
alter table public.test_answers enable row level security;
alter table public.scoring_rubrics enable row level security;
alter table public.test_results enable row level security;
alter table public.competency_results enable row level security;
alter table public.analysis_results enable row level security;
alter table public.analytics_snapshots enable row level security;
alter table public.reports enable row level security;
alter table public.recommendations enable row level security;
alter table public.development_plans enable row level security;
alter table public.development_tasks enable row level security;
alter table public.audit_logs enable row level security;

-- Profiles: users may read their own profile; platform admins may read all.
create policy "profiles_read_self_or_super" on public.profiles for select
using (id = auth.uid() or public.is_platform_admin());
create policy "profiles_update_self" on public.profiles for update
using (id = auth.uid()) with check (id = auth.uid());

-- Schools are visible to members of that school; super admin sees all.
create policy "schools_read_scope" on public.schools for select
using (public.is_platform_admin() or id = public.current_school_id());

-- School-scoped policies for tables that carry school_id directly.
do $$
declare t text;
begin
  foreach t in array array[
    'respondents','questionnaires','responses','assessment_periods','tests',
    'test_sessions','test_results','analysis_results','analytics_snapshots',
    'reports','recommendations','development_plans','audit_logs'
  ] loop
    execute format(
      'create policy %I on public.%I for all using (public.is_platform_admin() or school_id = public.current_school_id()) with check (public.is_platform_admin() or school_id = public.current_school_id())',
      t || '_school_scope', t
    );
  end loop;
end $$;

-- Child records inherit access from their owning respondent/questionnaire/test.
create policy "student_profiles_school_scope" on public.student_profiles for all
using (public.is_platform_admin() or exists (
  select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()
));
create policy "teacher_profiles_school_scope" on public.teacher_profiles for all
using (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()));
create policy "parent_profiles_school_scope" on public.parent_profiles for all
using (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()));
create policy "director_profiles_school_scope" on public.director_profiles for all
using (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()));
create policy "psychologist_profiles_school_scope" on public.psychologist_profiles for all
using (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()));
create policy "mahalla_profiles_school_scope" on public.mahalla_profiles for all
using (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.respondents r where r.id = respondent_id and r.school_id = public.current_school_id()));

create policy "questionnaire_sections_school_scope" on public.questionnaire_sections for all
using (public.is_platform_admin() or exists (select 1 from public.questionnaires q where q.id = questionnaire_id and q.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.questionnaires q where q.id = questionnaire_id and q.school_id = public.current_school_id()));
create policy "questions_school_scope" on public.questions for all
using (public.is_platform_admin() or exists (
  select 1 from public.questionnaire_sections s join public.questionnaires q on q.id = s.questionnaire_id
  where s.id = section_id and q.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.questionnaire_sections s join public.questionnaires q on q.id = s.questionnaire_id
  where s.id = section_id and q.school_id = public.current_school_id()
));
create policy "answer_options_school_scope" on public.answer_options for all
using (public.is_platform_admin() or exists (
  select 1 from public.questions x join public.questionnaire_sections s on s.id = x.section_id
  join public.questionnaires q on q.id = s.questionnaire_id
  where x.id = question_id and q.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.questions x join public.questionnaire_sections s on s.id = x.section_id
  join public.questionnaires q on q.id = s.questionnaire_id
  where x.id = question_id and q.school_id = public.current_school_id()
));
create policy "answers_school_scope" on public.answers for all
using (public.is_platform_admin() or exists (select 1 from public.responses r where r.id = response_id and r.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.responses r where r.id = response_id and r.school_id = public.current_school_id()));

create policy "test_questions_school_scope" on public.test_questions for all
using (public.is_platform_admin() or exists (select 1 from public.tests t where t.id = test_id and t.school_id = public.current_school_id()))
with check (public.is_platform_admin() or exists (select 1 from public.tests t where t.id = test_id and t.school_id = public.current_school_id()));
create policy "test_options_school_scope" on public.test_options for all
using (public.is_platform_admin() or exists (
  select 1 from public.test_questions q join public.tests t on t.id = q.test_id
  where q.id = question_id and t.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.test_questions q join public.tests t on t.id = q.test_id
  where q.id = question_id and t.school_id = public.current_school_id()
));
create policy "test_answers_school_scope" on public.test_answers for all
using (public.is_platform_admin() or exists (
  select 1 from public.test_sessions s where s.id = session_id and s.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.test_sessions s where s.id = session_id and s.school_id = public.current_school_id()
));
create policy "scoring_rubrics_school_scope" on public.scoring_rubrics for all
using (public.is_platform_admin() or exists (
  select 1 from public.test_questions q join public.tests t on t.id = q.test_id
  where q.id = test_question_id and t.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.test_questions q join public.tests t on t.id = q.test_id
  where q.id = test_question_id and t.school_id = public.current_school_id()
));
create policy "competency_results_school_scope" on public.competency_results for all
using (public.is_platform_admin() or exists (
  select 1 from public.test_results tr join public.test_sessions ts on ts.id = tr.session_id
  where tr.id = test_result_id and ts.school_id = public.current_school_id()
))
with check (public.is_platform_admin() or exists (
  select 1 from public.test_results tr join public.test_sessions ts on ts.id = tr.session_id
  where tr.id = test_result_id and ts.school_id = public.current_school_id()
));

-- Lookup/reference tables are readable by authenticated users.
create policy "test_categories_read" on public.test_categories for select to authenticated using (true);
create policy "test_levels_read" on public.test_levels for select to authenticated using (true);

-- Before production: add finer-grained policies for student/parent own-record access and respondent consent workflows.
