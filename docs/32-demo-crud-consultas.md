# 32 · Demo funcional de CRUD y consultas — Día 8

> Guion de la **evidencia oficial del Día 8**: "Demo funcional de CRUD y
> consultas (lista de cotejo)". Cada paso tiene un criterio observable que la
> lista de cotejo verifica. La demo se hace en parejas (piloto maneja la app,
> copiloto lleva este guion y anota).

## Reglas de la demo

1. **Modo demo o modo Supabase, el mismo guion.** Sin credenciales la app
   corre con el mock (el CRUD vive en memoria); con
   `--dart-define=SUPABASE_URL / SUPABASE_ANON_KEY` apunta al proyecto del
   Día 7. La demo muestra el MISMO flujo en ambos modos: eso ES la prueba de
   que la arquitectura por capas funciona.
2. **Cada paso termina con su criterio cumplido.** Si un paso falla, la
   sección "errores comunes" de la guía práctica resuelve el 90 % de los
   casos.
3. La demo se graba (video corto o capturas): es el insumo del Informe 2 del
   Día 10.

## Paso 1 · La lista sale de la BD (HU-09) — 5 min

**Qué hacer:** abrir la app con `fvm flutter run` (+ dart-define si hay
proyecto). Pestaña Inicio. Tocar el chip **Residuos**; luego **Todas**;
luego arrastrar hacia abajo (pull-to-refresh).

**Criterio observable:** los chips filtran la lista (Residuos → 2 tarjetas;
Todas → 8 con el seed del Día 7); el pull vuelve a consultar la BD; los
estados de carga y vacío se muestran según corresponda. El orden es por
fecha descendente (`ORDER BY creado_en DESC`).

## Paso 2 · Crear (HU-10, la C de CRUD) — 5 min

**Qué hacer:** pestaña Nuevo. Enviar el formulario vacío (observar los 3
mensajes de validación). Llenar título/descripción/categoría y enviar.

**Criterio observable:** el formulario NO envía si es inválido (HU-05
intacto); al enviar, el botón se bloquea durante el INSERT y el SnackBar
confirma; el nuevo reporte (RPT-009 en demo; un RPT-0XX nuevo en Supabase)
aparece primero en la lista.

## Paso 3 · Leer y editar (HU-10, la R y la U) — 5 min

**Qué hacer:** abrir el reporte recién creado (detalle con WHERE codigo = X).
Tocar el lápiz. Cambiar título y descripción; guardar. Volver a abrirlo.

**Criterio observable:** el detalle consulta puntual por id; el modo edición
precarga los valores; tras guardar, el detalle y la lista muestran el cambio
(sin reiniciar la app): el `ref.invalidate` hizo su trabajo.

## Paso 4 · Eliminar (HU-10, la D) — 5 min

**Qué hacer:** en el detalle del reporte creado, tocar la papelera,
confirmar, y verificar en Supabase Table Editor (o en la lista en demo).

**Criterio observable:** diálogo de confirmación con aviso de CASCADE; tras
eliminar, la lista ya no lo muestra; en Supabase, la fila desapareció y no
quedaron comentarios huérfanos.

## Paso 5 · Estadísticas y gráfico (HU-13) — 5 min

**Qué hacer:** icono de gráfico en la barra de Inicio → pantalla
Estadísticas. Comparar barras con el conteo del Día 7 (C06: 2/2/2/1/1).

**Criterio observable:** las 5 categorías del catálogo están en el eje
(LEFT JOIN: ninguna desaparece); los chips de estado muestran 3/2/2/1
(Recibido/En revisión/En proceso/Resuelto con el seed); tras los CRUD del
paso 2–4 los números son coherentes con la lista actual.

## Paso 6 · Contrato de datos (app ↔ BD) — 5 min

**Qué hacer:** en la terminal del proyecto, `fvm flutter test`. Luego abrir
Supabase Table Editor al lado de la app y comparar.

**Criterio observable:** la suite está en verde (31 pruebas, ver
`docs/33`); los 8 RPT del seed son los mismos que la lista muestra; ninguna
clave aparece en el repo (`git log -p` limpio).

## Cierre: control de seguridad (cierre del día)

Antes de subir el avance final, cada equipo ejecuta y anota en la bitácora:

- [ ] `git log -p | grep -i "supabase.co"` no devuelve claves reales
- [ ] El `--dart-define` no está pegado en ningún script del repo
- [ ] La clave anon usada es la del proyecto propio (no la del docente)
- [ ] Si una clave se filtró: rotar en Settings → API y anotarlo

**Resultado esperado anotado en docs/34 (bitácora):** pasos 1–6 completos +
checklist de seguridad. Con eso queda documentada la evidencia del Día 8.

## Errores comunes durante la demo

| Síntoma | Causa probable | Arreglo rápido |
|---|---|---|
| La lista carga para siempre | `--dart-define` mal escrito (URL sin https) | Revisar el comando de arranque; sin credenciales corre el demo |
| El filtro no cambia nada | Chip no actualiza el StateProvider | Verificar `ref.read(filtroCategoriaProvider.notifier).state` |
| INSERT falla con FK | Categoría escrita a mano y no del catálogo | Usar el dropdown: nombre exacto del seed |
| INSERT falla con RLS | Política del Día 7 exige usuario logueado | Demo usa el perfil semilla; el login real llega el Día 9 |
| El gráfico no refresca tras el CRUD | Falta `ref.invalidate(estadisticas...)` | Revisar el `_enviar()` del formulario y `_eliminar()` del detalle |
| `flutter test` rojo por ProviderScope | Pantalla Consumer montada sin scope | Envolver con `ProviderScope` (así se ajustaron los tests del Día 4) |
