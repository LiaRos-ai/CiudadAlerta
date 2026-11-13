# app/ — App Flutter de CiudadAlerta

Creada con `flutter create` en el **Día 2**, convertida en flujo navegable en
el **Día 4** (navegación con `go_router` HU-02, lista con datos mock HU-03,
detalle con parámetro de ruta HU-04 y formulario validado HU-05), **cerrada
como entrega del Sprint 1 en el Día 5** (pruebas alfa, tema claro/oscuro HU-06,
release v0.1, tag `v0.4.0-dia5`), **refactorizada en el Día 6 para arrancar
el Sprint 2** (arquitectura por capas con `ReportsRepository`, estado global
con Riverpod y borradores locales con `shared_preferences`, **HU-07**),
**conectada a su modelo de datos en el Día 7** (esquema ER y script SQL en
`../db/` con test de contrato) y **conectada a la base de datos en el Día 8**:
CRUD y consultas contra Supabase (HU-09, HU-10, HU-13) con **modo demo**
(sin credenciales corre con el mock) y estadísticas con gráfico `fl_chart`.

## Cómo ejecutarla

```bash
cd app
fvm flutter pub get          # descarga dependencias (go_router, flutter_riverpod, shared_preferences, supabase_flutter, fl_chart)
fvm flutter run              # MODO DEMO: elige el emulador AVD o tu celular por USB (CRUD en memoria)

# Contra tu proyecto Supabase del Día 7 (las claves NUNCA en el repo):
fvm flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU-CLAVE-ANON

fvm flutter test             # suite completa: 31 pruebas verdes
fvm flutter analyze          # sin advertencias antes de cada commit
```

- **Flujo del Sprint 1**: Entrar → shell de 4 pestañas (Inicio · Mapa · Nuevo · Perfil)
  → toca un reporte → detalle `/reporte/RPT-001` → pestaña Nuevo → formulario.
- **HU-06 (Día 5)**: cambia el modo oscuro del emulador (Ajustes → Pantalla →
  Tema oscuro); la app lo respeta sin tocar código (`themeMode: ThemeMode.system`).
- **Arquitectura (Día 6)**: la lista ya no llama al mock — pide `reportesProvider`
  con `ref.watch(...).when(...)`. Compara con el tag `v0.3.0-dia4` para ver el
  antes y después del refactor (regla: UI → providers → repositorio → datos).
- **HU-07 (Día 6)**: escribe medio reporte, CIERRA la app y reábrelo: el borrador
  se restaura con un SnackBar. Al enviar con éxito, el borrador se limpia
  (solo en modo crear; la edición no toca borradores).
- **Base de datos (Día 7)**: `../db/schema.sql`, `../db/seed.sql` y
  `../db/consultas.sql` son el esquema ER hecho código; `test/data_contract_test.dart`
  verifica que la app (categorías, estados, RPT-001..008) y el seed coincidan.
- **CRUD y consultas (Día 8)**: la lista sale de la BD con chips de filtro por
  categoría (HU-09); el formulario guarda con INSERT y el detalle permite
  editar y eliminar (HU-10, con CASCADE en comentarios/fotos); el icono de
  gráfico abre `/estadisticas` con las barras de HU-13 (GROUP BY). Sin
  credenciales el mismo flujo corre contra el mock (modo demo).
- **Pruebas alfa (Día 5)**: recorre los casos de `docs/17-casos-prueba-alfa.md`,
  ejecuta `fvm flutter analyze` (limpio) y `fvm flutter test` (31 pruebas verdes).
- **Hot reload**: guarda el archivo (`Ctrl+S`) → la pantalla se actualiza sin recompilar.

## Estructura

```
app/
├── lib/
│   ├── main.dart                    ← entrada: ProviderScope (Riverpod) + MaterialApp.router
│   ├── routing/app_router.dart      ← go_router: rutas + /reporte/:id + /editar/:id + /estadisticas
│   ├── data/report.dart             ← modelo Report (fromJson / toJson)
│   ├── data/mock_reports.dart       ← datos simulados (modo demo del Día 8)
│   ├── data/reports_repository.dart ← interfaz + mock con CRUD demo + provider de implementación
│   ├── data/supabase_config.dart    ← Día 8: cliente Supabase + --dart-define (claves fuera del repo)
│   ├── data/supabase_reports_repository.dart ← Día 8: CRUD y consultas (HU-09, HU-10, HU-13)
│   ├── data/estadistica.dart        ← Día 8: agregados GROUP BY deterministas (HU-13)
│   ├── data/draft_store.dart        ← Día 6 / HU-07: borradores con shared_preferences
│   ├── providers/reports_provider.dart ← filtro, lista, detalle y estadísticas (AsyncValue)
│   ├── theme/app_theme.dart         ← tema claro + oscuro HU-06 (Material 3, semilla #329B67)
│   ├── widgets/custom_button.dart   ← botón reutilizable (hereda el tema)
│   ├── widgets/custom_input.dart    ← campo de texto reutilizable
│   ├── widgets/report_card.dart     ← tarjeta de reporte (la usa la lista HU-03)
│   └── screens/
│       ├── welcome_screen.dart      ← HU-01: bienvenida; Entrar navega a /inicio
│       ├── home_shell.dart          ← HU-02: NavigationBar con 4 pestañas
│       ├── reports_list_screen.dart ← HU-03/HU-09: lista + chips de filtro + pull-to-refresh
│       ├── report_detail_screen.dart← HU-04/HU-10: detalle + editar + eliminar
│       ├── new_report_screen.dart   ← HU-05/HU-10: crear (INSERT) y editar (UPDATE) con borrador HU-07
│       ├── stats_screen.dart        ← Día 8 / HU-13: estadísticas GROUP BY + BarChart (fl_chart)
│       ├── map_placeholder_screen.dart ← pestaña Mapa (real en Sprint 3, HU-14)
│       └── profile_screen.dart         ← pestaña Perfil (real con Auth, Día 9 HU-08)
├── test/widget_test.dart          ← HU-01→HU-04: flujo de navegación y lista
├── test/form_validation_test.dart ← HU-05: validación (3 casos, envío async Día 8)
├── test/alfa_test.dart            ← Día 5: alfa (HU-06, conteo HU-03, borde HU-04)
├── test/draft_provider_test.dart  ← Día 6: borrador HU-07 + repositorio + provider (5 pruebas)
├── test/data_contract_test.dart   ← Día 7: contrato app ↔ BD (categorías, estados, RPT)
├── test/crud_demo_test.dart       ← Día 8: CRUD demo, filtro, agregados y mapeo JSON (12 pruebas)
├── test/stats_screen_test.dart    ← Día 8: gráfico y conteos de HU-13 (2 pruebas)
├── pubspec.yaml                   ← dependencias (+ supabase_flutter, fl_chart), versión 0.7.0+1
└── analysis_options.yaml          ← reglas de estilo (flutter_lints)
```

## Qué practicar con esta versión

1. **Conexión (Día 8)**: corre primero SIN credenciales (modo demo: el CRUD
   vive en memoria) y luego con `--dart-define` apuntando a tu proyecto del
   Día 7. El código de las pantallas es el mismo: eso prueba la arquitectura.
2. **Filtro (HU-09)**: toca los chips de categoría; el StateProvider cambia y
   el provider re-ejecuta la consulta (el WHERE del Día 7, vía REST).
3. **CRUD (HU-10)**: crea un reporte (INSERT con validación HU-05), ábrelo,
   edítalo (UPDATE) y elimínalo con confirmación (DELETE + CASCADE).
4. **Estadísticas (HU-13)**: icono de gráfico en Inicio; las barras muestran
   el GROUP BY por categoría (2/2/2/1/1 con el seed) y los chips los 4
   estados (3/2/2/1). Tras cada CRUD los números se actualizan solos.
5. **Borrador (HU-07)**: escribe medio reporte, cierra la app del todo y
   reábrelo: aparece "Borrador restaurado de tu última sesión". Envía el
   reporte completo: el borrador se limpia.
6. **Pestañas (HU-02)**: cambia entre Inicio/Mapa/Nuevo/Perfil; vuelve a Inicio:
   la lista NO se recarga (el `StatefulShellRoute` conserva el estado).
7. **Detalle (HU-04)**: toca un reporte; la ruta cambia a `/reporte/RPT-00x`
   y hoy la consulta puntual es el `WHERE codigo = X` del Día 7.
8. **Formulario (HU-05)**: envía vacío → 3 mensajes de error; llena bien →
   INSERT con botón bloqueado y SnackBar de confirmación.
9. **Tema oscuro (HU-06)**: activa el modo oscuro del sistema; la app cambia
   sola. Los dos temas viven en `app_theme.dart` con la misma semilla.
10. **Pruebas (Días 5-8)**: `fvm flutter test` deja 31 pruebas verdes; el
   contrato app-BD y la demo de `docs/32` son la evidencia continua del Hito 2.
11. **Reto**: intenta pegar la clave anon directamente en `main.dart` y luego
   ejecuta `git log -p` en el cierre del día: el control de seguridad debe
   demostrar por qué eso está prohibido (rotar claves y usar `--dart-define`).

## Regla del curso

El SDK está fijado con FVM: usa siempre `fvm flutter ...` en lugar de `flutter ...`
para que todos los equipos trabajen con la misma versión congelada del semestre.
