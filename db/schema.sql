-- ============================================================
-- CiudadAlerta - Esquema SQL de Supabase (PostgreSQL)
-- Clase 7 / Dia 7 del curso Aplicaciones Moviles I (SIS-0180)
-- Evidencia oficial del dia: ESQUEMA ER + SCRIPT SQL (lista de cotejo)
--
-- 5 tablas del Proyecto Guia:
--   profiles       -> usuarios de la app (extiende auth.users de Supabase)
--   categories     -> catalogo cerrado de categorias (Via, Luminaria, ...)
--   reports        -> reportes ciudadanos (HU-03, HU-09, HU-10)
--   comments       -> comentarios de seguimiento (1:N con reports)
--   report_photos  -> fotos en Storage (1:N con reports, HU-11)
--
-- Orden de ejecucion en el SQL Editor de Supabase:
--   1) este archivo (db/schema.sql)  2) db/seed.sql  3) db/consultas.sql
-- ============================================================

-- Extension necesaria para los UUID automaticos (gen_random_uuid())
create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- 1) PROFILES - el usuario ciudadano de La Paz o El Alto
--    id referencia a auth.users: Supabase Auth crea el usuario
--    y esta tabla guarda los datos de perfil (relacion 1:1).
-- ------------------------------------------------------------
create table profiles (
  id              uuid primary key references auth.users (id) on delete cascade,
  nombre_completo text not null,
  -- ciudadano | moderador | autoridad (el Hito 4 usa el rol moderador)
  rol             text not null default 'ciudadano'
                    check (rol in ('ciudadano', 'moderador', 'autoridad')),
  zona            text,                -- zona habitual, ej. 'Miraflores, La Paz'
  creado_en       timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2) CATEGORIES - catalogo cerrado (5 filas del curso)
--    Se modela como TABLA (no como texto libre en reports) para
--    poder renombrar, desactivar y hacer JOIN/GROUP BY rapido.
-- ------------------------------------------------------------
create table categories (
  id          smallint primary key,    -- 1..5 estables (el seed los fija)
  nombre      text not null unique,    -- Via | Luminaria | Residuos | Riesgo | Agua
  descripcion text,
  activa      boolean not null default true
);

-- ------------------------------------------------------------
-- 3) REPORTS - la entidad central del Proyecto Guia
--    codigo = RPT-001..RPT-008 (el id legible que la app muestra)
--    categoria_id y usuario_id son las FK del modelo ER (docs/27)
-- ------------------------------------------------------------
create table reports (
  id             uuid primary key default gen_random_uuid(),
  codigo         text not null unique,           -- RPT-001 (id legible de la app)
  titulo         text not null check (char_length(titulo) between 5 and 120),
  categoria_id   smallint not null references categories (id),
  usuario_id     uuid not null references profiles (id) on delete cascade,
  descripcion    text not null,
  -- Recibido | En revision | En proceso | Resuelto (mismos estados de la app)
  estado         text not null default 'Recibido'
                   check (estado in ('Recibido', 'En revision', 'En proceso', 'Resuelto')),
  zona           text not null,                  -- 'Senkata, El Alto'
  urgente        boolean not null default false,
  -- fecha del mock (texto) se reemplaza por timestamptz: permite ORDER BY real
  creado_en      timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4) COMMENTS - seguimiento ciudadano de cada reporte
--    on delete cascade: si se elimina el reporte, sus comentarios
--    desaparecen con el (nadie comenta sobre un reporte inexistente).
-- ------------------------------------------------------------
create table comments (
  id         uuid primary key default gen_random_uuid(),
  reporte_id uuid not null references reports (id) on delete cascade,
  usuario_id uuid references profiles (id) on delete set null,
  cuerpo     text not null check (char_length(cuerpo) between 1 and 500),
  creado_en  timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 5) REPORT_PHOTOS - evidencia fotografica (HU-11, Dia 9)
--    url = ruta del objeto en Supabase Storage (bucket 'report-fotos').
-- ------------------------------------------------------------
create table report_photos (
  id          uuid primary key default gen_random_uuid(),
  reporte_id  uuid not null references reports (id) on delete cascade,
  url         text not null,
  es_principal boolean not null default false,   -- miniatura de la tarjeta
  creado_en   timestamptz not null default now()
);

-- ------------------------------------------------------------
-- INDICES: toda FK y toda columna de filtro u orden del curso
-- (HU-09 filtra por categoria/estado y ordena por fecha)
-- ------------------------------------------------------------
create index idx_reports_categoria   on reports (categoria_id);
create index idx_reports_estado      on reports (estado);
create index idx_reports_creado_en   on reports (creado_en desc);
create index idx_reports_zona        on reports (zona);
create index idx_comments_reporte    on comments (reporte_id);
create index idx_photos_reporte      on report_photos (reporte_id);

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY (RLS) - introduccion del Dia 7
-- Dia 9 (HU-08) se refinan con Supabase Auth; aqui queda habilitada
-- y la politica base: leer todos, escribir solo el dueno.
-- ------------------------------------------------------------
alter table profiles       enable row level security;
alter table categories     enable row level security;
alter table reports        enable row level security;
alter table comments       enable row level security;
alter table report_photos  enable row level security;

-- Cualquiera puede consultar (la app publica de las Clases 1-5 era abierta)
create policy "lectura publica de reportes"   on reports       for select using (true);
create policy "lectura publica de categorias" on categories    for select using (true);
create policy "lectura publica de comentarios" on comments     for select using (true);
create policy "lectura publica de fotos"      on report_photos for select using (true);

-- Escribir solo el dueno: auth.uid() lo aporta Supabase Auth (Dia 9)
create policy "insertar solo mis reportes" on reports
  for insert with check (auth.uid() = usuario_id);
create policy "editar solo mis reportes"   on reports
  for update using (auth.uid() = usuario_id);
create policy "borrar solo mis reportes"   on reports
  for delete using (auth.uid() = usuario_id);
