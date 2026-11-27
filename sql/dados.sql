-- Garante a leitura correta dos acentos (o psql no Windows pode usar WIN1252 por padrão).
SET client_encoding = 'UTF8';
BEGIN;
-- Grade artificial de 10 colunas por 5 linhas, na área de referência central de MG.
INSERT INTO regiao_turistica
SELECT i, 'Região ' || lpad(i::text,2,'0'), CASE WHEN i%2=1 THEN 'cultural' ELSE 'natureza' END, 100*i,
 ST_MakeEnvelope(x,y,x+0.02,y+0.02,4674)
FROM (SELECT i, -44.0+((i-1)%10)*0.02 AS x, -20.0+((i-1)/10)*0.02 AS y FROM generate_series(1,50) i) g;
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
