# 28 · Script SQL de Supabase — Día 7

> El "por qué" del script SQL del **Día 7** (`db/schema.sql`, `db/seed.sql`,
> `db/consultas.sql`). El esquema ER está en `docs/27-modelo-er.md`; este
> documento registra las decisiones de implementación en PostgreSQL.

## 1. DDL: qué es y qué declara nuestro esquema

**DDL (Data Definition Language)** es el SQL que *define la estructura*:
`CREATE TABLE`, `ALTER TABLE`, `CREATE INDEX`. En `db/schema.sql` cada
`CREATE TABLE` fija cuatro cosas que la lista de cotejo verifica:

| Elemento | Ejemplo en `reports` | Por qué |
|---|---|---|
| Tipos correctos | `uuid`, `text`, `smallint`, `boolean`, `timestamptz` | El tipo evita basura: fechas en `timestamptz` permiten `ORDER BY`; `boolean` evita "true"/"si"/"1" |
| Constraints | `not null`, `unique`, `check` (estado, rol, longitud del título) | La BD rechaza un reporte sin título o con estado inventado: la validación de la app (HU-05) y la de la BD se defienden juntas |
| PK y FK | `id uuid primary key`; `categoria_id references categories(id)` | Integridad referencial: no existe reporte con categoría inexistente |
| Índices | `idx_reports_categoria`, `idx_reports_estado`, `idx_reports_creado_en` | Toda FK y toda columna usada en `WHERE`/`ORDER BY` por HU-09 queda indexada |

## 2. DML: qué es y dónde vive en el curso

**DML (Data Manipulation Language)** es el SQL que *maneja filas*:
`INSERT`, `SELECT`, `UPDATE`, `DELETE`.

- El `INSERT` del curso está en `db/seed.sql` (datos semilla idénticos al
  mock de la app).
- Los `SELECT` están en `db/consultas.sql` (C01–C10) y, desde el Día 8, en
  `SupabaseReportsRepository` (la app genera su DML con el cliente
  `supabase_flutter`).
- `UPDATE`/`DELETE` llegan con el CRUD de la HU-10 (Día 8); su versión SQL
  pura se practica en el trabajo autónomo.

## 3. RLS: la puerta de seguridad que se abre hoy y se cierra el Día 9

**Row Level Security** es la política de PostgreSQL que Supabase aplica a
* cada consulta: aunque la API REST sea "pública", sin política no hay fila
  visible ni escribible.

- Hoy (Día 7): se **habilita** RLS en las 5 tablas, se crea la lectura
  pública (la app del Sprint 1 era abierta) y la política base de
  `reports`: **insertar/editar/borrar solo el dueño**
  (`auth.uid() = usuario_id`).
- Día 9 (HU-08/HU-11): se refina con Supabase Auth real (login, roles,
  Storage) y se prueba con casos de seguridad.

```sql
-- extracto de db/schema.sql: escribir solo el dueno
create policy "insertar solo mis reportes" on reports
  for insert with check (auth.uid() = usuario_id);
```

## 4. Supabase: del proyecto a la API REST autogenerada

| Pieza | Qué hace | Dónde se ve |
|---|---|---|
| Proyecto | Instancia PostgreSQL administrada (región cercana, ej. São Paulo) | dashboard.supabase.com |
| SQL Editor | Ejecuta schema/seed/consultas; historial de consultas | Sidebar → SQL Editor |
| Table Editor | Las tablas como hoja editable: verificación visual del DDL | Sidebar → Table Editor |
| API REST autogenerada | Por cada tabla, Supabase expone REST (`GET/POST/PATCH/DELETE /rest/v1/reports`) con PostgREST: **sin escribir backend** | Sidebar → API Docs |
| RLS y policies | Reglas por fila aplicadas a TODAS las entradas (REST incluida) | Database → Policies |

**Regla de seguridad del curso:** el script SQL se commitea (es estructura,
no secreto); las claves del proyecto (`anon key`, `service_role`) **nunca**
van al repositorio —llegan por `--dart-define` el Día 8 (cierre del Día 8:
"¿hay claves en el repositorio?").

## 5. BaaS vs backend propio (y SQL vs NoSQL)

| Criterio | BaaS (Supabase) | Backend propio (Node/Django) |
|---|---|---|
| Tiempo hasta CRUD | Minutos (API autogenerada) | Días (endpoints, despliegue) |
| Autenticación | Incluida (Auth + RLS) | A implementar y auditar |
| Control fino de lógica | Vistas, funciones SQL, triggers | Total, cualquier lógica |
| Costo/operación para el curso | Gratis en tier de estudio | Servidor que mantener |
| Decisión del Hito 2 | ✅ Elegido | Se usa la lógica propia en funciones SQL cuando hace falta |

**SQL vs NoSQL (Firestore) y por qué el curso usa SQL:** los datos de
CiudadAlerta son **relacionales por naturaleza** (reporte–categoría–usuario–
comentarios con integridad referencial) y las consultas del producto son
**agregaciones** (estadísticas HU-13 con `GROUP BY`). PostgreSQL ofrece
JOIN, agregados y RLS; Firestore los "acoplados" hay que emularlos en el
cliente. Además es la misma tecnología que evalúa la Matriz 2.

## 6. Orden de ejecución y verificación

```text
1. db/schema.sql   -> Table Editor muestra las 5 tablas e índices
2. db/seed.sql     -> la consulta final debe devolver 5/4/8/4/3
3. db/consultas.sql-> C01..C10 corren sin error; C06 da 2 reportes por Via,
                     Luminaria y Residuos, y 1 por Riesgo y Agua (total 8)
```
