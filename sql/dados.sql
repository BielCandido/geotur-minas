-- Garante a leitura correta dos acentos (o psql no Windows pode usar WIN1252 por padrão).
SET client_encoding = 'UTF8';
BEGIN;
-- Grade artificial de 10 colunas por 5 linhas, na área de referência central de MG.
-- area_km2 é calculada da própria geometria em SIRGAS 2000 / UTM 23S (31983).
INSERT INTO regiao_turistica (id_regiao,nome,perfil,capacidade,area_km2,ano_criacao,geom)
SELECT i, 'Região ' || lpad(i::text,2,'0'), CASE WHEN i%2=1 THEN 'cultural' ELSE 'natureza' END, 100*i,
 round((ST_Area(ST_Transform(e,31983))/1e6)::numeric,3), 2000+(i%25), e
FROM (SELECT i, ST_MakeEnvelope(-44.0+((i-1)%10)*0.02, -20.0+((i-1)/10)*0.02,
                                -44.0+((i-1)%10)*0.02+0.02, -20.0+((i-1)/10)*0.02+0.02, 4674) AS e
      FROM generate_series(1,50) i) g;
INSERT INTO ponto_turistico
SELECT (r.id_regiao-1)*10+j,r.id_regiao,'Atração '||lpad(((r.id_regiao-1)*10+j)::text,3,'0'),
 (ARRAY['museu','parque','mirante'])[(j-1)%3+1],20*j,
 ST_SetSRID(ST_MakePoint(ST_XMin(r.geom)+0.003+((j-1)%5)*0.003,ST_YMin(r.geom)+0.005+((j-1)/5)*0.009),4674)
FROM regiao_turistica r CROSS JOIN generate_series(1,10) j;
INSERT INTO rota_turistica
SELECT (r.id_regiao-1)*2+j,r.id_regiao,'Rota '||lpad(((r.id_regiao-1)*2+j)::text,3,'0'),
 CASE WHEN j=1 THEN 'caminhada' ELSE 'bicicleta' END,30*j,
 ST_MakeLine(p.geom ORDER BY p.id_ponto)
FROM regiao_turistica r CROSS JOIN generate_series(1,2) j JOIN ponto_turistico p ON p.id_regiao=r.id_regiao AND ((p.id_ponto-1)%10)/5=j-1
GROUP BY r.id_regiao,j;
COMMIT;
