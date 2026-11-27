#!/bin/sh
# Importa a base GeoTur Minas num banco novo (Linux / macOS).
# Uso, na raiz do repositório:  sh scripts/importar.sh [usuario] [banco]
set -e
USUARIO="${1:-postgres}"
BANCO="${2:-geotur_minas}"
export PGCLIENTENCODING=UTF8
createdb -U "$USUARIO" -E UTF8 -T template0 "$BANCO"
for arquivo in schema.sql dados.sql validacao.sql consultas.sql; do
  echo "Executando sql/$arquivo..."
  psql -U "$USUARIO" -d "$BANCO" -v ON_ERROR_STOP=1 -f "sql/$arquivo"
done
echo "Importação concluída."
