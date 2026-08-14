# Banco de dados

A integração do Supabase com o GitHub está ligada em
**umandigital/veronica**, diretório de trabalho `.`, branch de produção
`main`. Ao dar merge em `main`, o Supabase aplica sozinho as migrações
daqui que ainda não rodaram naquele banco.

## Regra que importa

**Cada mudança de estrutura é um arquivo novo. Nunca se edita um arquivo
que já foi aplicado.**

O Supabase guarda numa tabela interna quais migrações já rodaram, pelo
carimbo de tempo do nome do arquivo. Editar um arquivo já aplicado não
tem efeito nenhum: para o Supabase, aquela migração está feita.

O nome segue `AAAAMMDDHHMMSS_descricao.sql`, em ordem cronológica:

```
20260812093000_estrutura.sql          <- aplicada ao dar merge em main
20260901101500_taxa_de_entrega.sql    <- exemplo de uma próxima
```

## Por que a primeira migração cria tudo de uma vez

O banco foi montado à mão, antes desta integração existir, e a tabela de
controle do Supabase está vazia — para ele, nenhuma migração rodou ainda.
Então a primeira vai tentar criar tudo.

Isso é seguro porque o arquivo é idempotente do começo ao fim:
`create table if not exists`, `add column if not exists`, `on conflict do
nothing`, e cada política é derrubada antes de ser recriada. Rodar num
banco que já tem tudo não duplica nem apaga nada — foi testado em três
execuções seguidas contra um Postgres limpo e contra um já povoado.

## Quando ainda vale colar à mão

Se precisar aplicar algo sem passar por `main` — um teste, uma correção
urgente — dá para colar o conteúdo do arquivo no **SQL Editor** do painel
do Supabase. O resultado é o mesmo; o que muda é que o Supabase não
registra a migração como aplicada, e ela vai rodar de novo no próximo
merge. Como é idempotente, também não faz mal.
