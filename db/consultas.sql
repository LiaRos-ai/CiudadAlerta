-- ============================================================
-- CiudadAlerta - Consultas SQL de practica (consultas.sql)
-- Clase 7 / Dia 7 - Aplicaciones Moviles I (SIS-0180)
--
-- 10 consultas que preparan el Dia 8 (HU-09 filtros/orden,
-- HU-13 estadisticas). Ejecutar cada bloque en el SQL Editor
-- de Supabase DESPUES de schema.sql + seed.sql.
--   C01-C03: SELECT con filtros y orden (WHERE / ORDER BY / LIMIT)
--   C04-C05: JOIN entre tablas
--   C06-C09: GROUP BY y agregados (COUNT / HAVING)
--   C10:     ventanas de tiempo con INTERVAL
-- ============================================================

-- C01 · Reportes en estado 'Recibido' (lo que el moderador atiende primero)
select codigo, titulo, estado, zona, urgente
from reports
where estado = 'Recibido'
order by creado_en desc;

-- C02 · HU-09: lista con filtro por categoria y orden por fecha
--       (la consulta EXACTA que la app ejecutara el Dia 8)
select r.codigo, r.titulo, c.nombre as categoria, r.creado_en
from reports r
join categories c on c.id = r.categoria_id
where c.nombre = 'Residuos'
order by r.creado_en desc;

-- C03 · Reportes urgentes de El Alto (filtro combinado AND / LIKE)
select codigo, titulo, zona, estado
from reports
where urgente = true and zona ilike '%El Alto%';

-- C04 · INNER JOIN: titulo + nombre de categoria + nombre del autor
--       (3 tablas: reports -> categories y reports -> profiles)
select r.codigo, r.titulo, c.nombre as categoria,
       p.nombre_completo as reportado_por, r.estado
from reports r
join categories c on c.id = r.categoria_id
join profiles p   on p.id = r.usuario_id
order by r.creado_en desc;

-- C05 · LEFT JOIN: reportes con/sin comentarios
--       (LEFT conserva los reportes que nadie ha comentado)
select r.codigo, r.titulo, count(cm.id) as n_comentarios
from reports r
left join comments cm on cm.reporte_id = r.id
group by r.codigo, r.titulo
order by n_comentarios desc, r.codigo;

-- C06 · HU-13: estadisticas por categoria (GROUP BY + COUNT)
--       (los numeros que pintara el grafico fl_chart del Dia 8)
select c.nombre as categoria, count(r.id) as total_reportes
from categories c
left join reports r on r.categoria_id = c.id
group by c.nombre
order by total_reportes desc;

-- C07 · Estadisticas por estado (el embudo Recibido -> Resuelto)
select estado, count(*) as total
from reports
group by estado
order by total desc;

-- C08 · Zonas con 2 o mas reportes (GROUP BY + HAVING)
select zona, count(*) as total
from reports
group by zona
having count(*) >= 2
order by total desc;

-- C09 · Fotos por reporte (LEFT JOIN a la tabla puente de HU-11)
select r.codigo, r.titulo, count(f.id) as n_fotos
from reports r
left join report_photos f on f.reporte_id = r.id
group by r.codigo, r.titulo
order by n_fotos desc;

-- C10 · Reportes de la ultima semana (INTERVAL de PostgreSQL)
select codigo, titulo, creado_en
from reports
where creado_en >= now() - interval '7 days'
order by creado_en desc;
