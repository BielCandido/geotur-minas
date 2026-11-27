BEGIN;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE TABLE regiao_turistica (
  id_regiao integer NOT NULL PRIMARY KEY,
  nome varchar(80) NOT NULL UNIQUE,
  perfil varchar(20) NOT NULL CHECK (perfil IN ('cultural','natureza')),
  capacidade integer NOT NULL CHECK (capacidade > 0),
  geom geometry(Polygon,4674) NOT NULL CHECK (ST_IsValid(geom) AND NOT ST_IsEmpty(geom))
);
CREATE INDEX regiao_turistica_geom_idx ON regiao_turistica USING GIST (geom);
CREATE TABLE ponto_turistico (
  id_ponto integer NOT NULL PRIMARY KEY,
  id_regiao integer NOT NULL REFERENCES regiao_turistica(id_regiao),
  nome varchar(80) NOT NULL UNIQUE,
  categoria varchar(20) NOT NULL CHECK (categoria IN ('museu','parque','mirante')),
  visitantes_dia integer NOT NULL CHECK (visitantes_dia >= 0),
  geom geometry(Point,4674) NOT NULL CHECK (ST_IsValid(geom) AND NOT ST_IsEmpty(geom))
);
CREATE INDEX ponto_turistico_geom_idx ON ponto_turistico USING GIST (geom);
CREATE INDEX ponto_turistico_regiao_idx ON ponto_turistico(id_regiao);
CREATE TABLE rota_turistica (
  id_rota integer NOT NULL PRIMARY KEY,
  id_regiao integer NOT NULL REFERENCES regiao_turistica(id_regiao),
  nome varchar(80) NOT NULL UNIQUE,
  modalidade varchar(20) NOT NULL CHECK (modalidade IN ('caminhada','bicicleta')),
  duracao_min integer NOT NULL CHECK (duracao_min > 0),
  geom geometry(LineString,4674) NOT NULL CHECK (ST_IsValid(geom) AND NOT ST_IsEmpty(geom))
);
CREATE INDEX rota_turistica_geom_idx ON rota_turistica USING GIST (geom);
CREATE INDEX rota_turistica_regiao_idx ON rota_turistica(id_regiao);
COMMIT;
