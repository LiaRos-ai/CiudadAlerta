-- ============================================================
-- CiudadAlerta - Datos semilla (seed.sql)
-- Clase 7 / Dia 7 - Aplicaciones Moviles I (SIS-0180)
--
-- Los datos REPLICAN los 8 reportes mock de la app
-- (app/lib/data/mock_reports.dart, RPT-001..RPT-008): la app y la
-- BD deben hablar el mismo idioma desde hoy (contrato de datos).
--
-- Ejecutar DESPUES de db/schema.sql en el SQL Editor de Supabase.
-- ============================================================

-- ------------------------------------------------------------
-- 1) CATEGORIAS: las 5 constantes de categoriasCiudadAlerta
--    (id smallint estables para poder referenciarlas en el seed)
-- ------------------------------------------------------------
insert into categories (id, nombre, descripcion) values
  (1, 'Via',       'Baches, tapas rotas, senaletica y danos en calzada'),
  (2, 'Luminaria', 'Alumbrado publico apagado o intermitente'),
  (3, 'Residuos',  'Basura acumulada, microbasurales y contenedores llenos'),
  (4, 'Riesgo',    'Peligros inminentes: cables caidos, excavaciones sin senalizar'),
  (5, 'Agua',      'Fugas de agua potable y desagues');

-- ------------------------------------------------------------
-- 2) PROFILES: 4 usuarios del equipo de pruebas
--    (en la app real se crean via Supabase Auth; aqui se insertan
--    directo para poder probar consultas en el Dia 7)
-- ------------------------------------------------------------
insert into profiles (id, nombre_completo, rol, zona) values
  ('11111111-1111-1111-1111-111111111101', 'Rosa Quispe',  'ciudadano',  'Miraflores, La Paz'),
  ('11111111-1111-1111-1111-111111111102', 'Carlos Mamani','ciudadano',  'Senkata, El Alto'),
  ('11111111-1111-1111-1111-111111111103', 'Marcelo Torrez','ciudadano', 'Calacoto, La Paz'),
  ('11111111-1111-1111-1111-111111111104', 'Ana Flores',   'moderador',  'Cotahuma, La Paz');

-- ------------------------------------------------------------
-- 3) REPORTS: los 8 reportes del mock, mismo codigo/zona/estado
--    (usuario_id reparte: Rosa 3, Carlos 3, Marcelo 2)
-- ------------------------------------------------------------
insert into reports (codigo, titulo, categoria_id, usuario_id, descripcion, estado, zona, urgente, creado_en) values
  ('RPT-001',
   'Bache profundo en la Av. Buenos Aires', 1,
   '11111111-1111-1111-1111-111111111101',
   'Bache de aproximadamente 1 metro en el carril derecho, a la altura del paradero de minibus. Ya provoco dos llantas ponchadas esta semana.',
   'Recibido', 'Miraflores, La Paz', true,  timestamptz '2026-11-03 08:15:00-04'),
  ('RPT-002',
   'Luminaria apagada en la calle Illampu', 2,
   '11111111-1111-1111-1111-111111111101',
   'Tres postes seguidos sin luz frente al colegio. La cuadra queda completamente oscura despues de las 19:00 y es la ruta de vuelta de los estudiantes.',
   'En revision', 'San Pedro, La Paz', false, timestamptz '2026-11-02 19:40:00-04'),
  ('RPT-003',
   'Microbasural junto al rio de El Alto', 3,
   '11111111-1111-1111-1111-111111111102',
   'Escombros y bolsas de basura acumulados desde hace dos semanas en el borde de la quebrada. Con la lluvia el material baja hacia el rio.',
   'En proceso', 'Senkata, El Alto', true,  timestamptz '2026-11-01 10:05:00-04'),
  ('RPT-004',
   'Cable de luz caido en la zona Sur', 4,
   '11111111-1111-1111-1111-111111111103',
   'Cable de media tension colgando a un metro del suelo despues del viento fuerte. Los vecinos pasan por al lado con los ninos.',
   'En proceso', 'Calacoto, La Paz', true,  timestamptz '2026-10-31 14:30:00-04'),
  ('RPT-005',
   'Fuga de agua en la esquina de la plaza', 5,
   '11111111-1111-1111-1111-111111111101',
   'Perdida de agua potable que corre por la acera desde el sabado. Se desperdicia el agua y el piso resbala para los peatones.',
   'Recibido', 'Villa Fatima, La Paz', false, timestamptz '2026-10-30 07:50:00-04'),
  ('RPT-006',
   'Sardinera desbordada en la ceja de El Alto', 3,
   '11111111-1111-1111-1111-111111111102',
   'El contenedor esta lleno y los desechos quedan en la vereda. Aparecen perros y moscas toda la manana.',
   'Resuelto', 'Ceja, El Alto', false, timestamptz '2026-10-29 09:20:00-04'),
  ('RPT-007',
   'Tapa de alcantarilla rota en la Av. 16 de Julio', 1,
   '11111111-1111-1111-1111-111111111102',
   'La tapa se hundio y queda un hueco abierto en el carril del bici. Peligroso para ciclistas al anochecer.',
   'En revision', 'El Prado, La Paz', false, timestamptz '2026-10-28 18:10:00-04'),
  ('RPT-008',
   'Semaforo apagado en la interseccion de la Ballivian', 2,
   '11111111-1111-1111-1111-111111111103',
   'El semaforo principal esta sin senal desde el lunes; los vehiculos pasan sin ceder el paso a los peatones.',
   'Recibido', 'Sopocachi, La Paz', false, timestamptz '2026-10-27 12:00:00-04');

-- ------------------------------------------------------------
-- 4) COMMENTS: seguimiento de algunos reportes
-- ------------------------------------------------------------
insert into comments (reporte_id, usuario_id, cuerpo, creado_en)
select r.id, p.id, c.cuerpo, c.cuando
from (values
  ('RPT-001', '11111111-1111-1111-1111-111111111104', 'Tarea enviada a la unidad de mantenimiento vial. Folio 2026-0891.', '2026-11-03 11:00:00-04'),
  ('RPT-003', '11111111-1111-1111-1111-111111111104', 'Un camion retiro la mitad del escombro; falta completar la limpieza.', '2026-11-02 16:30:00-04'),
  ('RPT-004', '11111111-1111-1111-1111-111111111102', 'Confirmo: pasa por encima de la acera de mi casa, mucho cuidado.', '2026-10-31 15:00:00-04'),
  ('RPT-006', '11111111-1111-1111-1111-111111111104', 'Contenedor vaciado y pintado. Problema resuelto, gracias por reportar.', '2026-10-29 17:45:00-04')
) as c(codigo, uid, cuerpo, cuando)
join reports r on r.codigo = c.codigo
join profiles p on p.id = c.uid;

-- ------------------------------------------------------------
-- 5) REPORT_PHOTOS: 3 fotos de ejemplo (rutas reales llegan con HU-11, Dia 9)
-- ------------------------------------------------------------
insert into report_photos (reporte_id, url, es_principal)
select r.id, f.url, f.principal
from (values
  ('RPT-001', 'report-fotos/rpt-001/bache_buenos_aires.jpg', true),
  ('RPT-003', 'report-fotos/rpt-003/microbasural_senkata.jpg', true),
  ('RPT-004', 'report-fotos/rpt-004/cable_calacoto.jpg', true)
) as f(codigo, url, principal)
join reports r on r.codigo = f.codigo;

-- Verificacion rapida (debe devolver 5/4/8/4/3):
select 'categories' as tabla, count(*) from categories
union all select 'profiles',    count(*) from profiles
union all select 'reports',     count(*) from reports
union all select 'comments',    count(*) from comments
union all select 'report_photos', count(*) from report_photos;
