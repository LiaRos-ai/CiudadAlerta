# 29 · Avance del Día 7 · Clase 7 — esquema ER y script SQL en el repositorio

> Guía de commits del **Día 7** para el equipo. Complementa `docs/07-convenciones-git.md`.
> El Día 7 deja en el repo la **evidencia oficial del día**: el Esquema ER
> (`docs/27`) y el script SQL (`db/`). La rama sigue el mismo flujo del Sprint 2.

## 1. Qué entrega el equipo al final del Día 7

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Modelo entidad-relación + normalización 3FN | `docs/27-modelo-er.md` | `docs: modelo entidad-relación de CiudadAlerta con normalización 3FN` |
| 2 | Esquema SQL de las 5 tablas (DDL + RLS) | `db/schema.sql` | `feat: esquema SQL de Supabase con las 5 tablas del Proyecto Guía` |
| 3 | Datos semilla coherentes con el mock de la app | `db/seed.sql` | `feat: datos semilla coherentes con los 8 reportes mock (RPT-001..008)` |
| 4 | 10 consultas de práctica (filtros, JOIN, GROUP BY) | `db/consultas.sql` | `docs: guía de 10 consultas SQL de práctica (filtros, JOIN y agregados)` |
| 5 | Documento de decisiones del script SQL | `docs/28-script-sql.md` | `docs: decisiones del script SQL (DDL, DML, RLS y BaaS)` |
| 6 | Versión 0.6.0 del paquete | `app/pubspec.yaml` | `chore: versión 0.6.0+1 para el avance del Sprint 2` |
| 7 | Contrato de datos app ↔ BD (test) | `app/test/data_contract_test.dart` | `test: contrato de categorías y reportes entre la app y el seed de la BD` |
| 8 | Guía de commits del día | `docs/29-avance-git-dia7.md` | `docs: guía de commits del día 7` |
| 9 | Bitácora del día | `docs/30-bitacora-dia7.md` | `docs: bitácora del día 7 con el registro del esquema ER` |
| 10 | README raíz y de la app actualizados | `README.md`, `app/README.md` | `docs: READMEs actualizados con la base de datos del Sprint 2` |

**Evidencia oficial del Día 7:** **Esquema ER + script SQL (lista de cotejo)**.
La lista de cotejo verifica las 12 condiciones del día (modelado, DDL, seed,
consultas, índices, RLS base, Git y bitácora).

## 2. Rama y flujo del día

```bash
# Continuidad del Sprint 2
git switch dev && git pull origin dev
git switch -c feature/dia7-modelo-sql-supabase

# El dia trabaja tres carpetas: docs/ (ER y decisiones), db/ (SQL) y app/test/
mkdir -p db

# ... pasos de la Guía Práctica (A–F) con un commit por pieza ...

git push -u origin feature/dia7-modelo-sql-supabase
# Pull Request hacia dev con revisión por pares (regla del curso)
```

## 3. Los 10 commits del Día 7 (uno por pieza, nunca un commit gigante)

```text
docs:  modelo entidad-relación de CiudadAlerta con normalización 3FN
feat:  esquema SQL de Supabase con las 5 tablas del Proyecto Guía
feat:  datos semilla coherentes con los 8 reportes mock (RPT-001..008)
docs:  guía de 10 consultas SQL de práctica (filtros, JOIN y agregados)
docs:  decisiones del script SQL (DDL, DML, RLS y BaaS)
chore: versión 0.6.0+1 para el avance del Sprint 2
test:  contrato de categorías y reportes entre la app y el seed de la BD
docs:  guía de commits del día 7
docs:  bitácora del día 7 con el registro del esquema ER
docs:  READMEs actualizados con la base de datos del Sprint 2
```

**Tag del día** (después del merge del PR hacia `dev`):

```bash
git tag -a v0.6.0-dia7 -m "Clase 7 (Día 7): modelo ER, script SQL de Supabase
(5 tablas), datos semilla del mock y 10 consultas de práctica (evidencia del Día 7)"
git push origin v0.6.0-dia7
```

## 4. Qué NO se commitea (regla de seguridad)

- **Nunca** las claves del proyecto Supabase (`anon key`, `service_role`,
  URL con tokens): el Día 8 llegan por `--dart-define` y el cierre del Día 8
  verifica el repo.
- **Nunca** el dump completo de la BD con usuarios reales; el seed usa datos
  de prueba del equipo.
- `schema.sql` y `seed.sql` SÍ se commitean: son estructura y datos de
  prueba, la única forma de reconstruir el proyecto si se pierde.

## 5. Checklist final antes del PR

- [ ] El ER (docs/27) y el DDL (db/schema.sql) cuentan la MISMA historia
      (5 tablas, mismas FK).
- [ ] El seed replica los 8 reportes del mock y el test de contrato pasa.
- [ ] `db/consultas.sql` se ejecutó completo en el SQL Editor sin errores.
- [ ] 10 commits convencionales + PR abierto + tag `v0.6.0-dia7` creado.
