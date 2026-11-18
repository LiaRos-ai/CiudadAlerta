-- CiudadAlerta · Migración de ubicaciones (Día 12 · Sprint 3 · HU-14)
-- Ejecutar en el SQL Editor de Supabase ANTES de abrir la pestaña Mapa.
--
-- HU-14 pide "el mapa con marcadores de los reportes": un marcador
-- necesita coordenadas, y la tabla reports (Día 7) no las tenía. Esta
-- migración agrega dos columnas OPCIONALES (null = reporte sin ubicación)
-- y las llena para los 8 reportes del seed con coordenadas aproximadas
-- de su zona (Miraflores, San Pedro, Senkata, Calacoto...).
--
-- Regla del curso: una migración es IDEMPOTENTE (se puede ejecutar dos
-- veces sin romper nada) y NUNCA borra datos existentes.

-- 1) Columnas nuevas: double precision porque la API de Google devuelve
--    números decimales de doble precisión (latitud antes de longitud).
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS latitud  double precision,
  ADD COLUMN IF NOT EXISTS longitud double precision;

-- 2) Ubicaciones aproximadas de los 8 reportes del seed (Día 7).
--    El Día 13 (HU-15) las coordenadas REALES llegarán del GPS del
--    dispositivo con geolocator; hoy son datos sembrados a mano.
UPDATE public.reports SET latitud = -16.4993, longitud = -68.1190 WHERE codigo = 'RPT-001'; -- Miraflores, La Paz (bache Av. Buenos Aires)
UPDATE public.reports SET latitud = -16.5009, longitud = -68.1287 WHERE codigo = 'RPT-002'; -- San Pedro, La Paz (luminaria calle Illampu)
UPDATE public.reports SET latitud = -16.4876, longitud = -68.2075 WHERE codigo = 'RPT-003'; -- Senkata, El Alto (microbasural)
UPDATE public.reports SET latitud = -16.5397, longitud = -68.0927 WHERE codigo = 'RPT-004'; -- Calacoto, La Paz
UPDATE public.reports SET latitud = -16.4735, longitud = -68.1113 WHERE codigo = 'RPT-005'; -- Villa Fátima, La Paz
UPDATE public.reports SET latitud = -16.5003, longitud = -68.1526 WHERE codigo = 'RPT-006'; -- Ceja, El Alto
UPDATE public.reports SET latitud = -16.5035, longitud = -68.1341 WHERE codigo = 'RPT-007'; -- El Prado, La Paz
UPDATE public.reports SET latitud = -16.5129, longitud = -68.1257 WHERE codigo = 'RPT-008'; -- Sopocachi, La Paz

-- 3) Verificación del docente: 8 filas con coordenadas.
--    Resultado esperado: latitud y longitud NO nulas en las 8 filas.
SELECT codigo, titulo, zona, latitud, longitud
  FROM public.reports
 ORDER BY codigo;

-- Nota de seguridad: las políticas RLS del Día 9 (rls_dia9.sql) NO
-- cambian. Las columnas nuevas heredan las mismas políticas: lectura
-- pública para el mapa y edición solo del autor (auth.uid() =
-- usuario_id). Verifica con:
--   SELECT * FROM pg_policies WHERE tablename = 'reports';
