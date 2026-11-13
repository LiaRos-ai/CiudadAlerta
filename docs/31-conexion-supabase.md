# 31 · Conexión de la app a la BD — Día 8

> El "por qué" de la conexión del **Día 8** (`lib/data/supabase_config.dart`,
> `lib/data/supabase_reports_repository.dart`, `lib/data/estadistica.dart`).
> El esquema SQL está en `docs/28-script-sql.md`; este documento registra las
> decisiones de la capa de datos que la demo funcional (evidencia oficial del
> día) hace visible.

## 1. El cliente: `supabase_flutter` y las variables de entorno

La app no habla SQL: habla **REST**. El paquete `supabase_flutter` envuelve a
PostgREST (la API que Supabase autogenera por tabla) y expone métodos
`.from('tabla').select/insert/update/delete` que viajan por HTTPS.

| Decisión | Elección del curso | Por qué |
|---|---|---|
| Credenciales | `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` | No hay archivo `.env` que pegarse en un commit: la clave nunca entra al repo (el cierre del día lo verifica con `git log -p`) |
| Paquete | `supabase_flutter ^2.5.0` | Cliente oficial; REST autogenerada sin escribir backend |
| Alternativa descartada | `flutter_dotenv` + `.env` | Válida, pero crea un archivo que es la causa nº 1 de claves filtradas en repos de estudiantes |
| Modo demo | Sin credenciales → `MockReportsRepository` | El laboratorio no se bloquea si el proyecto Supabase falla; el CRUD demo funciona contra memoria |

La clave **anon** es pública por diseño: identifica el proyecto y confía en
RLS para decidir qué filas cruzan. La clave **service_role** jamás va en una
app móvil (semanas 4 del curso lo repasan en seguridad).

## 2. La promesa del Día 6, cumplida

El Día 6 escribió en `reports_repository.dart`: *"en el Día 8
SupabaseReportsRepository implementará la MISMA interfaz y ninguna pantalla
cambiará una línea"*. Hoy se cumple con el provider de implementación:

```dart
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  if (cliente != null) {
    return SupabaseReportsRepository(cliente);   // credenciales presentes
  }
  return MockReportsRepository();                // modo demo
});
```

Las pantallas siguen llamando a `ReportsRepository`. Eso es la **ventaja
práctica de la arquitectura por capas**: el sprint cambia la implementación
y la UI ni se entera. El commit que introduce el cliente no toca ni un
archivo de `screens/`.

## 3. Mapa SQL del Día 7 → API del Día 8

| SQL (db/consultas.sql) | Cliente `supabase_flutter` | HU |
|---|---|---|
| `SELECT ... ORDER BY creado_en DESC` | `.select().order('creado_en', ascending: false)` | HU-09 |
| `WHERE categories.nombre = 'Residuos'` | `.eq('categories.nombre', categoria)` | HU-09 |
| `SELECT *, categories(nombre)` (JOIN) | `.select('*, categories(nombre)')` (select anidado por FK) | HU-09 |
| `INSERT INTO reports ...` | `.insert(map).select().single()` (RETURNING) | HU-10 |
| `UPDATE reports SET ... WHERE codigo = X` | `.update(map).eq('codigo', id)` | HU-10 |
| `DELETE FROM reports WHERE codigo = X` | `.delete().eq('codigo', id)` | HU-10 |
| `GROUP BY categoria + COUNT` | `.select('categories(nombre), estado')` + agrupado en Dart con `agruparPorCategoria()` | HU-13 |

Dos decisiones que se defienden en el informe:

1. **Select anidado, no copia de datos.** El nombre de la categoría llega
   embebido por la FK (`categories(nombre)`): 3FN intacta, nada que
   desincronizar.
2. **El GROUP BY de HU-13 se hace en Dart cuando la API no expone el
   agregado directo.** El módulo `estadistica.dart` replica el LEFT JOIN del
   Día 7: las categorías del catálogo sin reportes cuentan 0, y el desempate
   por orden de catálogo hace el gráfico determinista (probado en
   `crud_demo_test.dart`).

## 4. Identificadores: uuid técnico, código legible

`reports` tiene `id uuid` (PK técnica) y `codigo` RPT-001 (id legible). La
app muestra y navega por `codigo`; el INSERT devuelve ambas (`.select()`
después de `.insert()` es el `RETURNING` de PostgREST). El mapeo
`filaAReporte()` elige `codigo` para `Report.id` y guarda el uuid solo para
operaciones internas.

## 5. Fechas: `timestamptz` en la BD, texto en la app

El Día 7 decidió que el formateo vive en Dart. `fechaLegible()` convierte
`2026-11-03T08:15:00-04:00` → `03/11/2026 08:15` con `DateTime.tryParse` y
relleno de ceros: sin dependencia `intl` todavía (llega en el Hito 4). El
valor nulo o inválido no rompe la UI: cae a `—` (probado).

## 6. AsyncValue y reactividad: los estados que ya escribimos a mano

| Estado | Día 4 (FutureBuilder) | Día 8 (AsyncValue) |
|---|---|---|
| Cargando | `snapshot.connectionState == waiting` | `.when(loading: ...)` |
| Error | `snapshot.hasError` | `.when(error: ...)` + Reintentar con `ref.invalidate` |
| Datos | `snapshot.hasData` | `.when(data: ...)` |
| Vacío | `reportes.isEmpty` | igual, dentro de `data:` |

El filtro de HU-09 es un `StateProvider<String>`: al cambiar el chip, el
`FutureProvider` se re-ejecuta con el nuevo `WHERE`. Tras cada CRUD se
`ref.invalidate` sobre lista y estadísticas: la pantalla de la autoridad
(HU-13) se refresca sola.

## 7. Seguridad aplicada hoy

- Credenciales por `--dart-define`: nada de claves en el repo (cierre del día).
- La política base de RLS (Día 7) sigue vigente: lectura pública, escritura
  solo del dueño. En modo demo el autor es el usuario semilla; el Día 9
  (HU-08) `auth.uid()` lo sustituye.
- El error de escritura (constraint o RLS) llega como excepción del cliente:
  el SnackBar lo muestra sin crashear la app.
