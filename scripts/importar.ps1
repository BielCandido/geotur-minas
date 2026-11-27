# Importa a base GeoTur Minas num banco novo (Windows / PowerShell).
# Uso, na raiz do repositório:  .\scripts\importar.ps1
# Parâmetros opcionais: -Usuario postgres -Banco geotur_minas -Servidor localhost -Porta 5432
param(
    [string]$Usuario = "postgres",
    [string]$Banco = "geotur_minas",
    [string]$Servidor = "localhost",
    [int]$Porta = 5432
)
$ErrorActionPreference = "Stop"
$env:PGCLIENTENCODING = "UTF8"
# Faz o console exibir corretamente os acentos que o psql envia em UTF-8.
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$raiz = Split-Path -Parent $PSScriptRoot

& createdb -h $Servidor -p $Porta -U $Usuario -E UTF8 -T template0 $Banco
if ($LASTEXITCODE -ne 0) { throw "Falha ao criar o banco $Banco (ele já existe?)" }

foreach ($arquivo in "schema.sql", "dados.sql", "validacao.sql", "consultas.sql") {
    Write-Host "Executando sql/$arquivo..."
    & psql -h $Servidor -p $Porta -U $Usuario -d $Banco -v ON_ERROR_STOP=1 -f (Join-Path $raiz "sql\$arquivo")
    if ($LASTEXITCODE -ne 0) { throw "Falha em sql/$arquivo" }
}
Write-Host "Importação concluída."
