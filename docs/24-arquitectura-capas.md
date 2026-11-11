# 24 · Arquitectura por capas y persistencia local — CiudadAlerta

> Registro de decisión de arquitectura del **Día 6** (Clase 6). Complementa
> `docs/23-sprint-planning-2.md`. Aquí queda el "por qué" de las dos decisiones
> estructurales del Sprint 2: **arquitectura por capas con Riverpod** y la
> **elección de persistencia local** de la HU-07.

## 1. El problema: una app acoplada

Al cierre del Sprint 1 la app funcionaba, pero cada pantalla hablaba
directamente con los datos: `ReportsListScreen` llamaba a `cargarReportes()`
dentro de su propio `build` (FutureBuilder). Eso tiene tres costos que el
Hito 2 va a cobrar:

1. **Cambio de origen = reescribir pantallas.** En el Día 8 el mock pasa a
   Supabase; si la UI conoce la fuente, cada pantalla se edita.
2. **Consultas duplicadas.** La lista (HU-03) y las estadísticas (HU-13)
   quieren los mismos datos; con FutureBuilder cada pantalla consulta por su
   cuenta y no comparten nada.
3. **Estados de datos repetidos a mano.** Cargando/error/vacío se escribían
   con `if (snapshot...)` en cada pantalla; ese código es idéntico siempre.

## 2. La solución: capas con dirección única

```
┌─────────────────────────────────────────────────────────┐
│  UI · lib/screens/ y lib/widgets/                       │
│  Pantallas y componentes. Piden estado, no datos.       │
└──────────────────────┬──────────────────────────────────┘
                       │ ref.watch(reportesProvider)
┌──────────────────────▼──────────────────────────────────┐
│  PROVIDERS · lib/providers/                             │
│  Estado global con Riverpod. Cachea y comparte.         │
└──────────────────────┬──────────────────────────────────┘
                       │ ref.watch(reportsRepositoryProvider)
┌──────────────────────▼──────────────────────────────────┐
│  REPOSITORIO · lib/data/reports_repository.dart         │
│  Contrato abstract class ReportsRepository.             │
│  Única puerta de entrada a los datos (async).           │
└──────────────────────┬──────────────────────────────────┘
                       │ implements
┌──────────────────────▼──────────────────────────────────┐
│  DATOS · MockReportsRepository (hoy)                    │
│         SupabaseReportsRepository (Día 8)               │
└─────────────────────────────────────────────────────────┘
```

**Reglas del curso (se revisan en el PR):**

- La UI **nunca** importa `mock_reports.dart` ni `supabase_flutter`; solo
  providers y modelos.
- Las dependencias apuntan **hacia adentro** (UI → provider → repositorio →
  datos); los datos no conocen la UI.
- El repositorio devuelve `Future`/datos crudos; los mensajes de UI (SNB,
  textos de error) los decide la pantalla.
- Relación con MVVM: las pantallas son la Vista, los providers son el
  ViewModel observable y el repositorio es el Model.

## 3. Por qué Riverpod

| Criterio | setState | Riverpod (elegido) |
|---|---|---|
| Alcance | Local al StatefulWidget | Global, accesible desde cualquier pantalla |
| Compartir datos entre pantallas | No (hay que bajar por constructor) | Sí: un provider, muchas pantallas |
| Estados async | A mano (FutureBuilder) | `AsyncValue.when(loading/error/data)` declarativo |
| Cache de la consulta | No; cada rebuild puede re-consultar | El provider ejecuta el Future una vez |
| Pruebas | Difícil acoplar datos falsos | `ProviderContainer` + overrides |

Puntos de entrada usados en el Día 6: `ProviderScope` (raíz en `main.dart`),
`Provider<T>` (repositorio) y `FutureProvider<T>` (lista de reportes).
Los Day 8 añadirán `AsyncValue` con filtros y el Día 9, `StateNotifier`
para la sesión de autenticación.

## 4. Elección de persistencia local (HU-07)

| Opción | Qué guarda | Cuándo usarla en el curso | HU-07 |
|---|---|---|---|
| `shared_preferences` | Clave-valor simple (bool, int, String, List\<String\>) | Preferencias del usuario, flags, **borradores de 3 campos** | ✅ Elegida |
| `flutter_secure_storage` | Clave-valor cifrada en el keychain/keystore | Tokens y secretos: el **JWT de Supabase Auth** (Día 9) | ❌ Sobre-ingeniería para un borrador |
| `sqflite` | SQLite embebido: tablas, consultas SQL, migraciones | Cache consultable de reportes, listas grandes con WHERE/ORDER (Día 8) | ❌ No hay consultas sobre el borrador |

El borrador de reporte son tres textos sueltos que se leen y escriben
completos: no hay filtro, ni orden, ni relación con otras entidades.
`shared_preferences` resuelve exactamente eso con el costo más bajo.
La decisión se revisará si el borrador crece (p. ej. guardar ubicación y
varias fotos del borrador: ahí entraría `sqflite`).

## 5. Impacto en las pruebas

- `SharedPreferences.setMockInitialValues({})` permite probar el borrador
  sin dispositivo (`test/draft_provider_test.dart`).
- El `MockReportsRepository` es una implementación real de la interfaz:
  las pruebas del provider corren sin red y sin Supabase.
- En el Día 8 las pruebas del repositorio Supabase usarán la MISMA suite
  con overrides del provider: el refactor de hoy es el que lo hace posible.

## 6. Consecuencias y deudas técnicas

- ✅ El cambio a Supabase (Día 8) toca **una línea** (`reportsRepositoryProvider`).
- ✅ Los 4 estados de la lista siguen intactos (criterio HU-03/09).
- ⚠️ Deuda registrada: el guardado del borrador corre en cada tecla; en un
  proyecto de producción se aplicaría debounce (~300 ms). Se documenta en
  el cheatsheet y se acepta por simplicidad didáctica.
- ⚠️ El provider de reportes aún no soporta filtros (HU-09 los pedirá el
  Día 8 con `StateNotifier` o `family`).
