-- ============================================================================
-- CiudadAlerta - Dia 9 (Clase 9): SEGURIDAD DE DATOS
-- RLS por usuario + Storage (bucket fotos-reportes)
-- Sprint 2 (Hito 2) - Tema: "Autenticacion, seguridad de datos y recursos
-- nativos". Evidencia complementaria a docs/36-casos-prueba-seguridad.md
-- (la lista de cotejo del dia se llena ejecutando estos casos).
--
-- Como usar (SQL Editor de Supabase):
--   1. Ejecuta el script COMPLETO en el proyecto del Dia 7.
--   2. Los casos SP-04..SP-12 de docs/36 usan estas politicas.
--   3. Idempotente: puede re-ejecutarse (drop ... if exists al inicio).
--
-- Model mental de la clase (teoria del dia):
--   AUTENTICACION (Supabase Auth) = quien eres -> JWT -> auth.uid()
--   AUTORIZACION  (RLS + Storage policies) = que puedes tocar
--   La app envia el JWT en cada peticion; PostgreSQL lo valida ANTES de
--   tocar una sola fila. La clave anon sin JWT ve solo lo publico.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CREAR CUENTAS DE PRUEBA EN AUTH (para los casos SP-01..SP-06)
-- ----------------------------------------------------------------------------
-- Supabase Auth guarda las cuentas en la tabla PROTEGIDA auth.users (esquema
-- auth): NO se edita a mano. Desde el SQL Editor se pueden crear con
-- inv_user() del extension supabase_auth_admin, pero la via NORMAL del curso
-- es la app misma (pantalla "Crear cuenta" del Dia 9) o el panel
-- Authentication > Users > Add user. Cuentas sugeridas:
--
--   rosa.test@ciudadalerta.bo     / Clave2026   (ciudadana dueña de RPT-001)
--   carlos.test@ciudadalerta.bo   / Clave2026   (ciudadano dueño de RPT-002)
--   admin.test@ciudadalerta.bo    / Clave2026   (rol moderador, panel Hito 4)
--
-- Cada cuenta creada por la app tiene su auth.uid() propio. Para que el
-- PERFIL del ciudadano exista en profiles (y las FK funcionen), el trigger
-- handle_new_user crea la fila automaticamente; si tu proyecto del Dia 7 no
-- tiene el trigger, crealo aqui:

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nombre, rol, zona)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nombre', 'Ciudadano'),
    coalesce(new.raw_user_meta_data ->> 'rol', 'ciudadano'),
    'Zona sin registrar'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 2. RLS REFINADA DE REPORTS (reemplaza las politicas base del Dia 7)
-- ----------------------------------------------------------------------------
-- El Dia 7 quedo: "leer todos, escribir solo el dueno". HOY se hace explicito
-- y se completan las operaciones y las tablas hijas. Regla de oro: USING se
-- evalua para FILAS EXISTENTES (update/delete/select); WITH CHECK para las
-- NUEVAS (insert y la nueva version de un update).

drop policy if exists "lectura publica de reportes" on public.reports;
drop policy if exists "insertar solo mis reportes"  on public.reports;
drop policy if exists "editar solo mis reportes"    on public.reports;
drop policy if exists "borrar solo mis reportes"    on public.reports;

-- SP-03: sin sesion (clave anon) TAMBIEN se puede leer: la app publica
-- de las Clases 1-5 sigue funcionando de consultora.
create policy "lectura publica de reportes"
  on public.reports for select
  using (true);

-- SP-05: INSERT con otro usuario_id -> rechazado (42501/403).
-- auth.uid() es null sin JWT: null = cualquier_uuid es false -> denegado.
create policy "insertar solo mis reportes"
  on public.reports for insert
  with check (auth.uid() = usuario_id);

-- SP-06: UPDATE del reporte de OTRO -> 0 filas afectadas (using filtra).
create policy "editar solo mis reportes"
  on public.reports for update
  using (auth.uid() = usuario_id)
  with check (auth.uid() = usuario_id);

-- SP-07: DELETE del reporte de OTRO -> 0 filas afectadas.
create policy "borrar solo mis reportes"
  on public.reports for delete
  using (auth.uid() = usuario_id);

-- ----------------------------------------------------------------------------
-- 3. RLS DE COMMENTS (nuevo: cada quien escribe y borra SUS comentarios)
-- ----------------------------------------------------------------------------
drop policy if exists "lectura publica de comentarios" on public.comments;
drop policy if exists "comentar autenticado"           on public.comments;
drop policy if exists "borrar mis comentarios"         on public.comments;

create policy "lectura publica de comentarios"
  on public.comments for select using (true);

create policy "comentar autenticado"
  on public.comments for insert
  with check (auth.uid() = usuario_id);

create policy "borrar mis comentarios"
  on public.comments for delete
  using (auth.uid() = usuario_id);

-- ----------------------------------------------------------------------------
-- 4. RLS DE REPORT_PHOTOS (evidencia fotografica de HU-11)
-- ----------------------------------------------------------------------------
-- La foto es un INSERT en report_photos que referencia un reporte AJENO:
-- la subquery verifica la PROPIEDAD del reporte (no del archivo). Asi el
-- ciudadano no puede "colgar" fotos en reportes de otros (SP-10).
drop policy if exists "lectura publica de fotos"   on public.report_photos;
drop policy if exists "fotos de mis reportes"      on public.report_photos;
drop policy if exists "borrar fotos de mis reportes" on public.report_photos;

create policy "lectura publica de fotos"
  on public.report_photos for select using (true);

create policy "fotos de mis reportes"
  on public.report_photos for insert
  with check (
    exists (
      select 1 from public.reports r
      where r.id = reporte_id and r.usuario_id = auth.uid()
    )
  );

create policy "borrar fotos de mis reportes"
  on public.report_photos for delete
  using (
    exists (
      select 1 from public.reports r
      where r.id = reporte_id and r.usuario_id = auth.uid()
    )
  );

-- ----------------------------------------------------------------------------
-- 5. PROFILES: cada quien VE todos los perfiles publicos pero solo EDITA
--    el suyo (el nombre y zona aparecen junto a los reportes).
-- ----------------------------------------------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "perfiles publicos"     on public.profiles;
drop policy if exists "editar mi perfil"      on public.profiles;

create policy "perfiles publicos"
  on public.profiles for select using (true);

create policy "editar mi perfil"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- 6. STORAGE: bucket fotos-reportes (HU-11)
-- ----------------------------------------------------------------------------
-- Bucket PUBLICO de lectura (las miniaturas se muestran sin sesion) pero
-- con ESCRITURA acotada: cada cuenta solo escribe en SU carpeta
-- {usuarioId}/. La ruta la construye photo_storage.dart.
insert into storage.buckets (id, name, public)
values ('fotos-reportes', 'fotos-reportes', true)
on conflict (id) do update set public = true;

-- Lectura publica de las fotos (igual que report_photos en SQL)
drop policy if exists "lectura publica de fotos de reportes" on storage.objects;
create policy "lectura publica de fotos de reportes"
  on storage.objects for select
  using (bucket_id = 'fotos-reportes');

-- Subida SOLO a la carpeta propia: (storage.foldername(name))[1] es el
-- primer "directorio" del objeto; debe coincidir con auth.uid(). (SP-09)
drop policy if exists "subir solo a mi carpeta" on storage.objects;
create policy "subir solo a mi carpeta"
  on storage.objects for insert
  with check (
    bucket_id = 'fotos-reportes'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Reemplazo (upsert:true al reintentar) y borrado de la propia carpeta
drop policy if exists "reemplazar fotos en mi carpeta" on storage.objects;
create policy "reemplazar fotos en mi carpeta"
  on storage.objects for update
  using (
    bucket_id = 'fotos-reportes'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "borrar fotos de mi carpeta" on storage.objects;
create policy "borrar fotos de mi carpeta"
  on storage.objects for delete
  using (
    bucket_id = 'fotos-reportes'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ----------------------------------------------------------------------------
-- 7. VERIFICACION DEL DIA (casos de prueba de seguridad en vivo)
-- ----------------------------------------------------------------------------
-- Los siguientes pasos son la version "laboratorio" de docs/36: se ejecutan
-- impersonando usuarios con la clave anon + login, desde la app o con el
-- SQL Editor (opcion "Run as authenticated user" con un JWT real).

-- SP-05 (simulado): INSERT con uid ajeno -> DEBE fallar con RLS error
-- (en SQL Editor: set request.jwt.claims con el JWT de carlos.test)
-- insert into reports (codigo, titulo, categoria_id, usuario_id, descripcion, zona)
-- values ('RPT-X99', 'Prueba de RLS ajena', 1,
--         '11111111-1111-1111-1111-111111111101', 'No soy Rosa', 'Miraflores');
-- EXPECTED: ERROR new row violates row-level security policy (SP-05 OK)

-- SP-11 (consultas de auditoria): quien puede ver que
select codigo, titulo, usuario_id,
       (usuario_id = auth.uid()) as es_mio
from reports
order by creado_en desc;

-- SP-12: inventario final de politicas (evidencia para el Informe 2)
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public' or tablename like 'objects%'
order by tablename, policyname;
