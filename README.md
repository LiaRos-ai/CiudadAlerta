# CiudadAlerta — Proyecto Guía · Aplicaciones Móviles I (SIS-0180)

**Sprint 1 · Día 5 — Cierre del Sprint 1: pruebas alfa, control de versiones y release v0.1**

CiudadAlerta es la app móvil del Proyecto Guía de la asignatura **Aplicaciones Móviles I**
(Ingeniería de Sistemas · Octavo semestre). Permite a los ciudadanos de **La Paz y El Alto**
reportar problemas urbanos (baches, luminarias, basura, riesgos) con foto, voz y ubicación,
y dar seguimiento transparente al estado de cada reporte.

El docente actúa como **Product Owner** del Proyecto Guía y lo desarrolla en vivo (live coding);
cada equipo, en paralelo, aplica el mismo día lo aprendido en su **proyecto paralelo**.


## Cierre del Sprint 1 (Clase 5 · Día 5)

Este snapshot corresponde a la **entrega del Hito 1**: tema *"Pruebas alfa,
control de versiones y cierre del Sprint 1"*. El incremento del Día 4
(4 pestañas, lista, detalle y formulario) se completa con:

| Carpeta / archivo | Qué contiene |
|---|---|
| `app/lib/theme/app_theme.dart` | **HU-06**: tema claro + tema oscuro con la misma semilla (Material 3) |
| `app/lib/main.dart` | `darkTheme` + `themeMode: ThemeMode.system` (respeta la configuración del sistema) |
| `app/test/alfa_test.dart` | **Pruebas alfa automatizadas**: HU-06 (dos temas), conteo de 8 tarjetas (HU-03) y caso de borde del detalle (HU-04) |
| `docs/17-casos-prueba-alfa.md` | Planilla de 10 casos de prueba alfa del Sprint 1 (pasos, esperado, real, estado) |
| `docs/18-sprint-review-1.md` | Acta del **Sprint Review 1**: demo del incremento y ajustes al Product Backlog |
| `docs/19-retrospectiva-1.md` | Acta de la **Retrospectiva 1** (Start / Stop / Continue) con 2 acciones de mejora |
| `docs/20-informe-1.md` | **Informe 1 (entregable del Hito 1)**: matriz de decisión, wireframes, app y reporte de pruebas alfa |
| `docs/21-avance-git-dia5.md` | Guía de commits del día, GitFlow simplificado y publicación del **release v0.1** |
| `docs/22-bitacora-dia5.md` | Bitácora del Día 5 con el registro de la prueba individual del LMS |

**Release v0.1 del producto**: tag `v0.4.0-dia5` (historial: `v0.0.0-sprint0` →
`v0.1.0-dia2` → `v0.2.0-dia3` → `v0.3.0-dia4` → `v0.4.0-dia5`), 9 pruebas en verde
y `fvm flutter analyze` sin advertencias. Evidencia oficial del día: **Informe 1 +
app sencilla con framework**, evaluada con la Matriz 1 (Hito 1, 20 pts).

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
