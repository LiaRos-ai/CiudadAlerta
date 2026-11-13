# CiudadAlerta — Proyecto Guía · Aplicaciones Móviles I (SIS-0180)

**Sprint 2 · Día 8 — La app se conecta a la base de datos: CRUD, consultas y presentación**

CiudadAlerta es la app móvil del Proyecto Guía de la asignatura **Aplicaciones Móviles I**
(Ingeniería de Sistemas · Octavo semestre). Permite a los ciudadanos de **La Paz y El Alto**
reportar problemas urbanos (baches, luminarias, basura, riesgos) con foto, voz y ubicación,
y dar seguimiento transparente al estado de cada reporte.

El docente actúa como **Product Owner** del Proyecto Guía y lo desarrolla en vivo (live coding);
cada equipo, en paralelo, aplica el mismo día lo aprendido en su **proyecto paralelo**.


## Conexión a la BD del Sprint 2 (Clase 8 · Día 8)

Este snapshot corresponde al **tercer día del Hito 2**: tema *"Conexión de la
app a la BD: CRUD, consultas y presentación de datos"*. La app del Día 6
(capas + Riverpod + HU-07) habla hoy con la base de datos creada el Día 7:
la evidencia oficial del día es la **Demo funcional de CRUD y consultas
(lista de cotejo)**.

| Carpeta / archivo | Qué contiene |
|---|---|
| `app/lib/data/supabase_config.dart` | **Cliente de Supabase** con credenciales por `--dart-define` (nunca en el repo) y **modo demo** sin credenciales |
| `app/lib/data/supabase_reports_repository.dart` | **CRUD y consultas contra PostgreSQL**: filtro/orden con select anidado (HU-09), insert/update/delete (HU-10), agregados (HU-13) |
| `app/lib/data/estadistica.dart` | Modelos de **estadísticas** con agrupado determinista (el GROUP BY de HU-13, equivalente al C06 del Día 7) |
| `app/lib/data/reports_repository.dart` | Interfaz + mock con CRUD demo + **provider que decide la implementación** (Supabase o demo) |
| `app/lib/providers/reports_provider.dart` | Providers de filtro, lista, detalle y estadísticas (AsyncValue) |
| `app/lib/screens/stats_screen.dart` | **Pantalla de estadísticas** con gráfico de barras `fl_chart` (HU-13) |
| `app/test/` | Suite de **31 pruebas** (contrato app ↔ BD, CRUD demo, filtros, agregados, widgets y estadísticas) |
| `docs/31-conexion-supabase.md` | Decisiones de conexión: cliente, variables de entorno, mapeo SQL→API, AsyncValue y seguridad |
| `docs/32-demo-crud-consultas.md` | **Guion de la demo funcional** (evidencia oficial): pasos y criterios observables |
| `docs/33-avance-git-dia8.md` | Guía de commits del Día 8 y etiqueta `v0.7.0-dia8` |
| `docs/34-bitacora-dia8.md` | Bitácora del Día 8 con el registro de la demo y el control de claves |

**Cómo correr la app hoy:**

```bash
fvm flutter run   # modo DEMO (mock): CRUD en memoria, sin credenciales

# contra tu proyecto Supabase del Día 7 (claves fuera del repo):
fvm flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU-CLAVE-ANON
```

**Avance del producto**: tag `v0.7.0-dia8` (historial: `v0.0.0-sprint0` →
`v0.1.0-dia2` → `v0.2.0-dia3` → `v0.3.0-dia4` → `v0.4.0-dia5` → `v0.5.0-dia6` →
`v0.6.0-dia7` → `v0.7.0-dia8`), `fvm flutter analyze` sin advertencias y
`fvm flutter test` en verde (31 pruebas). Evidencia oficial del día:
**Demo funcional de CRUD y consultas**.

### Camino del Sprint 2 (Hito 2)

| Día | Tema | HU |
|---|---|---|
| 6 ✅ | Arquitectura por capas, Riverpod y persistencia local | HU-07 |
| 7 ✅ | Bases de datos: modelado ER, SQL y Supabase | esquema + seed |
| 8 ✅ | CRUD, consultas y presentación de datos | HU-09, HU-10, HU-13 |
| 9 | Autenticación, seguridad (RLS) y recurso nativo | HU-08, HU-11 |
| 10 | Distribuciones: APK release y cierre del sprint | HU-12 + Informe 2 |

## Cierre del Sprint 1 (referencia · Día 5)

El Hito 1 cerró con el release v0.1 (tag `v0.4.0-dia5`): tema claro/oscuro (HU-06),
pruebas alfa documentadas (`docs/17`), actas de Review y Retrospectiva (`docs/18-19`),
Informe 1 (`docs/20`) y guía de release (`docs/21-22`). Ese incremento es la base
estable sobre la que arranca el Sprint 2.

## Visión del producto

> Para ciudadanos de La Paz y El Alto que necesitan reportar problemas urbanos
> (baches, luminarias, basura, riesgos), **CiudadAlerta** es una app móvil que permite
> crear reportes geolocalizados con foto y voz, a diferencia de los canales actuales
> dispersos, y da seguimiento transparente al estado de cada reporte.

Detalle completo en [`docs/01-product-vision-board.md`](docs/01-product-vision-board.md).

## Stack tecnológico del curso

| Capa | Tecnología |
|---|---|
| Lenguaje | Dart (null safety) |
| Framework multiplataforma | Flutter (versión fija con **FVM**) |
| Navegación | go_router |
| Estado y arquitectura | Riverpod + arquitectura por capas |
| UI | Material 3 |
| Base de datos y backend | Supabase (PostgreSQL + Auth + Storage) |
| APIs externas | Google Maps Platform · AWS (S3, Lambda, Rekognition) |
| Notificaciones y voz | Firebase Cloud Messaging · speech_to_text · flutter_tts |
| Control de versiones y Scrum | GitHub (repositorio + Projects + Actions) |

**Regla del curso:** las versiones de Flutter, Dart y paquetes quedan congeladas al inicio
con FVM y `pubspec.lock`. No ejecutar `flutter upgrade` durante el semestre.

## Metodología de trabajo

- **Scrum (Guía 2020)**: 4 sprints de 5 días de clase (15 h cada uno).
- **Eventos**: Sprint Planning (día 1 de cada sprint), Daily Scrum (inicio de cada clase),
  Sprint Review + Retrospectiva (día 5), Refinamiento (cierre del día 5).
- **Tablero GitHub Projects**: `Backlog → Ready → En curso → En revisión → Hecho`
  (máximo 2 tarjetas "En curso" por persona).
- **Definition of Done**: código en repositorio con PR revisado, app compilando en
  emulador y dispositivo real, criterios de aceptación cumplidos, sin claves en el
  repositorio, evidencia (captura o video) y tarjeta movida a "Hecho".

## Estructura del repositorio

```
ciudadalerta/
├── README.md                  ← este archivo
├── docs/                      ← artefactos del Sprint 0 y bitácoras diarias
│   ├── 01-product-vision-board.md
│   ├── 02-personas.md
│   ├── 03-product-backlog.md  (27 historias de usuario, 118 puntos)
│   ├── 04-definition-of-done.md
│   ├── 05-definition-of-ready.md
│   ├── 06-working-agreement.md
│   ├── 07-convenciones-git.md
│   ├── 08-sprint-planning-1.md
│   ├── 09-matriz-decision-framework.md
│   ├── 10-bitacora-dia2.md
│   ├── 12-avance-git-dia2.md
│   ├── 13-bitacora-dia3.md
│   ├── 14-avance-git-dia3.md
│   ├── 15-bitacora-dia4.md
│   ├── 16-avance-git-dia4.md
│   ├── 17-casos-prueba-alfa.md
│   ├── 18-sprint-review-1.md
│   ├── 19-retrospectiva-1.md
│   ├── 20-informe-1.md
│   ├── 21-avance-git-dia5.md
│   ├── 22-bitacora-dia5.md
│   ├── 23-sprint-planning-2.md
│   ├── 24-arquitectura-capas.md
│   ├── 25-avance-git-dia6.md
│   ├── 26-bitacora-dia6.md
│   ├── 27-modelo-er.md
│   ├── 28-script-sql.md
│   ├── 29-avance-git-dia7.md
│   ├── 30-bitacora-dia7.md
│   ├── 31-conexion-supabase.md
│   ├── 32-demo-crud-consultas.md
│   ├── 33-avance-git-dia8.md
│   └── 34-bitacora-dia8.md
├── db/                        ← SQL de Supabase: schema, seed y consultas (Día 7)
├── matriz_decision/           ← plantilla de matriz de decisión (Día 2)
├── wireframes/                ← plantilla de wireframes (Día 2)
└── app/                       ← código Flutter (HU-01..HU-10 y HU-13; conectada a Supabase desde el Día 8)
```

## Equipo y roles Scrum

| Rol | Responsable | Responsabilidad |
|---|---|---|
| Product Owner (Proyecto Guía) | Docente | Prioriza el Product Backlog y acepta el incremento en el Review. |
| Scrum Master | Rotativo por sprint | Facilita eventos, gestiona impedimentos, cuida el tablero. |
| Developers | Estudiantes | Diseñan, programan, prueban y documentan; todos hacen commits y revisan PR. |

## Cómo contribuir (resumen)

1. Toma una historia del tablero y muévela a **En curso**.
2. Crea una rama: `git switch -c feature/HU-05-formulario-reporte`.
3. Haz commits convencionales: `feat:`, `fix:`, `docs:`, `chore:` (ver
   [`docs/07-convenciones-git.md`](docs/07-convenciones-git.md)).
4. Abre un **Pull Request** y pide revisión a un compañero.
5. Al aprobarse, merge y mueve la tarjeta a **Hecho** con su evidencia.

## Licencia y uso

Material didáctico de la asignatura Aplicaciones Móviles I (SIS-0180). Uso educativo.
No incluir claves ni secretos en este repositorio: se usan variables de entorno
(`--dart-define`) o GitHub Secrets.
