# 57 · Avance Git del Día 13 — CiudadAlerta (Sprint 3)

> Registro de los **17 commits** del Día 13 ("Geolocalización,
> Geocoding y rutas"). Un commit por pieza: cada uno compila por
> separado y cuenta una historia revisable en el PR. La guía de
> convenciones vive en `docs/07-convenciones-git.md`.

## Estado de partida

- Tag del día anterior: `v1.1.0-dia12` (mapa real de los reportes con
  marcadores e InfoWindow; 71 pruebas verdes).
- El mapa era una foto estática: sin punto azul, coordenadas sembradas
  y zona de los reportes nuevos como texto de relleno.
- Entra al sprint: el GPS (permisos y lectura puntual), el geocoding
  con caché y la ruta costo cero hacia el reporte.

## Historia del día (17 commits)

| # | Commit | Qué contiene |
|---|---|---|
| 1 | `chore: dependencias geolocator, geocoding y url_launcher (HU-15/HU-20)` | `app/pubspec.yaml` (geolocator ^13.0.1, geocoding ^3.0.0, url_launcher ^6.3.0) |
| 2 | `feat: permisos de ubicación ACCESS_FINE/COARSE en el manifest` | `android/app/src/main/AndroidManifest.xml` (sin "always": minimización) |
| 3 | `feat: servicio de ubicación con geolocator y lógica pura de distancia` | `app/lib/data/ubicacion/ubicacion_service.dart` (permiso en contexto, lectura puntual, distanciaA, mensajes) |
| 4 | `fix: el select de Supabase pide latitud y longitud (marcadores contra la BD)` | `app/lib/data/supabase_reports_repository.dart` (obtenerReportes + buscarPorId; incidencia estrella del día) |
| 5 | `feat: mapa vivo con punto azul y botón Mi ubicación (HU-15)` | `app/lib/screens/mapa_screen.dart` (ConsumerStatefulWidget, FAB, myLocationEnabled como estado) |
| 6 | `feat: geocoding inverso con caché y contador de llamadas` | `app/lib/data/ubicacion/geocoding_service.dart` (clave a 5 decimales, resolver inyectable) |
| 7 | `feat: el formulario captura la ubicación y la dirección legible (HU-15)` | `app/lib/screens/new_report_screen.dart` ("Usar mi ubicación" + zona real) |
| 8 | `feat: crearReporte acepta latitud/longitud en interfaz y mock` | `reports_repository.dart` (interfaz + mock con coords; la reconstrucción del mock preserva fotoUrl y coordenadas) |
| 9 | `feat: el INSERT de Supabase guarda latitud y longitud` | `supabase_reports_repository.dart` (parámetros opcionales; claves solo si la fila las tiene) |
| 10 | `feat: dirección legible en el detalle y ruta Cómo llegar (HU-15/HU-20)` | `app/lib/data/ubicacion/ruta.dart` + `report_detail_screen.dart` (FutureBuilder + url_launcher) |
| 11 | `chore: versión 1.2.0+4 para el mapa vivo` | `app/pubspec.yaml` (versionName 1.2.0, versionCode 4: nunca se reusa) |
| 12 | `test: ubicación, geocoding y rutas (77 pruebas verdes)` | `app/test/ubicacion_test.dart` (6 pruebas: distancia 2, dirección 2, ruta 2) |
| 13 | `docs: guía de permisos y ubicación (docs/55)` | `docs/55-permisos-y-ubicacion.md` (manifest, runtime, privacidad) |
| 14 | `docs: guía de geocoding y rutas (docs/56)` | `docs/56-geocoding-y-rutas.md` (caché, costos, ruta costo cero) |
| 15 | `docs: avance git del día 13 (docs/57)` | este archivo |
| 16 | `docs: bitácora del día 13 con la demo en dispositivo (docs/58)` | `docs/58-bitacora-dia13.md` |
| 17 | `docs: READMEs actualizados con la ubicación` | `README.md` + `app/README.md` |

## Verificación del cierre (checklist del día)

- Tag `v1.2.0-dia13` anotado y empujado al remoto.
- `git log --oneline v1.1.0-dia12..HEAD` muestra los commits en orden:
  dependencias → permisos → servicio → fix → mapa vivo → geocoding →
  formulario → repositorio → detalle/ruta → versión → tests → docs.
- `git rev-list --count HEAD` llega a **163**.
- `git log -p | grep -cE 'AIza[A-Za-z0-9_-]{30,}'` devuelve **0**:
  ninguna clave REAL en el historial (los `AIza...` de la documentación
  son ejemplos, no claves — MASVS intacto).
- `fvm flutter test` reporta **77 pruebas verdes** (71 + 6).
