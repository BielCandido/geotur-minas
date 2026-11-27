SET client_encoding = 'UTF8';
SELECT version(), postgis_full_version();
SELECT 'regiao_turistica' AS tabela, count(*) AS registros FROM regiao_turistica
UNION ALL SELECT 'ponto_turistico', count(*) FROM ponto_turistico
UNION ALL SELECT 'rota_turistica', count(*) FROM rota_turistica;
DO $$ BEGIN
IF (SELECT count(*) FROM regiao_turistica) <> 50 OR EXISTS (SELECT 1 FROM regiao_turistica WHERE geom IS NULL OR ST_IsEmpty(geom) OR NOT ST_IsValid(geom) OR ST_SRID(geom)<>4674) THEN RAISE EXCEPTION 'Falha: regiao_turistica'; END IF;
IF (SELECT count(*) FROM ponto_turistico) <> 500 OR EXISTS (SELECT 1 FROM ponto_turistico WHERE geom IS NULL OR ST_IsEmpty(geom) OR NOT ST_IsValid(geom) OR ST_SRID(geom)<>4674) THEN RAISE EXCEPTION 'Falha: ponto_turistico'; END IF;
IF (SELECT count(*) FROM rota_turistica) <> 100 OR EXISTS (SELECT 1 FROM rota_turistica WHERE geom IS NULL OR ST_IsEmpty(geom) OR NOT ST_IsValid(geom) OR ST_SRID(geom)<>4674) THEN RAISE EXCEPTION 'Falha: rota_turistica'; END IF;
IF EXISTS (SELECT 1 FROM ponto_turistico p JOIN regiao_turistica r USING(id_regiao) WHERE NOT ST_Within(p.geom,r.geom)) THEN RAISE EXCEPTION 'Fora da região: ponto_turistico'; END IF;
IF EXISTS (SELECT 1 FROM rota_turistica p JOIN regiao_turistica r USING(id_regiao) WHERE NOT ST_Within(p.geom,r.geom)) THEN RAISE EXCEPTION 'Fora da região: rota_turistica'; END IF;
IF EXISTS (SELECT 1 FROM regiao_turistica r WHERE (SELECT count(*) FROM ponto_turistico p WHERE p.id_regiao=r.id_regiao)<>10 OR (SELECT count(*) FROM rota_turistica t WHERE t.id_regiao=r.id_regiao)<>2) THEN RAISE EXCEPTION 'Falha: cardinalidade por região'; END IF;
IF EXISTS (SELECT 1 FROM regiao_turistica WHERE abs(area_km2 - ST_Area(ST_Transform(geom,31983))/1e6) > 0.001) THEN RAISE EXCEPTION 'Falha: area_km2 diverge da geometria'; END IF;
IF EXISTS (SELECT 1 FROM rota_turistica WHERE ST_NPoints(geom)<>5) THEN RAISE EXCEPTION 'Falha: rota sem 5 vértices'; END IF;
RAISE NOTICE '650 feições: validação aprovada';
END $$;
