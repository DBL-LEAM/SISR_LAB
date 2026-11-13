-- =====================================================================
--  SISR Lab : stockage de la progression des comptes (Supabase)
--
--  Mise en place (une seule fois) :
--   1. Créer un projet gratuit sur https://supabase.com
--   2. SQL Editor > New query > coller ce fichier > Run
--   3. Authentication > Sign In / Providers > Email : laisser activé
--      (« Confirm email » activé = l'élève doit cliquer sur un lien reçu par mail)
--   4. Authentication > URL Configuration :
--        Site URL      = l'adresse du site (ex. https://dbl-leam.github.io/SISR_LAB/)
--        Redirect URLs = la même adresse
--   5. Project Settings > API : copier « Project URL » et la clé « anon public »
--      dans SUPABASE_URL et SUPABASE_ANON_KEY (index.html, section « Comptes »).
--
--  La clé anon est publique : la sécurité repose sur les règles RLS ci-dessous,
--  chaque utilisateur ne peut lire et écrire QUE sa propre ligne.
-- =====================================================================

create table if not exists public.progress (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.progress enable row level security;

drop policy if exists "progress: lire la sienne"     on public.progress;
drop policy if exists "progress: créer la sienne"    on public.progress;
drop policy if exists "progress: modifier la sienne" on public.progress;

create policy "progress: lire la sienne" on public.progress
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "progress: créer la sienne" on public.progress
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "progress: modifier la sienne" on public.progress
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
