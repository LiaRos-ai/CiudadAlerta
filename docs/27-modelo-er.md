# 27 · Modelo entidad-relación de CiudadAlerta — Día 7

> Modelo ER del **Día 7** (Clase 7): la evidencia oficial del día es el
> **Esquema ER + script SQL**. Este documento es la mitad "esquema"; la mitad
> "script" vive en `db/schema.sql`, `db/seed.sql` y `db/consultas.sql`.
> Antes de tocar Supabase el equipo dibuja este modelo y lo revisa con el
> checklist de normalización (revisión por pares del cierre).

## 1. De las 5 categorías de texto a 5 tablas

Hasta el Día 6 la app vivía de dos constantes Dart (`categoriasCiudadAlerta`
y `estadosCiudadAlerta`) y de 8 reportes en memoria. El Hito 2 convierte ese
universo en un **modelo relacional en PostgreSQL (Supabase)**:

- Las **entidades** son las "cosas" que la app guarda y consulta: usuarios,
  categorías, reportes, comentarios y fotos.
- Las **relaciones** son cómo se conectan: un reporte **pertenece a** una
  categoría y **lo escribió** un usuario; un reporte **recibe** comentarios y
  fotos (1 a N).
- La regla del curso: **cada entidad = una tabla; cada relación = una
  clave foránea (FK)**.

## 2. Diagrama ER (notación crow's foot simplificada)

```text
┌──────────────┐        ┌──────────────┐
│   profiles   │        │  categories  │
├──────────────┤        ├──────────────┤
│ PK id (uuid) │        │ PK id (1..5) │
│    nombre_   │        │    nombre    │
│      completo│        │  descripcion │
│    rol       │        │    activa    │
│    zona      │        └──────┬───────┘
│    creado_en │               │ 1
└──────┬───────┘               │
       │ 1                N    │
       └────────────►┌─────────▼────┐
                     │   reports    │
                     ├──────────────┤
                     │ PK id (uuid) │
                     │    codigo    │  RPT-001..008 (id legible)
                     │    titulo    │
              1      │ FK categoria │────────► categories.id
  profiles.id ◄──────│ FK usuario_id│
                     │  descripcion │
                     │  estado      │  Recibido|En revision|En proceso|Resuelto
                     │  zona        │
                     │  urgente     │
                     │  creado_en   │
                     └──┬────────┬──┘
                  1  /  │        │  \  1
        ┌───────────────▼─┐    ┌─▼──────────────────┐
        │    comments     │    │   report_photos    │
        ├─────────────────┤    ├────────────────────┤
        │ PK id           │    │ PK id              │
        │ FK reporte_id   │    │ FK reporte_id      │
        │ FK usuario_id   │    │  url (Storage)     │
        │  cuerpo         │    │  es_principal      │
        │  creado_en      │    │  creado_en         │
        └─────────────────┘    └────────────────────┘
```

## 3. Entidades y atributos (tabla resumen)

| Tabla | Propósito | PK | FK | Atributos clave | Relaciones |
|---|---|---|---|---|---|
| `profiles` | Perfil del usuario ciudadano/moderador | `id uuid` (= `auth.users.id`) | — | nombre_completo, rol, zona | 1:1 con Supabase Auth; 1:N con reports y comments |
| `categories` | Catálogo cerrado de 5 categorías | `id smallint` (1..5) | — | nombre (único), descripcion, activa | 1:N con reports |
| `reports` | Entidad central: reporte ciudadano | `id uuid` (+ `codigo` único) | `categoria_id`, `usuario_id` | titulo, descripcion, estado, zona, urgente, creado_en | N:1 con categories y profiles; 1:N con comments y report_photos |
| `comments` | Seguimiento del reporte | `id uuid` | `reporte_id`, `usuario_id` | cuerpo, creado_en | N:1 con reports |
| `report_photos` | Evidencia fotográfica (HU-11) | `id uuid` | `reporte_id` | url (Storage), es_principal | N:1 con reports |

**Decisiones de diseño discutidas en clase:**

1. **`categories` como tabla y no como texto libre** en `reports`: permite
   renombrar/desactivar una categoría en un solo lugar, garantiza valores
   válidos por FK y hace el `GROUP BY` de HU-13 directo.
2. **`codigo` (RPT-001) además de `id` (uuid)**: el uuid es la PK técnica que
   nunca se muestra; el código es el identificador legible que la app ya
   muestra desde el Día 4. Convivir es normal en sistemas reales.
3. **`creado_en` timestamptz en lugar del texto `fecha` del mock**: con fecha
   real la BD puede hacer `ORDER BY` y `INTERVAL '7 days'`; el formateo para
   mostrar se hace en la app (Dart), no en la BD.
4. **`on delete cascade` en comments y report_photos**: si un reporte se
   borra, sus comentarios y fotos no pueden quedar huérfanos.

## 4. Normalización aplicada: 1FN → 2FN → 3FN

| Forma normal | Regla | En CiudadAlerta |
|---|---|---|
| 1FN | Valores atómicos: una celda, un valor; sin listas dentro de celdas | `categoria` NO es "Via, Riesgo"; hay una fila por reporte y una FK a categories. Las fotos van en tabla propia, no en un array de URLs |
| 2FN | 1FN + ninguna columna depende de SOLO una parte de la PK compuesta | Todas las PK son de una sola columna (uuid/smallint): la 2FN se cumple de fábrica |
| 3FN | 2FN + ninguna columna depende de otra columna no clave | El nombre de la categoría NO se copia en `reports` (se consultará por JOIN). Si se copiara, renombrar "Residuos" exigiría actualizar N filas |

**Violación típica detectada en la revisión por pares:** guardar
`categoria_nombre` junto a `categoria_id` en `reports`. Es redundancia de
3FN rota: dos columnas que dicen lo mismo y acabarán desincronizadas.

## 5. Contrato app ↔ base de datos

El seed (`db/seed.sql`) replica EXACTAMENTE los 8 reportes del mock
(`app/lib/data/mock_reports.dart`): mismos códigos RPT-001..RPT-008, mismos
títulos, zonas, estados y urgencia, y las mismas 5 categorías. El test
`app/test/data_contract_test.dart` verifica ese contrato: si mañana alguien
cambia una categoría en la app y no en la BD (o al revés), la prueba lo
detecta antes que el usuario.

## 6. Salida del día

- [x] Diagrama ER con las 5 entidades y sus relaciones (este documento).
- [x] Tabla resumen de entidades, PK/FK y cardinalidades.
- [x] Normalización 1FN/2FN/3FN verificada con el checklist de la clase.
- [x] Script SQL en `db/schema.sql` coherente con este modelo.
