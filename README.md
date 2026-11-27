# GeoTur Minas
Modelagem e documentação de uma base geográfica sintética de turismo no centro de Minas Gerais, para PostgreSQL + PostGIS.

UFOP — CSI803 — Banco de Dados Geográficos — Professor Bruno R. Monteiro.
Autores: Camille Silva, Yuri Lima e Gabriel Nunes.

## Descrição
A base tem três tabelas espaciais relacionadas, com 650 feições no total:

| Tabela | Geometria | Registros | Conteúdo |
|---|---|---|---|
| `regiao_turistica` | Polygon | 50 | Regiões de estudo artificiais |
| `ponto_turistico` | Point | 500 | Atrações fictícias (museu, parque, mirante) |
| `rota_turistica` | LineString | 100 | Rotas fictícias de caminhada e bicicleta |

SRID 4674 (SIRGAS 2000) em todas as tabelas; medidas em metros com reprojeção para 31983 (UTM 23S). Chaves primárias e estrangeiras, restrições `NOT NULL`, `UNIQUE` e `CHECK`, e índices espaciais GiST. A documentação completa está em [`DICIONARIO.md`](DICIONARIO.md) e o diagrama em [`docs/der.png`](docs/der.png).

## Fonte e licença dos dados
Geração própria e determinística (sem aleatoriedade), versão 1.0, 25/11/2026, feita por `sql/dados.sql`. Não há coleta de fontes externas. Os dados são fictícios: não são oficiais nem representam todo o estado. Dados e código sob licença MIT (ver [`LICENSE`](LICENSE)).

## Requisitos
- PostgreSQL **16.16** e PostGIS **3.4.2** (GEOS 3.12.1, PROJ 8.2.1), versões usadas no teste. Outras versões 16.x e PostGIS 3.x devem funcionar, mas não foram testadas.
- `psql` e `createdb` no PATH (vêm com o PostgreSQL), ou o pgAdmin 4.

## Importação
Abra um terminal na raiz do repositório e use um banco novo.

**Opção 1: script pronto**

Windows (PowerShell):
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\importar.ps1 -Usuario postgres
```
Linux/macOS:
```sh
sh scripts/importar.sh postgres
```

**Opção 2: comandos manuais**
```sh
createdb -U postgres -E UTF8 -T template0 geotur_minas
psql -U postgres -d geotur_minas -v ON_ERROR_STOP=1 -f sql/schema.sql
psql -U postgres -d geotur_minas -v ON_ERROR_STOP=1 -f sql/dados.sql
psql -U postgres -d geotur_minas -v ON_ERROR_STOP=1 -f sql/validacao.sql
psql -U postgres -d geotur_minas -v ON_ERROR_STOP=1 -f sql/consultas.sql
```

**Opção 3: pgAdmin 4**
Crie um banco com codificação UTF8, abra a Query Tool nele e execute `sql/schema.sql`, `sql/dados.sql`, `sql/validacao.sql` e `sql/consultas.sql`, nessa ordem.

Não repita a carga no mesmo banco: as chaves primárias impedem duplicação. Para recomeçar, apague o banco (`dropdb -U postgres geotur_minas`) e crie de novo.

**Resultado esperado:** `validacao.sql` mostra as versões instaladas, as contagens (50, 500 e 100) e a mensagem `NOTICE: 650 feições: validação aprovada` (em português: `NOTA:`). Qualquer falha interrompe a execução com erro. No PowerShell, essa mensagem pode aparecer em vermelho porque o psql a escreve na saída de erro; isso é normal.

**Teste em banco limpo:** executado em 26/11/2026 no Windows 11, com PostgreSQL 16.16 (instalador EDB) e PostGIS 3.4.2 (Stack Builder), sem erros: 650 feições carregadas e validação aprovada.

### Problema conhecido no Windows
Se `CREATE EXTENSION postgis` falhar com `não foi possível carregar a biblioteca ".../postgis-3.dll": unknown error 126`, falta a DLL `libwinpthread-1.dll` na pasta `bin`. Ela vem no próprio pacote do PostGIS, numa subpasta. Num PowerShell como administrador:
```powershell
Copy-Item "C:\Program Files\PostgreSQL\16\bin\postgisgui\libwinpthread-1.dll" "C:\Program Files\PostgreSQL\16\bin\"
Restart-Service postgresql-x64-16
```
Depois apague o banco criado na tentativa (`dropdb -U postgres geotur_minas`) e importe de novo.

## Estrutura
```
geotur-minas/
├── README.md          # descrição, fonte, requisitos, importação, citação
├── DICIONARIO.md      # dicionário de dados
├── LICENSE            # licença MIT
├── sql/
│   ├── schema.sql     # extensão, tabelas, restrições e índices
│   ├── dados.sql      # geração e carga reproduzível das 650 feições
│   ├── validacao.sql  # testes de integridade
│   └── consultas.sql  # consultas espaciais de exemplo
├── dados/
│   ├── brutos/        # vazio: não há dados externos
│   └── tratados/      # vazio: os dados são gerados por sql/dados.sql
├── scripts/
│   ├── importar.ps1   # importação automática (Windows)
│   └── importar.sh    # importação automática (Linux/macOS)
└── docs/
    └── der.png        # diagrama entidade-relacionamento
```

## Como citar
SILVA, Camille; LIMA, Yuri; NUNES, Gabriel. **GeoTur Minas: base geográfica sintética de turismo**. Versão 1.0. João Monlevade: UFOP, 2026. Disponível em: <https://github.com/BielCandido/geotur-minas>.
