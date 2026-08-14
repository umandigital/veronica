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
  imagem    text,
  video     text,
  visivel   boolean not null default true,
  ordem     integer not null default 0,
  criado_em timestamptz not null default now()
);

-- Colunas novas para quem criou a tabela numa versão anterior
alter table public.categorias add column if not exists video text;
alter table public.categorias alter column nome drop not null;

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

-- Perguntas frequentes da dobra "Dúvidas"
create table if not exists public.faq (
  id        text primary key,
  pergunta  text not null,
  resposta  text not null default '',
  visivel   boolean not null default true,
  ordem     integer not null default 0,
  criado_em timestamptz not null default now()
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
alter table public.faq        enable row level security;
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

drop policy if exists "faq leitura publica"  on public.faq;
drop policy if exists "faq escrita autenticada" on public.faq;
create policy "faq leitura publica"
  on public.faq for select using (true);
create policy "faq escrita autenticada"
  on public.faq for all to authenticated using (true) with check (true);

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
insert into public.categorias (id, nome, visivel, ordem) values
  ('c1','Anéis',      true, 0),
  ('c2','Brincos',    true, 1),
  ('c3','Colares',    true, 2),
  ('c4','Pulseiras',  true, 3),
  ('c5','Braceletes', true, 4),
  ('c6','Broches',    true, 5),
  ('c7','Conjuntos',  true, 6)
on conflict (id) do nothing;

-- Quem rodou uma versão anterior deste arquivo ficou com outra lista de
-- categorias; este bloco acerta nome e ordem sem tocar em imagens ou
-- visibilidade já ajustadas no painel.
--
-- ATENÇÃO: c2 e c3 trocaram de nome entre si (Colares e Brincos) e c5
-- deixou de ser Broches. Se você já tinha subido fotos de categoria, elas
-- seguem presas ao id antigo e podem acabar na categoria errada — confira
-- em Categorias, no painel, e troque as imagens que ficarem trocadas.
update public.categorias set nome = v.nome, ordem = v.ordem
  from (values
    ('c1','Anéis',0), ('c2','Brincos',1), ('c3','Colares',2), ('c4','Pulseiras',3),
    ('c5','Braceletes',4), ('c6','Broches',5), ('c7','Conjuntos',6)
  ) as v(id, nome, ordem)
 where public.categorias.id = v.id;

insert into public.config (id, valor) values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 5b. DÚVIDAS FREQUENTES
--     Ponto de partida; tudo editável em Área administrativa → Dúvidas.
--     `do nothing` para não desfazer o que já foi ajustado no painel.
-- ---------------------------------------------------------------------
insert into public.faq (id, pergunta, resposta, visivel, ordem) values
  ('f1','O que é, afinal, uma semijoia?',
        'Uma base de metal nobre revestida por uma espessa camada de ouro ou ródio. O brilho e a presença são de joia fina; o preço é de peça para usar no dia a dia, sem medo.', true, 0),
  ('f2','Quanto tempo o banho dura?',
        'Depende de duas coisas: a espessura da camada e o uso. Perfume, suor, cloro e produtos de limpeza são o que mais desgasta. Com os cuidados abaixo, a peça mantém o brilho por muito mais tempo.', true, 1),
  ('f3','Posso dormir, nadar ou tomar banho com a peça?',
        'Melhor não. Água, cloro e o atrito do travesseiro desgastam o banho. Retire antes — é o hábito que mais prolonga a vida da peça.', true, 2),
  ('f4','Perfume e creme estragam a semijoia?',
        'Em contato direto, sim: álcool, perfume e cremes atacam a camada. Coloque a peça por último, depois de tudo pronto, e ela agradece.', true, 3),
  ('f5','Como devo guardar?',
        'Em local seco, longe de luz e umidade. Se possível, cada peça em seu saquinho individual — assim uma não risca a outra.', true, 4),
  ('f6','E para limpar?',
        'Um pano seco e macio depois do uso, para tirar suor e resíduo. Nada de produto de limpeza, pasta de dente ou álcool.', true, 5),
  ('f7','Como faço o pedido?',
        'Escolha a peça e a quantidade no catálogo e toque em pedir. A mensagem chega pronta no WhatsApp, com a peça já identificada — dali em diante é conversa direta com Verônica.', true, 6),
  ('f8','Como combino pagamento e entrega?',
        'Direto com Verônica, pelo WhatsApp. Ela passa as formas de pagamento e combina entrega ou envio conforme onde você está.', true, 7),
  ('f9','Não sei meu tamanho de anel. E agora?',
        'Chame no WhatsApp antes de fechar o pedido. Verônica explica como medir em casa, com um barbante ou uma tira de papel, e confere o tamanho com você.', true, 8),
  ('f10','Dá para pedir embalagem de presente?',
        'Dá — é só avisar na mensagem. Diga também se é para entregar direto a quem vai receber, que Verônica prepara desse jeito.', true, 9)
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
  (select count(*) from public.faq)                     as duvidas,
  (select count(*) from public.perfis)                  as usuarios,
  (select count(*) from public.perfis where papel='admin') as admins,
  (select count(*) from storage.buckets where id='midia')  as bucket_midia;

-- Rodar este arquivo mais de uma vez é seguro: nada é duplicado nem perdido.
