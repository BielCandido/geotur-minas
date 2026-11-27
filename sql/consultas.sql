-- Atrações por região
SELECT r.nome,count(p.id_ponto) FROM regiao_turistica r JOIN ponto_turistico p USING(id_regiao) GROUP BY r.id_regiao,r.nome ORDER BY r.id_regiao;
-- Comprimento em metros (SIRGAS 2000 / UTM 23S)
SELECT nome,round(ST_Length(ST_Transform(geom,31983))::numeric,2) AS metros FROM rota_turistica;
-- Atrações a até 500 metros da primeira atração
SELECT p.nome FROM ponto_turistico p JOIN ponto_turistico a ON a.id_ponto=1 AND p.id_ponto<>a.id_ponto WHERE ST_DWithin(ST_Transform(p.geom,31983),ST_Transform(a.geom,31983),500);
-- Rotas que intersectam regiões
SELECT t.nome,r.nome FROM rota_turistica t JOIN regiao_turistica r ON ST_Intersects(t.geom,r.geom);
-- Região de cada atração pela relação espacial (deve coincidir com a FK)
SELECT p.nome,r.nome AS regiao_espacial,p.id_regiao=r.id_regiao AS confere FROM ponto_turistico p JOIN regiao_turistica r ON ST_Within(p.geom,r.geom) ORDER BY p.id_ponto LIMIT 20;
-- Área de cada região em km² (UTM 23S)
SELECT nome,round((ST_Area(ST_Transform(geom,31983))/1e6)::numeric,3) AS area_km2 FROM regiao_turistica ORDER BY id_regiao;
-- Visitação total por perfil de região
SELECT r.perfil,sum(p.visitantes_dia) AS visitantes FROM regiao_turistica r JOIN ponto_turistico p USING(id_regiao) GROUP BY r.perfil;
