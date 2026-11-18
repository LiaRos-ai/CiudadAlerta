# 53 · Avance Git del Día 12 — CiudadAlerta (Sprint 3)

> Registro de los **17 commits** del Día 12 ("APIs de Google: Maps
> Platform, claves y configuración"). Un commit por pieza: cada uno
> compila por separado y cuenta una historia revisable en el PR. La
> guía de convenciones vive en `docs/07-convenciones-git.md`.

## Estado de partida

- Tag del día anterior: `v1.0.0-dia11` (primera API externa: clima
  Open-Meteo con deterioro elegante; 65 pruebas verdes).
- Faltaba el primer entregable visible del Hito 3: la pestaña Mapa
  seguía siendo el placeholder del Día 4 y ningún reporte tenía
  coordenadas.
- Entra al sprint: la migración de ubicaciones, el SDK de Google Maps
  con la clave inyectada por build y la ventana emergente al detalle.

## Historia del día (17 commits)

| # | Commit | Qué contiene |
|---|---|---|
| 1 | `chore: dependencia google_maps_flutter para HU-14` | `app/pubspec.yaml` (google_maps_flutter ^2.10.0) |
| 2 | `feat: coordenadas opcionales en Report (latitud/longitud)` | `app/lib/data/report.dart` (patrón fotoUrl del Día 9; contrato Día 7 intacto) |
| 3 | `feat: mapeo de la fila Supabase con latitud y longitud` | `app/lib/data/supabase_reports_repository.dart` (cast tolerante `as num?`) |
| 4 | `feat: coordenadas reales de La Paz y El Alto en el mock` | `app/lib/data/mock_reports.dart` (8 reportes con ubicación) |
| 5 | `feat: migración SQL de ubicaciones para Supabase` | `db/ubicaciones_dia12.sql` (ALTER + 8 UPDATE + verificación; idempotente) |
| 6 | `feat: constructor de marcadores desde reportes (lógica pura)` | `app/lib/data/mapa/marcadores.dart` (marcadoresDe + coordenadasDe + sedeLaPaz) |
| 7 | `feat: MapaScreen con GoogleMap y ventana emergente al detalle (HU-14)` | `app/lib/screens/mapa_screen.dart` (ConsumerWidget + reportesProvider + InfoWindow.onTap → `/reporte/:id`) |
| 8 | `feat: la pestaña Mapa abre el mapa real` | `app/lib/routing/app_router.dart` + retiro de `map_placeholder_screen.dart` |
| 9 | `feat: clave de Maps llega al manifest por --dart-define` | `android/app/src/main/AndroidManifest.xml` (placeholder `${mapsApiKey}`) |
| 10 | `feat: Gradle decodifica dart-defines y llena el placeholder` | `android/app/build.gradle` (manifestPlaceholders; cero claves versionadas) |
| 11 | `chore: versión 1.1.0+3 para el primer mapa` | `app/pubspec.yaml` (versionName 1.1.0, versionCode 3: nunca se reusa) |
| 12 | `test: mapa y coordenadas (71 pruebas verdes)` | `app/test/mapa_test.dart` (6 pruebas: modelo 2, marcadores 3, panel sin clave 1) |
| 13 | `docs: guía de la consola Google Cloud y restricciones (docs/51)` | `docs/51-consola-google-cloud.md` (evidencia oficial: claves restringidas) |
| 14 | `docs: guía técnica del mapa en Flutter (docs/52)` | `docs/52-mapa-google-flutter.md` |
| 15 | `docs: avance git del día 12 (docs/53)` | este archivo |
| 16 | `docs: bitácora del día 12 con la revisión de claves (docs/54)` | `docs/54-bitacora-dia12.md` |
| 17 | `docs: READMEs actualizados con el mapa` | `README.md` + `app/README.md` |

## Verificación del cierre (checklist del día)

- Tag `v1.1.0-dia12` anotado y empujado al remoto.
- `git log --oneline v1.0.0-dia11..HEAD` muestra los 17 commits en
  orden: dependencia → modelo → repositorio → datos → SQL → lógica →
  UI → navegación → configuración Android → versión → tests → docs.
- `git log -p | grep -c AIza` devuelve 0: ninguna clave en el historial.
- `fvm flutter test` en verde: 71 pruebas (contrato 3, alfa 3,
  borradores 5, formulario 3, widgets 3, CRUD, auth 12, foto 9,
  release, clima 6, stats 2, mapa 6...).
- La migración `db/ubicaciones_dia12.sql` ejecutada en el proyecto de
  Supabase del aula; verificación con las 8 filas con coordenadas.
- La clave del aula quedó restringida (paquete + SHA-1 debug, solo
  Maps SDK for Android) y el consumo visible en el panel de la consola.

## Por qué el orden de los commits importa

Los primeros 5 commits preparan los DATOS (modelo, repositorio, mock,
BD) y compilan sin el SDK; el 6 agrega la lógica pura con la
dependencia nueva; el 7-9 solo después toca la UI y la navegación; el
10-11 configura la plataforma y el 12 congela la versión. Si un commit
rompe el build, el bisect del día sabe exactamente dónde empezó el
problema: es el mismo criterio de "cada commit compila" del Día 3.
