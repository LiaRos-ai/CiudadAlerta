# 19 · Acta de la Retrospectiva 1 — CiudadAlerta (Día 5)

> Segundo evento de cierre del Sprint 1 (30 min). La retrospectiva mira el
> **proceso**, no el producto: cómo trabajó el equipo durante los 5 días.
> Técnica usada: **Start / Stop / Continue**, con 2 acciones de mejora concretas
> que el equipo verifica en la retrospectiva del Sprint 2.

## Datos de la sesión

| Campo | Valor |
|---|---|
| Sprint analizado | 1 (días 1-5) |
| Duración | 30 min |
| Moderación | Scrum Master rotativo |
| Regla de oro | Sin culpas: se discuten procesos y sistemas, no personas |

## 1. Lluvia en tres columnas (15 min)

### 🟢 START (empezar a hacer)

- Pair programming con rotación REAL cada 15 min (a veces rotamos solo en teoría).
- Escribir el caso de prueba ANTES de arreglar el bug (registro en la planilla 17).
- Revisar los PR de otros equipos con sugerencias concretas, no solo "LGTM".

### 🔴 STOP (dejar de hacer)

- Commits gigantes tipo "avance del día" que mezclan UI, datos y tests.
- Dejar `flutter analyze` para el final: los 40 warnings de la tarde del día 3
  se habrían evitado aplicando el linter desde el primer archivo.
- Discutir alcance dentro del Daily Scrum (eso va con el PO después del Daily).

### 🔵 CONTINUE (seguir haciendo)

- Datos mock creíbles del contexto boliviano: hicieron las demos revisibles.
- Commits convencionales (`feat:`, `test:`, `docs:`): el historial cuenta la historia.
- Widget de prueba del tema antes de cada commit (evitó romper el shell dos veces).

## 2. Datos objetivos del sprint (5 min)

| Indicador | Valor | Lectura |
|---|---|---|
| Commits del sprint | 38 | Promedio ~8 por día: granularidad correcta |
| Tags | v0.0.0-sprint0 → v0.4.0-dia5 | 5 hitos de avance etiquetados |
| Historias completadas | 6 / 6 (21 pts) | 100 % del compromiso del sprint |
| Pruebas en verde al cierre | 9 | Flujo, validación y alfa automatizada |
| Bugs de las pruebas alfa | registrados como issues | Ninguno bloqueante |

## 3. Dos acciones de mejora (10 min, con responsable y verificación)

| # | Acción | Responsable | Se verifica en |
|---|---|---|---|
| A1 | Rotación piloto/copiloto con temporizador visible de 15 min y registro en la bitácora del día | Scrum Master de la semana | Bitácora del Día 6 (docs/23) |
| A2 | `fvm flutter analyze` + `fvm flutter test` corren ANTES de cada commit (hook del equipo), no solo al final del día | Todo el equipo | El PR del Día 6 no trae warnings |

## 4. Cierre

Las acciones A1 y A2 se copian al tablero (columna "En curso") y se revisan en
el Daily Scrum del Día 6. La retrospectiva termina SIEMPRE con acciones, no con
opiniones: esa es la diferencia entre quejarse y mejorar.

**Firmas / acuerdo del equipo:** ______________________
