# 33 · Avance Git del Día 8 — CiudadAlerta (Sprint 2)

> Registro de los **16 commits** del Día 8 ("Conexión de la app a la BD:
> CRUD, consultas y presentación de datos"). Un commit por pieza: cada uno
> compila por separado y cuenta una historia revisable en el PR. La guía de
> convenciones vive en `docs/07-convenciones-git.md`.

## Estado de partida

- Tag del día anterior: `v0.6.0-dia7` (modelo ER, script SQL, seed y
  consultas en `db/`).
- La app corre con mock; la interfaz `ReportsRepository` ya prometía el
  cambio de implementación (docs/24, decisión de arquitectura del Día 6).

## Commits del Día 8

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Dependencias del Sprint 2 (cliente y gráfico) | `app/pubspec.yaml` | `chore: dependencias supabase_flutter y fl_chart para el Sprint 2` |
| 2 | Cliente de Supabase con `--dart-define` y modo demo | `app/lib/data/supabase_config.dart` | `feat: cliente de Supabase con variables de entorno --dart-define` |
| 3 | Modelos de agregados HU-13 (GROUP BY en Dart) | `app/lib/data/estadistica.dart` | `feat: modelos de estadísticas con GROUP BY determinista (HU-13)` |
| 4 | Repositorio Supabase (CRUD + consultas) y mock con CRUD demo | `app/lib/data/supabase_reports_repository.dart`, `app/lib/data/reports_repository.dart` | `feat: repositorio Supabase con CRUD y consultas (HU-09 y HU-10)` |
| 5 | Providers de filtro, detalle y estadísticas | `app/lib/providers/reports_provider.dart` | `feat: providers de filtro, detalle y estadísticas (HU-09 y HU-13)` |
| 6 | Lista con chips de filtro y acceso a estadísticas | `app/lib/screens/reports_list_screen.dart` | `feat: filtro por categoría en la lista de reportes (HU-09)` |
| 7 | Formulario en modo edición con guardado asíncrono | `app/lib/screens/new_report_screen.dart` | `feat: formulario en modo edición con guardado asíncrono (HU-10)` |
| 8 | Detalle con editar y eliminar (confirmación + CASCADE) | `app/lib/screens/report_detail_screen.dart` | `feat: edición y eliminación desde el detalle del reporte (HU-10)` |
| 9 | Pantalla de estadísticas con fl_chart y nuevas rutas | `app/lib/screens/stats_screen.dart`, `app/lib/routing/app_router.dart`, `app/lib/main.dart` | `feat: estadísticas con gráfico de barras y rutas /estadisticas y /editar (HU-13)` |
| 10 | Versión del paquete para el avance del Sprint 2 | `app/pubspec.yaml` | `chore: versión 0.7.0+1 para el avance del Sprint 2` |
| 11 | Suite de pruebas al Día 8 (31 verdes) | `app/test/` (7 archivos) | `test: CRUD demo, filtros, agregados y estadísticas (31 pruebas verdes)` |
| 12 | Decisiones de conexión | `docs/31-conexion-supabase.md` | `docs: decisiones de conexión a la BD (cliente, env, mapeo y AsyncValue)` |
| 13 | Guion de la demo (evidencia oficial) | `docs/32-demo-crud-consultas.md` | `docs: guion de la demo funcional de CRUD y consultas` |
| 14 | Guía de commits del día | `docs/33-avance-git-dia8.md` | `docs: guía de commits del día 8` |
| 15 | Bitácora del día | `docs/34-bitacora-dia8.md` | `docs: bitácora del día 8 con el registro de la demo` |
| 16 | README raíz y de la app | `README.md`, `app/README.md` | `docs: READMEs actualizados con el CRUD de Supabase` |

## Flujo Git del día

```bash
git switch dev && git pull origin dev
git switch -c feature/dia8-crud-consultas-supabase
# ... pasos A-F del laboratorio con un commit por pieza ...
git push -u origin feature/dia8-crud-consultas-supabase
# Pull Request hacia dev + revisión por pares (regla del curso)

git tag -a v0.7.0-dia8 -m "Clase 8 (Día 8): app conectada a Supabase -
CRUD completo (HU-10), filtro y orden (HU-09) y estadísticas con
gráfico (HU-13); modo demo sin credenciales; suite en 31 verdes"
```

## Verificación del historial

- `git log --oneline v0.6.0-dia7..HEAD` debe listar 16 commits con el
  formato `tipo: descripción` (feat/chore/test/docs).
- `git log -p | grep -i "supabase.co"` NO debe mostrar claves reales:
  las credenciales viajan por `--dart-define` (cierre del día).
- La suite de pruebas queda en **31 verdes** (`fvm flutter test`).
