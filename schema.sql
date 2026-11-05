-- Observatório Eleitoral: estrutura para dados agregados oficiais do TSE.
-- Aplicar no Neon somente após conectar e validar a base de destino.
-- Não armazena identidade de eleitores nem infere voto individual.

create table if not exists fontes_tse (
  id bigint generated always as identity primary key,
  ano integer not null check (ano between 1994 and 2100),
  conjunto text not null,
  recurso text not null,
  url text not null,
  sha256 char(64),
  consultado_em timestamptz not null default now(),
  importado_em timestamptz,
  linhas_lidas bigint,
  linhas_aceitas bigint,
  unique (ano, recurso, url, sha256)
);

create table if not exists eleicoes (
  id bigint generated always as identity primary key,
  ano integer not null,
  turno smallint not null check (turno in (1, 2)),
  uf char(2) not null,
  cargo text not null,
  municipio_tse integer,
  unique nulls not distinct (ano, turno, uf, cargo, municipio_tse)
);

create table if not exists candidaturas (
  id bigint generated always as identity primary key,
  eleicao_id bigint not null references eleicoes(id),
  sq_candidato bigint not null,
  nome_completo text not null,
  nome_urna text not null,
  numero integer not null,
  partido text not null,
  situacao text,
  resultado text,
  tipo_voto text not null check (tipo_voto in ('nominal', 'chapa')),
  fonte_id bigint not null references fontes_tse(id),
  unique (eleicao_id, sq_candidato)
);

create table if not exists votos_zona (
  eleicao_id bigint not null references eleicoes(id),
  candidatura_id bigint not null references candidaturas(id),
  municipio_tse integer not null,
  municipio text not null,
  zona integer not null,
  votos integer not null check (votos >= 0),
  fonte_id bigint not null references fontes_tse(id),
  primary key (candidatura_id, municipio_tse, zona)
);

create table if not exists votos_secao (
  eleicao_id bigint not null references eleicoes(id),
  candidatura_id bigint not null references candidaturas(id),
  municipio_tse integer not null,
  zona integer not null,
  secao integer not null,
  votos integer not null check (votos >= 0),
  fonte_id bigint not null references fontes_tse(id),
  primary key (candidatura_id, municipio_tse, zona, secao)
);

create table if not exists contas_campanha (
  candidatura_id bigint primary key references candidaturas(id),
  receita_total numeric(18,2),
  despesa_total numeric(18,2),
  fonte_id bigint not null references fontes_tse(id),
  atualizado_em timestamptz not null default now()
);

create table if not exists notas_analiticas (
  id bigint generated always as identity primary key,
  eleicao_id bigint not null references eleicoes(id),
  modelo text not null,
  versao_prompt text not null,
  escopo_json jsonb not null,
  indicadores_json jsonb not null,
  texto text not null,
  revisado boolean not null default false,
  criado_em timestamptz not null default now()
);

create index if not exists votos_zona_eleicao_local on votos_zona (eleicao_id, municipio_tse, zona);
create index if not exists votos_secao_eleicao_local on votos_secao (eleicao_id, municipio_tse, zona, secao);
create index if not exists candidaturas_benchmark on candidaturas (eleicao_id, partido, numero);

-- Prévia secundária em tabela distinta. Nunca promover a TSE conciliado sem
-- conferir os arquivos oficiais e seus totais em cada nível de agregação.
create table if not exists resumo_preliminar (
  ano integer not null,
  cargo text not null,
  municipio text,
  votos integer not null check (votos >= 0),
  fonte_url text not null,
  status_validacao text not null check (status_validacao in ('secundaria_pendente_tse', 'tse_conciliado')),
  registrado_em timestamptz not null default now(),
  unique nulls not distinct (ano, cargo, municipio)
);

-- Auditoria essencial antes de publicar: a soma por zona deve conferir com
-- o total oficial; a soma por seção deve conferir com a soma por zona.
-- A vice-prefeitura em 2024 registra voto de chapa, sem comparação de
-- crescimento nominal com a candidatura proporcional de 2026.
