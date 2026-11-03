# 4 · Definition of Done — CiudadAlerta (Sprint 0)

> Acordada en el Día 1 durante el Sprint 0 y aplicada a todas las historias del curso.
> El equipo puede ampliarla (nunca reducirla) en la Retrospectiva.

## Criterios generales (todas las historias)

1. **Código en el repositorio** con Pull Request revisado por al menos un compañero.
2. **La app compila y se ejecuta sin errores** en emulador y en un dispositivo real.
3. **Cumple los criterios de aceptación** de la historia y fue probada
   (pruebas alfa en Sprint 1 · unitarias en Sprints 2-4 · beta con usuarios en Sprint 4).
4. **Sin claves ni secretos en el repositorio** (usar `--dart-define`, variables de
   entorno o GitHub Secrets).
5. **Evidencia registrada** (captura o video corto) y tarjeta movida a **Hecho**
   en el tablero de GitHub Projects.
6. **Documentación mínima actualizada** (README, comentario de decisión o wiki).

## Criterios técnicos por sprint

| Sprint | Criterio adicional de terminado |
|---|---|
| 1 | App con 4 o más pantallas navegables con datos simulados; `flutter analyze` sin errores; pruebas alfa ejecutadas con planilla de casos. |
| 2 | App conectada a PostgreSQL (Supabase) con CRUD y autenticación; APK release instalable; script SQL versionado en `docs/sql/`. |
| 3 | 2 o más APIs externas integradas con claves restringidas; consumo documentado (costos y cuotas). |
| 4 | Producto estable probado con usuarios reales (SUS); build firmado; documentación y video demo. |

## Reglas de calidad permanente

- Mensajes de commit convencionales (`feat:`, `fix:`, `docs:`, `chore:`).
- Todo cambio pasa por Pull Request; **no se hace push directo a `main`**.
- El uso de IA generativa se **declara en la bitácora** del equipo (no se usa en
  pruebas individuales).
- El `pubspec.lock` y la versión de Flutter (FVM) no cambian durante el curso sin
  acuerdo del equipo y del docente.

## Verificación en el Sprint Review

El Product Owner (docente) recorre el tablero y comprueba, historia por historia:
evidencia + criterios de aceptación + demo en vivo. Solo lo que cumple el DoD
cuenta como **incremento** del sprint.
