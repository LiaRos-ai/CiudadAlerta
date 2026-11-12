# 30 · Bitácora del Día 7 — CiudadAlerta (Sprint 2)

> Plantilla de bitácora del equipo para el Día 7. Se completa al cierre de la
> clase y se sube al repositorio con commit `docs: bitácora del día 7`. El
> historial de bitácoras es evidencia del criterio "Proceso Scrum" (rúbrica
> de proceso, 3 pts por hito).

## Datos del día

| Campo | Valor |
|---|---|
| Día / Sprint | Día 7 · Sprint 2 · Hito 2 |
| Fecha | ____ / ____ / 2026 |
| Tema | Bases de datos para móviles: modelado relacional, SQL y Supabase (PostgreSQL) |
| Equipo | ____________________ |
| Scrum Master del día | ____________________ |
| Product Owner del día (docente) | ____________________ |

## Daily Scrum (inicio)

| Integrante | Ayer | Hoy | Impedimentos |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

**Quiz de activación (PK/FK, SELECT y JOIN):** grupo ______ ·
participantes ______ · promedio ______ · preguntas con más errores: ______

## Laboratorio del Proyecto Guía

| Paso | Resultado | Observaciones |
|---|---|---|
| A · Modelo ER en papel (docs/27) | ☐ | Entidades y relaciones acordadas antes de abrir Supabase |
| B · Proyecto Supabase + SQL Editor | ☐ | Región ____________ · plan B aplicado: ☐ sí ☐ no |
| C · schema.sql ejecutado (5 tablas) | ☐ | Table Editor verificado |
| D · seed.sql ejecutado (5/4/8/4/3) | ☐ | Categorías y 8 reportes del mock |
| E · consultas.sql C01–C10 | ☐ | Consultas con error: ____________ |
| F · Commits + PR + tag v0.6.0-dia7 | ☐ | |

## Revisión por pares del modelo ER (cierre)

| Checklist de normalización | Nuestro ER | ER del compañero |
|---|---|---|
| 1FN: sin listas en celdas (fotos y comentarios en tablas propias) | ☐ | ☐ |
| 2FN: PK simples; nada depende de "parte" de la clave | ☐ | ☐ |
| 3FN: sin redundancia (nombre de categoría NO copiado en reports) | ☐ | ☐ |
| PK y FK declaradas; cardinalidades correctas | ☐ | ☐ |
| Índices en FK y columnas de filtro (categoria_id, estado, creado_en) | ☐ | ☐ |

**Hallazgos de la revisión (1–3 líneas por hallazgo):**

1. ________________________________________________
2. ________________________________________________

## Proyecto paralelo (nuestra app)

| Campo | Registro |
|---|---|
| Entidades del ER (mínimo 4 tablas) | ____________________ |
| ¿Dónde quedó el ER del equipo? | docs/ o carpeta db/ del proyecto: ____ |
| N.º de consultas de prueba documentadas | ____ (meta: 10) |
| Impedimento mayor del día | ____________________ |

## Trabajo autónomo asignado (90 min)

- Teoría (45 min, LMS): documentación "Database" de Supabase + tutorial de
  JOIN y agregaciones; participación en el foro (buenas prácticas de modelado).
- Proyecto (45 min): guía de 10 consultas SQL sobre el esquema del proyecto
  paralelo (C01–C10 con comentario de qué HU sirve cada una).

## Evidencia del día

- [x] Esquema ER + script SQL (evidencia oficial del Día 7, lista de cotejo).
- [x] `db/` con schema.sql, seed.sql y consultas.sql commiteados.
- [x] PR hacia dev con revisión por pares y tag `v0.6.0-dia7`.
