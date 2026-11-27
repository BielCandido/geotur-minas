# Dicionário de dados — GeoTur Minas

## 1. Visão geral da base

| Item | Descrição |
|---|---|
| Título | GeoTur Minas: base geográfica sintética de turismo (`geotur_minas`) |
| Descrição e finalidade | Base com regiões turísticas, atrações e rotas fictícias numa área de referência no centro de Minas Gerais. Finalidade acadêmica: demonstrar modelagem, carga, validação e consultas espaciais no PostGIS. Não serve para orientar viagens reais. |
| Autores | Camille Silva, Yuri Lima e Gabriel Nunes (UFOP, CSI803 — Banco de Dados Geográficos) |
| Versão e data | Versão 1.0, elaborada em 25/11/2026 |
| Fonte | Geração própria, sem coleta externa. Todo o processo está em `sql/dados.sql`. Não há dados brutos de terceiros. |
| Método de geração | Determinístico, executado no próprio PostGIS com `generate_series`, `ST_MakeEnvelope`, `ST_MakePoint` e `ST_MakeLine`. Não há aleatoriedade, portanto não há semente: cada execução gera exatamente as mesmas 650 feições. Parâmetros na seção 1.1. |
| Licença | Dados sintéticos e código sob licença MIT (ver `LICENSE`), que permite redistribuição. |
| Cobertura espacial | Grade artificial de referência entre as longitudes -44,0 e -43,8 e as latitudes -20,0 e -19,9 (centro de Minas Gerais). Não corresponde a limites administrativos nem cobre todo o estado. |
| Cobertura temporal | Cenário fictício de novembro de 2026. Não há série histórica. |
| SRID e justificativa | **EPSG:4674 (SIRGAS 2000)**, datum oficial do Brasil, o mesmo das malhas do IBGE, o que facilita cruzar a base com dados oficiais sem reprojeção. Todas as tabelas usam o mesmo SRID. Para medidas em metros, as consultas reprojetam para **EPSG:31983 (SIRGAS 2000 / UTM 23S)**, a zona UTM da área de estudo. |
| Escala e precisão | Não se aplica: as coordenadas são calculadas, não medidas. Os valores têm precisão de 0,001 grau (cerca de 100 m) por construção. |
| Tratamentos aplicados | 1. Geometrias criadas diretamente em SRID 4674, sem reprojeção na carga. 2. Nomes de tabelas e colunas em `snake_case`, sem acentos; texto em UTF-8 (`SET client_encoding = 'UTF8'`). 3. Nenhum valor nulo: todas as colunas são `NOT NULL`. 4. Restrições `CHECK (ST_IsValid(geom) AND NOT ST_IsEmpty(geom))` impedem geometrias inválidas ou vazias; não foi necessário `ST_MakeValid`, pois não há geometria externa a reparar. 5. `sql/validacao.sql` confere contagens, SRID, validade, contenção espacial (`ST_Within`) e cardinalidade por região. |

### 1.1 Parâmetros da geração

| Parâmetro | Valor |
|---|---|
| Grade de regiões | 10 colunas × 5 linhas = 50 células quadradas de 0,02 grau, a partir de (-44,0; -20,0) |
| Atrações por região | 10, em duas filas de cinco; espaçamento de 0,003 grau em x; filas a 0,005 e 0,014 grau da borda inferior da célula |
| Rotas por região | 2: a rota 1 liga as atrações da fila de baixo; a rota 2, as da fila de cima (5 vértices cada) |
| `perfil` | `cultural` para regiões de id ímpar; `natureza` para id par |
| `capacidade` | 100 × `id_regiao` (100 a 5.000) |
| `area_km2` | Calculada da geometria: `ST_Area(ST_Transform(geom, 31983)) / 1.000.000`, arredondada a 3 casas |
| `ano_criacao` | 2000 + (`id_regiao` mod 25), de 2000 a 2024 |
| `categoria` | Cíclica pela posição j (1 a 10) da atração na região: museu, parque, mirante, museu… |
| `visitantes_dia` | 20 × j (20 a 200) |
| `modalidade` / `duracao_min` | Rota 1: caminhada, 30 min; rota 2: bicicleta, 60 min |

Medidas resultantes em EPSG:31983: cada região tem entre 4,632 e 4,635 km² (coluna `area_km2`); cada rota tem entre 1.255,48 e 1.256,25 m. A variação vem apenas da posição na projeção UTM.

## 2. Descrição das tabelas

### Tabela `regiao_turistica`
Células de estudo artificiais. **Geometria:** Polygon · **SRID:** 4674 · **Registros:** 50.

| Coluna | Tipo | Tamanho/Domínio | Nulo? | PK/FK | Descrição | Exemplo |
|---|---|---|---|---|---|---|
| id_regiao | integer | 1 a 50, único | Não | PK | Identificador da região | 1 |
| nome | varchar | 80, único | Não | — | Nome simulado da região | Região 01 |
| perfil | varchar | 20 · ver seção 4 | Não | — | Perfil turístico predominante | cultural |
| capacidade | integer | > 0 | Não | — | Capacidade hipotética de visitantes por dia | 100 |
| area_km2 | numeric | (8,3) · > 0 | Não | — | Área da região em km², calculada da geometria em EPSG:31983 | 4.632 |
| ano_criacao | smallint | 1900 a 2026 | Não | — | Ano hipotético de criação da região turística | 2001 |
| geom | geometry | Polygon, 4674 | Não | — | Limite da célula; válido e não vazio | `POLYGON((-44 -20,-44 -19.98,-43.98 -19.98,-43.98 -20,-44 -20))` |

### Tabela `ponto_turistico`
Atrações fictícias internas às regiões. **Geometria:** Point · **SRID:** 4674 · **Registros:** 500.

| Coluna | Tipo | Tamanho/Domínio | Nulo? | PK/FK | Descrição | Exemplo |
|---|---|---|---|---|---|---|
| id_ponto | integer | 1 a 500, único | Não | PK | Identificador da atração | 1 |
| id_regiao | integer | ver `regiao_turistica` | Não | FK | Região da atração. Referencia `regiao_turistica.id_regiao` | 1 |
| nome | varchar | 80, único | Não | — | Nome simulado da atração | Atração 001 |
| categoria | varchar | 20 · ver seção 4 | Não | — | Categoria da atração | museu |
| visitantes_dia | integer | ≥ 0 | Não | — | Visitação hipotética diária | 20 |
| geom | geometry | Point, 4674 | Não | — | Localização da atração; válida e não vazia | `POINT(-43.997 -19.995)` |

### Tabela `rota_turistica`
Traçados fictícios que conectam atrações de uma mesma região. **Geometria:** LineString · **SRID:** 4674 · **Registros:** 100.

| Coluna | Tipo | Tamanho/Domínio | Nulo? | PK/FK | Descrição | Exemplo |
|---|---|---|---|---|---|---|
| id_rota | integer | 1 a 100, único | Não | PK | Identificador da rota | 1 |
| id_regiao | integer | ver `regiao_turistica` | Não | FK | Região da rota. Referencia `regiao_turistica.id_regiao` | 1 |
| nome | varchar | 80, único | Não | — | Nome simulado da rota | Rota 001 |
| modalidade | varchar | 20 · ver seção 4 | Não | — | Modalidade de deslocamento | caminhada |
| duracao_min | integer | > 0 | Não | — | Duração hipotética em minutos | 30 |
| geom | geometry | LineString, 4674 | Não | — | Traçado com 5 vértices; válido e não vazio | `LINESTRING(-43.997 -19.995,-43.994 -19.995,-43.991 -19.995,-43.988 -19.995,-43.985 -19.995)` |

## 3. Relacionamentos

| Origem | Destino | Tipo | Descrição |
|---|---|---|---|
| `ponto_turistico.id_regiao` | `regiao_turistica.id_regiao` | FK 1:N | Cada região possui dez atrações. |
| `rota_turistica.id_regiao` | `regiao_turistica.id_regiao` | FK 1:N | Cada região possui duas rotas. |
| `ponto_turistico.geom` | `regiao_turistica.geom` | Espacial | `ST_Within`: a atração está contida na sua região; usado em `validacao.sql` para conferir a FK. |
| `rota_turistica.geom` | `regiao_turistica.geom` | Espacial | `ST_Within` e `ST_Intersects`: a rota está contida na sua região e só intersecta ela. |
| `rota_turistica.geom` | `ponto_turistico.geom` | Espacial | Cada rota passa pelas cinco atrações de uma fila da região (vértices coincidentes), sem FK direta. Pode ser consultado com `ST_Intersects`. |

O diagrama está em `docs/der.png`.

## 4. Domínios e códigos

| Coluna | Valor | Significado |
|---|---|---|
| `regiao_turistica.perfil` | cultural | Região com foco em patrimônio e cultura (rótulo hipotético) |
| | natureza | Região com foco em paisagens e ecoturismo (rótulo hipotético) |
| `ponto_turistico.categoria` | museu | Atração do tipo museu |
| | parque | Atração do tipo parque |
| | mirante | Atração do tipo mirante |
| `rota_turistica.modalidade` | caminhada | Rota percorrida a pé |
| | bicicleta | Rota percorrida de bicicleta |

Distribuição: 25 regiões de cada perfil; 200 museus, 150 parques e 150 mirantes; 50 rotas de cada modalidade.

## 5. Qualidade e limitações

- **Dados fictícios:** nomes, categorias, capacidade, visitação e duração não são estimativas reais.
- **Geometria esquemática:** regiões são quadrados de grade e rotas são linhas retas; não há rede viária, relevo nem acessibilidade.
- **Cobertura:** área pequena no centro de Minas Gerais; não representa o estado.
- **Uso:** não usar para navegação ou decisões públicas.
- **Validação:** `sql/validacao.sql` interrompe a execução com erro se alguma contagem, SRID, geometria ou relação espacial falhar, e emite `650 feições: validação aprovada` em caso de sucesso. Executada com aprovação em 26/11/2026 (PostgreSQL 16.16 e PostGIS 3.4.2).
