# 34 · Bitácora del Día 8 — CiudadAlerta (Sprint 2)

> Plantilla de bitácora del equipo para el Día 8. Se completa al cierre de la
> clase y se sube al repositorio con commit `docs: bitácora del día 8`. El
> historial de bitácoras es evidencia del criterio "Proceso Scrum" (rúbrica
> de proceso, 3 pts por hito).

## Datos del día

| Campo | Valor |
|---|---|
| Día / Sprint | Día 8 · Sprint 2 · Hito 2 |
| Fecha | ____ / ____ / 2026 |
| Tema | Conexión de la app a la BD: CRUD, consultas y presentación de datos |
| Equipo | ____________________ |
| Scrum Master del día | ____________________ |
| Product Owner del día (docente) | ____________________ |

## Daily Scrum (inicio)

| Integrante | Ayer | Hoy | Impedimentos |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

**Quiz de activación (cliente supabase_flutter, Future y async/await):**
grupo ______ · participantes ______ · promedio ______ ·
preguntas con más errores: ______

## Laboratorio del Proyecto Guía

| Paso | Resultado (SI / NO / EN PROCESO) | Observación |
|---|---|---|
| A. Dependencias + cliente con `--dart-define` | | |
| B. Repositorio Supabase (CRUD + consultas) | | |
| C. HU-09: lista con filtro y orden desde la BD | | |
| D. HU-10: crear / editar / eliminar | | |
| E. HU-13: estadísticas + gráfico fl_chart | | |
| F. Commits, PR y tag v0.7.0-dia8 | | |

## Demo funcional de CRUD y consultas (evidencia oficial)

| Paso de la demo (docs/32) | Se cumplió | Nota |
|---|---|---|
| 1. Lista desde la BD con filtro (HU-09) | ☐ | |
| 2. Crear con validación (HU-10) | ☐ | |
| 3. Leer y editar (HU-10) | ☐ | |
| 4. Eliminar con CASCADE (HU-10) | ☐ | |
| 5. Estadísticas y gráfico (HU-13) | ☐ | |
| 6. Contrato de datos (31 pruebas verdes) | ☐ | |

**Modo usado en la demo:** ☐ demo (mock) ☐ Supabase con `--dart-define`

## Registro de la conexión (para el Informe 2)

| Dato | Valor |
|---|---|
| Proyecto Supabase (nombre) | ____________________ |
| Región | ____________________ |
| Modo de inyección de credenciales | `--dart-define` (URL y clave ANON; sin service_role) |
| Tablas usadas por la app hoy | reports, categories |
| Consulta principal (texto) | `.from('reports').select('*, categories(nombre)').order('creado_en', ascending: false)` |
| Pruebas de la suite | 31 verdes (fvm flutter test) |

## Control de seguridad del cierre (¿hay claves en el repositorio?)

| Verificación | Resultado |
|---|---|
| `git log -p \| grep -i "supabase.co"` sin claves reales | ☐ |
| `--dart-define` no pegado en ningún script del repo | ☐ |
| Clave anon del proyecto propio (no la del docente) | ☐ |
| Si hubo fuga: clave rotada en Settings → API | ☐ N/A |

## Proyecto paralelo (45 min)

| Equipo / app | Listado con filtro | CRUD | Indicador agregado |
|---|---|---|---|
| MoviPaz | | | |
| SaludCerca | | | |
| EmprendeLocal | | | |
| CulturaAndina | | | |

## Retrospectiva rápida del día

| Seguir haciendo | Dejar de hacer | Empezar a hacer |
|---|---|---|
| | | |

**Compromiso para el Día 9:** autenticación (HU-08) y foto con permisos
nativos (HU-11) — llegar con la demo del Día 8 funcionando y el proyecto
Supabase activo (el plan gratuito se pausa por inactividad: abrirla hoy).

## Anexos

- Capturas de la demo: ____________________ (carpeta compartida del equipo)
- Video corto de la demo: ____________________
- Hallazgos de la revisión por pares del PR: ____________________
