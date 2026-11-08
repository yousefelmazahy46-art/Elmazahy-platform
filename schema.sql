create table public.profiles(id uuid primary key references auth.users(id) on delete cascade,full_name text not null default '',role text not null default 'student' check(role in('student','teacher')));
create table public.subjects(id bigint generated always as identity primary key,name text unique not null);
create table public.courses(id bigint generated always as identity primary key,subject_id bigint references public.subjects(id),title text not null,description text default '');
create table public.lessons(id bigint generated always as identity primary key,course_id bigint references public.courses(id),title text not null,video_url text,pdf_url text);
create table public.exams(id bigint generated always as identity primary key,subject_id bigint references public.subjects(id),title text not null,duration_minutes int default 30,is_published boolean default false);
create table public.questions(id bigint generated always as identity primary key,exam_id bigint references public.exams(id),question_text text not null,options jsonb not null default '[]',correct_option int not null,points numeric default 1);
create table public.exam_attempts(id bigint generated always as identity primary key,exam_id bigint references public.exams(id),student_id uuid references auth.users(id),score numeric default 0,submitted_at timestamptz default now());
alter table public.profiles enable row level security;alter table public.subjects enable row level security;alter table public.courses enable row level security;alter table public.lessons enable row level security;alter table public.exams enable row level security;alter table public.questions enable row level security;alter table public.exam_attempts enable row level security;
create policy "read own profile" on public.profiles for select using(auth.uid()=id);
create policy "read subjects" on public.subjects for select to authenticated using(true);
create policy "read courses" on public.courses for select to authenticated using(true);
create policy "read lessons" on public.lessons for select to authenticated using(true);
create policy "read published exams" on public.exams for select to authenticated using(is_published);
create policy "read questions" on public.questions for select to authenticated using(true);
create policy "read own attempts" on public.exam_attempts for select to authenticated using(student_id=auth.uid());
insert into public.subjects(name) values('اللغة العربية'),('البرمجة'),('التاريخ'),('اللغة الإنجليزية') on conflict do nothing;
-- Configure teacher privileges and secure exam answer handling before production use.
