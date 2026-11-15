-- TCU Business Management forum: shared read, verified school-email writing,
-- owner-only deletion, plus moderation for the designated administrator.

create table if not exists public.forum_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  category text not null check (category in ('general', 'courses', 'internships', 'events', 'ideas')),
  title text not null check (length(btrim(title)) between 1 and 100),
  body text not null check (length(btrim(body)) between 1 and 2000),
  anonymous boolean not null default true,
  display_name text check (display_name is null or length(btrim(display_name)) between 1 and 60),
  created_at timestamptz not null default now()
);

create table if not exists public.forum_replies (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.forum_posts(id) on delete cascade,
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  body text not null check (length(btrim(body)) between 1 and 1000),
  anonymous boolean not null default true,
  display_name text check (display_name is null or length(btrim(display_name)) between 1 and 60),
  created_at timestamptz not null default now()
);

alter table public.forum_posts enable row level security;
alter table public.forum_replies enable row level security;
revoke all on table public.forum_posts, public.forum_replies from anon, authenticated;
grant select on table public.forum_posts, public.forum_replies to anon, authenticated;
grant insert, delete on table public.forum_posts, public.forum_replies to authenticated;

drop policy if exists "Forum posts are publicly readable" on public.forum_posts;
create policy "Forum posts are publicly readable" on public.forum_posts
  for select to anon, authenticated using (true);
drop policy if exists "School members can create forum posts" on public.forum_posts;
create policy "School members can create forum posts" on public.forum_posts
  for insert to authenticated with check (
    author_id = (select auth.uid())
    and lower(coalesce((select auth.jwt() ->> 'email'), '')) ~ '^[^@]+@gms\.tcu\.edu\.tw$'
  );
drop policy if exists "Owners and the named administrator can delete forum posts" on public.forum_posts;
create policy "Owners and the named administrator can delete forum posts" on public.forum_posts
  for delete to authenticated using (
    author_id = (select auth.uid())
    or lower(coalesce((select auth.jwt() ->> 'email'), '')) = '113114202@gms.tcu.edu.tw'
  );

drop policy if exists "Forum replies are publicly readable" on public.forum_replies;
create policy "Forum replies are publicly readable" on public.forum_replies
  for select to anon, authenticated using (true);
drop policy if exists "School members can create forum replies" on public.forum_replies;
create policy "School members can create forum replies" on public.forum_replies
  for insert to authenticated with check (
    author_id = (select auth.uid())
    and lower(coalesce((select auth.jwt() ->> 'email'), '')) ~ '^[^@]+@gms\.tcu\.edu\.tw$'
  );
drop policy if exists "Owners and the named administrator can delete forum replies" on public.forum_replies;
create policy "Owners and the named administrator can delete forum replies" on public.forum_replies
  for delete to authenticated using (
    author_id = (select auth.uid())
    or lower(coalesce((select auth.jwt() ->> 'email'), '')) = '113114202@gms.tcu.edu.tw'
  );

create index if not exists forum_posts_created_at_idx on public.forum_posts (created_at desc);
create index if not exists forum_replies_post_id_created_at_idx on public.forum_replies (post_id, created_at);
create index if not exists forum_posts_author_id_idx on public.forum_posts (author_id);
create index if not exists forum_replies_author_id_idx on public.forum_replies (author_id);
