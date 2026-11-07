# CiudadAlerta — Proyecto Guía · Aplicaciones Móviles I (SIS-0180)

**Sprint 1 · Día 4 — Avance de la Clase 4: Navegación, listas y formularios**

CiudadAlerta es la app móvil del Proyecto Guía de la asignatura **Aplicaciones Móviles I**
(Ingeniería de Sistemas · Octavo semestre). Permite a los ciudadanos de **La Paz y El Alto**
reportar problemas urbanos (baches, luminarias, basura, riesgos) con foto, voz y ubicación,
y dar seguimiento transparente al estado de cada reporte.

El docente actúa como **Product Owner** del Proyecto Guía y lo desarrolla en vivo (live coding);
cada equipo, en paralelo, aplica el mismo día lo aprendido en su **proyecto paralelo**.


## Avance de la Clase 4 (Día 4 · Sprint 1)

Este snapshot del repositorio corresponde al cierre del **Día 4**, cuyo tema fue
*"Navegación, listas y formularios"*. Novedades respecto al Día 3:

| Carpeta / archivo | Qué contiene |
|---|---|
| `app/lib/routing/app_router.dart` | `go_router`: rutas `/inicio`, `/mapa`, `/nuevo`, `/perfil`, `ShellRoute` de pestañas y `/reporte/:id` |
| `app/lib/screens/home_shell.dart` | **HU-02**: barra inferior con 4 pestañas (Inicio · Mapa · Nuevo · Perfil) |
| `app/lib/data/report.dart` | Modelo `Report` con `fromJson`/`toJson` (listo para Supabase en el Hito 2) |
| `app/lib/data/mock_reports.dart` | 8 reportes simulados de La Paz y El Alto + `cargarReportes()` async |
| `app/lib/screens/reports_list_screen.dart` | **HU-03**: `ListView.builder` con estados cargando / error / vacío |
| `app/lib/screens/report_detail_screen.dart` | **HU-04**: detalle con parámetro de ruta; muestra todos los campos |
| `app/lib/screens/new_report_screen.dart` | **HU-05**: `Form` + `TextFormField` + validadores; no envía si es inválido |
| `app/lib/screens/welcome_screen.dart` | **HU-01** actualizada: "Entrar" navega a `/inicio` (go_router) |
| `app/test/widget_test.dart` | Pruebas del flujo HU-01 → HU-02 → HU-03 → HU-04 |
| `app/test/form_validation_test.dart` | Pruebas de validación de la HU-05 (3 casos) |
| `docs/15-bitacora-dia4.md` | Plantilla de bitácora del equipo para el Día 4 |
| `docs/16-avance-git-dia4.md` | Guía de commits y Pull Request del Día 4 |

**Evidencia del día:** lista de cotejo de funcionalidades del Sprint 1 (HU-01 a HU-05),
aplicada al cierre del laboratorio → evaluada con la Matriz 1 (Hito 1, 20 pts).
El foro del LMS (UX móvil vs. web responsive) es la evidencia del trabajo autónomo.

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
│   └── 16-avance-git-dia4.md
├── matriz_decision/           ← plantilla de matriz de decisión (Día 2)
├── wireframes/                ← plantilla de wireframes (Día 2)
└── app/                       ← código Flutter (HU-01 a HU-05 desde el Día 4)
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
