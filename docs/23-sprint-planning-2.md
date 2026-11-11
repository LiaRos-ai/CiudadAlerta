# 23 · Sprint Planning 2 — CiudadAlerta (Sprint 2 · Hito 2)

> Acta del **Sprint Planning 2** realizado en la Clase 6 (Día 6, 30 min de laboratorio).
> Es la ceremonia que abre el Sprint 2 y su salida — el **Sprint Backlog 2 publicado
> en el tablero** — es la **evidencia oficial del Día 6** según el plan de la asignatura.

## 1. Entradas del planning

| Entrada | Fuente | Estado |
|---|---|---|
| Product Backlog refinado (HU-07 a HU-13 estimadas) | Cierre del Día 5 | ✅ Listo |
| Retrospectiva 1 (2 acciones de mejora) | `docs/19-retrospectiva-1.md` | ✅ Incorporadas |
| Release v0.1 (base estable en `main`) | tag `v0.4.0-dia5` | ✅ Publicado |
| Capacidad del equipo | 5 días × 3 h presenciales + 1.5 h autónomas | ✅ Confirmada |

## 2. Meta del Sprint 2 (Sprint Goal)

> **"App híbrida/multiplataforma con autenticación, CRUD y consultas contra
> PostgreSQL (Supabase), con un recurso nativo y un APK release instalable
> generado con Flutter."**

Es una meta de producto y de proceso a la vez: al cierre del Día 10 la app
ya no vive de datos simulados — consulta, escribe y protege datos reales —
y se instala en un dispositivo real desde un APK release.

## 3. Sprint Backlog 2 (HU-07 a HU-13)

Selección del Product Backlog con Planning Poker (puntos de historia ya
estimados en el refinamiento del Día 5). Total del sprint: **57 puntos**.

| HU | Historia de usuario | Puntos | Día planificado | Criterio de aceptación |
|---|---|---|---|---|
| HU-07 | Guardar borradores locales para no perder lo escrito sin conexión | 6 | Día 6 ✅ | Borrador persiste al cerrar la app (shared_preferences / sqflite) |
| HU-09 | Ver reportes desde la BD con filtro por categoría y orden por fecha | 8 | Día 8 | Consulta con filtros; estados loading/error/empty |
| HU-10 | Crear, editar y eliminar mis reportes (CRUD) | 8 | Día 8 | CRUD completo; RLS impide editar reportes ajenos |
| HU-13 | Ver estadísticas por categoría y estado para priorizar atención | 8 | Día 8 | Consulta agregada (GROUP BY) y gráfico en pantalla |
| HU-08 | Registrarme e iniciar sesión para gestionar mis reportes | 9 | Día 9 | Supabase Auth; sesión persistente; cierre de sesión |
| HU-11 | Adjuntar una foto al reporte para dar evidencia | 9 | Día 9 | Cámara/galería; sube a Storage; muestra miniatura |
| HU-12 | APK instalable para probar la app en dispositivos reales | 10 | Día 10 | APK release con `flutter build apk`; ícono y splash configurados |

Orden de construcción: primero la **arquitectura** (Día 6: capas + Riverpod +
persistencia local), después la **base de datos** (Día 7: modelado y SQL),
luego el **CRUD sobre datos reales** (Día 8), la **seguridad y el recurso
nativo** (Día 9) y el **empaquetado** (Día 10).

## 4. Decisiones técnicas del planning

| Decisión | Alternativa descartada | Motivo |
|---|---|---|
| Arquitectura por capas (UI – providers – repositorio – datos) | Seguir llamando al mock desde la UI | El cambio a Supabase no debe tocar una sola pantalla (Día 8) |
| Riverpod como gestión de estado | Provider / Bloc / setState compartido | `FutureProvider` + `AsyncValue` resuelven loading/error/data declarativamente; es la opción recomendada en la documentación oficial de Flutter para el curso |
| Borradores con `shared_preferences` | `sqflite` / `flutter_secure_storage` | Son 3 campos clave-valor sin consultas ni sensibilidad (ver `docs/24-arquitectura-capas.md`) |
| Bifurcar el repositorio: `MockReportsRepository` hoy, `SupabaseReportsRepository` el Día 8 | Reescribir la pantalla de lista | La interfaz `ReportsRepository` ya es el contrato; el mock se conserva para pruebas |

## 5. Riesgos identificados

1. **Cuentas de Supabase** (Día 7): cada equipo necesita su proyecto propio;
   el plan B es un proyecto compartido del docente con esquemas por equipo.
2. **Conectividad del aula**: los borradores locales (HU-07) justamente
   desacoplan el laboratorio del Día 6 de la red.
3. **Tiempo del Día 10**: la compilación release es lenta; el APK se genera
   al inicio del laboratorio y el Review corre en paralelo.

## 6. Salida y evidencia

- [x] Meta del Sprint 2 redactada y compartida con el equipo.
- [x] HU-07 a HU-13 seleccionadas y ordenadas por día.
- [x] **Sprint Backlog 2 publicado en el tablero** (evidencia oficial del Día 6).
- [x] Decisiones técnicas registradas en `docs/24-arquitectura-capas.md`.
