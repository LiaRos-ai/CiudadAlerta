# 42 · Informe 2 — App híbrida conectada a base de datos (Hito 2)

> Evidencia de aprendizaje significativo del **Hito 2 (Sprint 2)** según el
> plan de la asignatura: "creación y prueba práctica de la aplicación
> híbrida con conexión a base de datos (modelo ER, script SQL, consultas,
> APK)". Instrumento de evaluación: **Matriz 2 (20 pts)**. Se sustenta el
> Día 10 en 5 minutos por equipo con el APK instalado en el teléfono.

## Datos del trabajo

| Campo | Valor |
|---|---|
| Asignatura | Aplicaciones Móviles I (SIS-0180) · Ingeniería de Sistemas · 8.º semestre |
| Hito | 2 — Del día 6 al día 10 |
| Producto | CiudadAlerta v0.9.0+1 (tag `v0.9.0-dia10`) |
| Repo | Historial completo con 112 commits y 10 tags (`v0.0.0-sprint0` → `v0.9.0-dia10`) |
| Artefacto instalable | `app-release.apk` (~9 MB, minify + shrink, firma upload) |

## 1. Objetivo del hito

Desarrollar una aplicación híbrida conectada a una base de datos relacional,
realizar consultas y presentar/analizar los datos, y generar una
distribución estable para Android. La meta del sprint: autenticación, CRUD
y consultas contra PostgreSQL (Supabase), un recurso nativo (cámara) y el
APK release instalable (HU-12).

## 2. Modelo entidad-relación y decisiones (docs/27)

- 5 tablas: `profiles`, `categories`, `reports`, `comments`, `report_photos`.
- PK uuid; FK con ON DELETE CASCADE para comentarios y fotos.
- Normalización hasta 3FN: la categoría se separó de reports (evita
  inconsistencia de nombres) y el estado se modeló como texto acotado.
- Índices sobre `reports(categoria_id)`, `reports(creado_en desc)` y
  `report_photos(reporte_id)` para las consultas del Día 8.

## 3. Script SQL y datos semilla (Día 7, docs/28)

- `db/schema.sql`: DDL + constraints + índices + RLS base.
- `db/seed.sql`: 5 categorías / 4 perfiles / 8 reportes (RPT-001..008) /
  4 comentarios / 3 fotos, coherente con los datos mock de la app.
- `db/rls_dia9.sql`: refinamiento por usuario + bucket `fotos-reportes`.

## 4. CRUD y consultas desde la app (Día 8, docs/31-32)

- Repositorio único `supabase_reports_repository.dart`: ninguna pantalla
  importa el SDK; errores traducidos a mensajes en español.
- Lista con filtro por categoría y orden por fecha (HU-09), edición y
  eliminación con confirmación (HU-10), estadísticas con GROUP BY y
  BarChart (HU-13).
- Consultas con select anidado (`categories(*)`, `report_photos(url)`)
  equivalentes a los JOIN de `db/consultas.sql` (C01..C10).

## 5. Autenticación, autorización y seguridad (Día 9, docs/35-36)

- Supabase Auth email/contraseña; JWT del usuario en
  `flutter_secure_storage` (MASVS-STORAGE-1).
- RLS por usuario: `auth.uid() = usuario_id` (USING para filas existentes,
  WITH CHECK para nuevas); Storage acotado a la carpeta propia.
- Casos de prueba SP-01..SP-12 ejecutados con captura; la prueba cruzada
  entre equipos no logró editar filas ajenas (SP-07 falló, como debía).

## 6. Recurso nativo: foto con permisos (HU-11)

- `image_picker` + `permission_handler` con degradación elegante: negar la
  cámara no rompe el reporte (galería o reporte sin foto).
- Validación en Dart puro (formato, ≤5 MB) y subida tras el INSERT del
  reporte: si Storage falla, el reporte ya vive (docs/35, decisión 5).

## 7. Distribución Android (Día 10, docs/39) — HU-12

| Pieza | Valor entregado |
|---|---|
| Versión | `0.9.0+1` (versionName 0.9.0, versionCode 1) |
| Identidad | applicationId `com.ciudadalerta.app`, minSdk 23 |
| Ícono y splash | pin adaptativo + splash nativa con la marca |
| Firma | keystore de upload local; `key.properties` fuera del repo |
| Build | `flutter build apk --release` tras analyze + 59 pruebas verdes |
| Instalación | `adb install -r app-release.apk` en 3 teléfonos del equipo |

Capturas incluidas: ícono en el launcher, splash al abrir, versión en el
perfil y reporte creado desde el teléfono (sin cable).

## 8. Estado del sprint y evidencias

- HU-07..HU-13 **hechas** (31/31 puntos); acta del Review 2 en docs/40 y
  retrospectiva con compromisos en docs/41.
- Suite completa: **59 pruebas verdes** (`fvm flutter test`).
- Conocimiento pendiente planificado: APIs REST y Google Maps (Sprint 3).

## Anexos

1. Casos SP-01..SP-12 con capturas (Día 9).
2. Consultas C01..C10 ejecutadas con resultados (Día 7).
3. Salida de `scripts/build_release.sh` (analyze, test, build, sha256).
4. Historial Git: `git log --oneline v0.8.0-dia9..HEAD` (17 commits del Día 10).
