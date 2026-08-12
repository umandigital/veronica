-- =====================================================================
-- Verônica Vargas Semijoias — configuração do Supabase
-- =====================================================================
-- Como usar:
--   1. Supabase → SQL Editor → New query → cole este arquivo → Run.
--   2. Authentication → Users → Add user:
--        e-mail: uman.agencia@gmail.com
--        senha:  a senha combinada
--        marque "Auto Confirm User"
--   3. Rode o bloco final deste arquivo para promover esse usuário a admin.
--   4. A URL do projeto e a chave publishable já vêm preenchidas no site
--      (Área administrativa → Configurações → Supabase). Só troque se o
--      projeto mudar. Use sempre a chave anon/publishable — NUNCA a
--      service_role/secret, que ignora o RLS e não pode ir para o navegador.
--
-- Modelo de acesso: leitura pública (o catálogo é público), escrita apenas
-- para usuários autenticados. A chave anon/publishable é publicável — quem
-- protege a escrita é o RLS abaixo, não o segredo da chave.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------
create table if not exists public.categorias (
  id        text primary key,
  nome      text not null,
  eyebrow   text default 'Coleção',
  altura    text default 'media' check (altura in ('curta','media','alta')),
  imagem    text,
  visivel   boolean not null default true,
  ordem     integer not null default 0,
  criado_em timestamptz not null default now()
);

create table if not exists public.produtos (
  id        text primary key,
  nome      text not null,
  categoria text references public.categorias(id) on delete set null,
  preco     numeric(10,2) not null default 0,
  preco_de  numeric(10,2) not null default 0,
  imagens   jsonb not null default '[]'::jsonb,
  destaque  boolean not null default false,
  visivel   boolean not null default true,
  ordem     integer not null default 0,
  criado_em timestamptz not null default now()
);

-- Configurações do site em uma única linha (id = 1)
create table if not exists public.config (
  id            smallint primary key default 1 check (id = 1),
  valor         jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

-- Perfis espelham auth.users e carregam nome e papel
create table if not exists public.perfis (
  id        uuid primary key references auth.users(id) on delete cascade,
  email     text not null,
  nome      text,
  papel     text not null default 'editor' check (papel in ('admin','editor')),
  criado_em timestamptz not null default now()
);

create index if not exists produtos_categoria_idx on public.produtos(categoria);
create index if not exists produtos_destaque_idx  on public.produtos(destaque) where destaque;

-- ---------------------------------------------------------------------
-- 2. PERFIL AUTOMÁTICO A CADA NOVO USUÁRIO
-- ---------------------------------------------------------------------
create or replace function public.criar_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.perfis (id, email, nome, papel)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'papel', 'editor')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists ao_criar_usuario on auth.users;
create trigger ao_criar_usuario
  after insert on auth.users
  for each row execute function public.criar_perfil();

-- ---------------------------------------------------------------------
-- 3. RLS — leitura pública, escrita autenticada
-- ---------------------------------------------------------------------
alter table public.categorias enable row level security;
alter table public.produtos   enable row level security;
alter table public.config     enable row level security;
alter table public.perfis     enable row level security;

drop policy if exists "categorias leitura publica"  on public.categorias;
drop policy if exists "categorias escrita autenticada" on public.categorias;
create policy "categorias leitura publica"
  on public.categorias for select using (true);
create policy "categorias escrita autenticada"
  on public.categorias for all to authenticated using (true) with check (true);

drop policy if exists "produtos leitura publica"  on public.produtos;
drop policy if exists "produtos escrita autenticada" on public.produtos;
create policy "produtos leitura publica"
  on public.produtos for select using (true);
create policy "produtos escrita autenticada"
  on public.produtos for all to authenticated using (true) with check (true);

drop policy if exists "config leitura publica"  on public.config;
drop policy if exists "config escrita autenticada" on public.config;
create policy "config leitura publica"
  on public.config for select using (true);
create policy "config escrita autenticada"
  on public.config for all to authenticated using (true) with check (true);

-- Perfis: visíveis apenas para quem está autenticado; só admin altera papéis
drop policy if exists "perfis leitura autenticada" on public.perfis;
drop policy if exists "perfis admin gerencia"      on public.perfis;
drop policy if exists "perfis edita a si mesmo"    on public.perfis;
create policy "perfis leitura autenticada"
  on public.perfis for select to authenticated using (true);
create policy "perfis edita a si mesmo"
  on public.perfis for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "perfis admin gerencia"
  on public.perfis for all to authenticated
  using (exists (select 1 from public.perfis p where p.id = auth.uid() and p.papel = 'admin'))
  with check (exists (select 1 from public.perfis p where p.id = auth.uid() and p.papel = 'admin'));

-- ---------------------------------------------------------------------
-- 4. STORAGE — bucket público para fotos das peças, logos e vídeo do hero
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('midia', 'midia', true)
on conflict (id) do update set public = true;

drop policy if exists "midia leitura publica"   on storage.objects;
drop policy if exists "midia envio autenticado" on storage.objects;
drop policy if exists "midia gestao autenticada" on storage.objects;
create policy "midia leitura publica"
  on storage.objects for select using (bucket_id = 'midia');
create policy "midia envio autenticado"
  on storage.objects for insert to authenticated with check (bucket_id = 'midia');
create policy "midia gestao autenticada"
  on storage.objects for update to authenticated using (bucket_id = 'midia');

-- ---------------------------------------------------------------------
-- 5. CATEGORIAS DE PRODUTO
-- ---------------------------------------------------------------------
insert into public.categorias (id, nome, altura, visivel, ordem) values
  ('c1','Anéis',      'media', true, 0),
  ('c2','Brincos',    'alta',  true, 1),
  ('c3','Colares',    'curta', true, 2),
  ('c4','Pulseiras',  'alta',  true, 3),
  ('c5','Braceletes', 'curta', true, 4),
  ('c6','Broches',    'media', true, 5)
on conflict (id) do nothing;

-- Quem rodou uma versão anterior deste arquivo ficou com outra lista de
-- categorias; este bloco acerta nome e ordem sem tocar em imagens ou
-- visibilidade já ajustadas no painel.
--
-- ATENÇÃO: c2 e c3 trocaram de nome entre si (Colares e Brincos) e c5
-- deixou de ser Broches. Se você já tinha subido fotos de categoria, elas
-- seguem presas ao id antigo e podem acabar na categoria errada — confira
-- em Categorias, no painel, e troque as imagens que ficarem trocadas.
update public.categorias set nome = v.nome, altura = v.altura, ordem = v.ordem
  from (values
    ('c1','Anéis','media',0), ('c2','Brincos','alta',1), ('c3','Colares','curta',2),
    ('c4','Pulseiras','alta',3), ('c5','Braceletes','curta',4), ('c6','Broches','media',5)
  ) as v(id, nome, altura, ordem)
 where public.categorias.id = v.id;

insert into public.config (id, valor) values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 6. PERFIS DE QUEM JÁ EXISTIA
--    O gatilho acima só age em usuários criados depois dele. Este bloco
--    cria o perfil de quem já estava em Authentication → Users, de modo
--    que a ordem dos passos deixa de importar.
-- ---------------------------------------------------------------------
insert into public.perfis (id, email, nome, papel)
select u.id,
       u.email,
       coalesce(u.raw_user_meta_data->>'nome', split_part(u.email, '@', 1)),
       coalesce(u.raw_user_meta_data->>'papel', 'editor')
  from auth.users u
 where not exists (select 1 from public.perfis p where p.id = u.id)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 7. PROMOVER O PRIMEIRO ADMIN
--    Não faz nada se o usuário ainda não existir: crie-o em
--    Authentication → Users e rode este arquivo de novo.
-- ---------------------------------------------------------------------
update public.perfis
   set papel = 'admin', nome = 'UMAN'
 where email = 'uman.agencia@gmail.com';

-- ---------------------------------------------------------------------
-- CONFERÊNCIA — o resultado aparece na aba Results
-- ---------------------------------------------------------------------
select
  (select count(*) from public.categorias)              as categorias,
  (select count(*) from public.produtos)                as produtos,
  (select count(*) from public.perfis)                  as usuarios,
  (select count(*) from public.perfis where papel='admin') as admins,
  (select count(*) from storage.buckets where id='midia')  as bucket_midia;

-- Rodar este arquivo mais de uma vez é seguro: nada é duplicado nem perdido.
