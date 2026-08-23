-- =====================================================================
-- Publicações do Instagram exibidas antes do rodapé
-- =====================================================================
-- Arquivo novo, não edição do anterior: o Supabase registra as migrações
-- já aplicadas pelo carimbo de tempo do nome, e mexer numa que já rodou
-- não teria efeito nenhum.
--
-- Por que o conteúdo fica aqui e não vem do Instagram: desde 2020 a Meta
-- não entrega as publicações de um perfil para uma página comum. Seria
-- preciso app da Meta, conta comercial ligada a uma página do Facebook e
-- um token que vence a cada 60 dias — e token não pode ficar no navegador.
-- =====================================================================

create table if not exists public.instagram (
  id        text primary key,
  imagem    text not null default '',
  link      text,
  legenda   text,
  visivel   boolean not null default true,
  ordem     integer not null default 0,
  criado_em timestamptz not null default now()
);

alter table public.instagram enable row level security;

drop policy if exists "instagram leitura publica"    on public.instagram;
drop policy if exists "instagram escrita autenticada" on public.instagram;
create policy "instagram leitura publica"
  on public.instagram for select using (true);
create policy "instagram escrita autenticada"
  on public.instagram for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- CONFERÊNCIA
-- ---------------------------------------------------------------------
select
  (select count(*) from public.faq)       as duvidas,
  (select count(*) from public.instagram) as publicacoes;
