# Observatório Eleitoral · Antônia de Jesus

Painel público de demonstração para explorar **resultados agregados oficiais** da candidatura de Antônia de Jesus Barbosa Fernandes (PL 22456) a deputada estadual de São Paulo no primeiro turno de 2026.

## Escopo publicado

- 8.416 votos nominais: 779 registros de zona, 6.803 seções com votos, 333 de 645 municípios com votos.
- Os totais por seção foram conciliados com as respectivas zonas; diferença zero.
- Benchmark de 1.346 candidaturas da mesma eleição, cargo, UF e turno. A posição apresentada ordena votos nominais, não substitui a classificação proporcional oficial.
- Prestação final: R$ 528.549,99 em receitas de candidatos e R$ 529.878,47 em despesas contratadas de candidatos. Esses conjuntos têm escopos diferentes; a diferença não representa saldo de caixa.
- Filtros de município, zona e seção; indicadores, gráficos, mapa ilustrativo, tabela paginada, busca e leitura automática determinística.
- Participação como vice na chapa municipal de 2024 em área separada, sem comparação de voto individual entre eleições.

A aplicação em `dist/` é estática, gratuita para demonstrar e acessível ao público. `dist/data.json` é um retrato dos arquivos oficiais, não uma conexão em tempo real. O mesmo conjunto agregado foi registrado no banco Neon `observatorio_eleitoral` com origem e hashes em `fontes_tse`. Não há serviço de Ollama nem cobrança de modelo: os textos analíticos são gerados por regras transparentes sobre os números apresentados. Uma integração futura com modelo externo requer credencial e orçamento próprios.

## Fontes e atualização

- [Resultados 2026, TSE](https://dadosabertos.tse.jus.br/dataset/resultados-2026): `votacao_candidato_munzona_2026.zip`, `votacao_secao_2026_SP.zip`.
- [Candidaturas 2026, TSE](https://dadosabertos.tse.jus.br/dataset/candidatos-2026): `consulta_cand_2026.zip`.
- [Prestação de contas 2026, TSE](https://dadosabertos.tse.jus.br/dataset/prestacao-de-contas-eleitorais-2026): `prestacao_de_contas_eleitorais_candidatos_2026.zip`.

Extração: 05/11/2026. Os hashes SHA-256 dos ZIPs utilizados constam no painel e no `data.json`. A atualização demanda baixar as fontes, refazer a agregação, conciliar e republicar `dist/data.json`. Não commitar os arquivos ZIP brutos.

## Desenvolvimento

Abra `dist/index.html` com servidor HTTP local para que `fetch('data.json')` funcione. Exemplo: `python -m http.server 8000 --directory dist`. `node --check dist/app.js` verifica a sintaxe; confira também as somas no JSON antes de publicar.

O SQL de `schema.sql` define a estrutura do Neon. Os dados por seção são agregados públicos; nenhum eleitor ou voto individual é identificado. O mapa é apenas esquemático e não deve ser usado para inferir localização precisa.
