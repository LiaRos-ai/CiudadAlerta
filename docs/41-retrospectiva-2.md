# 41 · Retrospectiva del Sprint 2 — CiudadAlerta (Día 10)

> 20 minutos después del Review. Formato **Start / Stop / Continue**.
> El equipo analiza el proceso (no el producto) y deja máx. 3 compromisos
> medibles para el Sprint 3. El Scrum Master del día facilita y redacta.

## Métricas del sprint (hechos, no opiniones)

| Métrica | Inicio (Día 5) | Cierre (Día 10) | Lectura |
|---|---|---|---|
| Puntos hechos | 21/21 (Sprint 1) | 31/31 (HU-07..HU-13) | Meta cumplida |
| Commits acumulados | 40 | 112 | +72 en 5 días (~14/día, uno por pieza) |
| Pruebas en verde | 9 | 59 | El crecimiento se automatizó (contrato, CRUD, auth, release) |
| Tags | v0.4.0-dia5 | v0.9.0-dia10 | Cada día = un incremento revisable |
| Incidencias registradas | 3 | 6 (2 mayores: pause del plan gratuito de Supabase, keystore perdido 1 h) | Se gestionaron sin bloquear el día |

## Start (empezar a hacer)

1. **Batería de respaldo para el plan gratuito de Supabase**: un segundo
   proyecto del equipo (schema.sql + seed.sql se re-ejecutan en 10 min).
2. **Checklist de build antes de taggear**: `analyze + test + build` en
   verde, y solo entonces tag (evita el APK sin firmar del intento 1).
3. **Backup del keystore fuera del repo** con acceso acordado del equipo
   (el intento perdido de 1 h fue la lección más cara del sprint).

## Stop (dejar de hacer)

1. **Commits "chorro"** (`feat: cambios`) que mezclan UI + repositorio:
   volver al estándar de un commit = una pieza revisable.
2. **Probar solo en el emulador**: el permiso de cámara y la splash se
   evalúan en el teléfono desde el Día 10.
3. **Aumentar alcance a mitad de sprint** (la "mini pantalla de mapa" que
   nadie pidió): se discute en el refinamiento, no en plena HU.

## Continue (seguir haciendo)

1. **Un commit por pieza + PR con revisión por pares**: el historial
   cuenta la historia del sprint y facilita detectar el commit culpable.
2. **Dart puro probado sin red** (validadores, estadísticas, release
   config): la suite corre sin Supabase activo.
3. **Bitácora diaria con capturas**: el Informe 2 se armó en 30 min
   porque las evidencias ya estaban recolectadas cada día.

## Compromisos para el Sprint 3 (máx. 3, medibles)

| # | Compromiso | Cómo se verifica |
|---|---|---|
| 1 | Respaldo de proyecto Supabase por equipo creado el día 1 del sprint | Captura del Table Editor del proyecto B |
| 2 | Ningún commit sin tipo convencional (feat/fix/docs/chore/test) | `git log --oneline` del sprint revisado en el Review 3 |
| 3 | Checklist de build ejecutada antes de cada tag | docs de bitácora con la salida de scripts/build_release.sh |
