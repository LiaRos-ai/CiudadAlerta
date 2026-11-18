# 49 · Avance Git del Día 11 — CiudadAlerta (Sprint 3)

> Registro de los **17 commits** del Día 11 ("Sprint Planning 3: concepto
> de API, REST, JSON y consumo seguro"). Un commit por pieza: cada uno
> compila por separado y cuenta una historia revisable en el PR. La guía
> de convenciones vive en `docs/07-convenciones-git.md`.

## Estado de partida

- Tag del día anterior: `v0.9.0-dia10` (APK release instalable + cierre
  del Sprint 2; 59 pruebas verdes).
- Faltaba el eslabón del Hito 3: la app todavía NO consumía APIs externas
  directamente (Supabase llegaba envuelto en su SDK) y nadie había
  probado un endpoint en Postman antes de codificar.
- Entra al sprint: `http`, el modelo `Clima`, el primer cliente REST y la
  tarjeta de clima con deterioro elegante.

## Historia del día (17 commits)

| # | Commit | Qué contiene |
|---|---|---|
| 1 | `chore: dependencias http para el consumo de APIs (Sprint 3)` | `app/pubspec.yaml` (http ^1.2.2) |
| 2 | `feat: modelo Clima con fromJson para Open-Meteo` | `app/lib/data/clima/clima.dart` |
| 3 | `feat: mapeo visual de códigos de clima (íconos y colores)` | `app/lib/data/clima/clima_visual.dart` |
| 4 | `feat: WeatherService con cliente http inyectable y códigos de estado` | `app/lib/data/clima/weather_service.dart` |
| 5 | `feat: ApiConfig con --dart-define para claves externas (sin secretos en el repo)` | `app/lib/data/api/api_config.dart` |
| 6 | `feat: proveedor del clima con Riverpod y deterioro elegante` | `app/lib/providers/clima_provider.dart` |
| 7 | `feat: tarjeta de clima en la pantalla de reportes` | `app/lib/widgets/clima_card.dart` + integración en `reports_list_screen.dart` |
| 8 | `feat: colección Postman con los endpoints de la app y de Open-Meteo` | `api/postman_collection.json` |
| 9 | `chore: versión 1.0.0+2 para el arranque del Sprint 3` | `app/pubspec.yaml` (versionName 1.0.0, versionCode 2: nunca se reusa) |
| 10 | `test: clima y configuración de APIs (65 pruebas verdes)` | `app/test/clima_test.dart` (6 pruebas: modelo 2, servicio 3, config 1) |
| 11 | `docs: Sprint Backlog 3 publicado en el tablero (docs/45)` | `docs/45-sprint-backlog-3.md` |
| 12 | `docs: cuadro comparativo de APIs del Día 11 (docs/46)` | `docs/46-cuadro-comparativo-apis.md` (evidencia oficial, Matriz 3) |
| 13 | `docs: guía REST, JSON y consumo seguro (docs/47)` | `docs/47-api-rest-json.md` |
| 14 | `docs: guía técnica del servicio de clima (docs/48)` | `docs/48-servicio-clima-open-meteo.md` |
| 15 | `docs: avance git del día 11 (docs/49)` | este archivo |
| 16 | `docs: bitácora del día 11 con el Planning Poker del Sprint 3 (docs/50)` | `docs/50-bitacora-dia11.md` |
| 17 | `docs: READMEs actualizados con el clima y el Sprint 3` | `README.md` + `app/README.md` |

## Verificación del cierre (checklist del día)

```bash
git log --oneline v0.9.0-dia10..HEAD | wc -l      # 17
fvm flutter analyze                                # 0 issues
fvm flutter test                                   # 65 pruebas verdes
git status --short                                 # (limpio)
git tag                                            # ... v0.9.0-dia10 v1.0.0-dia11
```

## El tag del día

```bash
git tag -a v1.0.0-dia11 -m "Clase 11 (Día 11): Sprint Planning 3 + primera
API externa consumida con http (clima Open-Meteo sin API key) con modelo
Clima, ApiConfig sin secretos y deterioro elegante; cuadro comparativo de
APIs (Matriz 3); suite en 65 pruebas verdes"
```

Por qué el salto de versión: el Sprint 3 abre el Hito 3 (la app pasa de
"con datos reales" a "con servicios externos") y el semver reserva el
1.0.0 para producto completo por épica — el `versionCode` sube a 2 para
respetar la regla de nunca reusar el build number del APK 0.9.0+1.
