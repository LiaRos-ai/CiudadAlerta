# app/ — App Flutter de CiudadAlerta

Creada con `flutter create` en el **Día 2**, convertida en flujo navegable en
el **Día 4** (navegación con `go_router` HU-02, lista con datos mock HU-03,
detalle con parámetro de ruta HU-04 y formulario validado HU-05), **cerrada
como entrega del Sprint 1 en el Día 5** (pruebas alfa, tema claro/oscuro HU-06,
release v0.1, tag `v0.4.0-dia5`) y **refactorizada en el Día 6 para arrancar
el Sprint 2**: arquitectura por capas con `ReportsRepository`, estado global
con Riverpod y borradores locales con `shared_preferences` (**HU-07**).

## Cómo ejecutarla

```bash
cd app
fvm flutter pub get          # descarga dependencias (go_router, flutter_riverpod, shared_preferences)
fvm flutter run              # elige el emulador AVD o tu celular por USB
fvm flutter test             # pruebas de widgets, formulario, alfa y borrador (14 en total)
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
  se restaura con un SnackBar. Al enviar con éxito, el borrador se limpia.
- **Pruebas alfa (Día 5)**: recorre los casos de `docs/17-casos-prueba-alfa.md`,
  ejecuta `fvm flutter analyze` (limpio) y `fvm flutter test` (14 pruebas verdes).
- **Hot reload**: guarda el archivo (`Ctrl+S`) → la pantalla se actualiza sin recompilar.

## Estructura

```
app/
├── lib/
│   ├── main.dart                    ← entrada: ProviderScope (Riverpod) + MaterialApp.router
│   ├── routing/app_router.dart      ← go_router: rutas, ShellRoute y /reporte/:id
│   ├── data/report.dart             ← modelo Report (fromJson / toJson)
│   ├── data/mock_reports.dart       ← datos simulados + cargarReportes() async
│   ├── data/reports_repository.dart ← Día 6: interfaz ReportsRepository + MockReportsRepository
│   ├── data/draft_store.dart        ← Día 6 / HU-07: borradores con shared_preferences
│   ├── providers/reports_provider.dart ← Día 6: FutureProvider de reportes (AsyncValue)
│   ├── theme/app_theme.dart         ← tema claro + oscuro HU-06 (Material 3, semilla #329B67)
│   ├── widgets/custom_button.dart   ← botón reutilizable (hereda el tema)
│   ├── widgets/custom_input.dart    ← campo de texto reutilizable
│   ├── widgets/report_card.dart     ← tarjeta de reporte (la usa la lista HU-03)
│   └── screens/
│       ├── welcome_screen.dart      ← HU-01: bienvenida; Entrar navega a /inicio
│       ├── home_shell.dart          ← HU-02: NavigationBar con 4 pestañas
│       ├── reports_list_screen.dart ← HU-03: ListView.builder + estados de datos
│       ├── report_detail_screen.dart← HU-04: detalle con parámetro de ruta
│       ├── new_report_screen.dart   ← HU-05: Form + validators · HU-07: borrador automático
│       ├── map_placeholder_screen.dart ← pestaña Mapa (real en Sprint 3, HU-14)
│       └── profile_screen.dart         ← pestaña Perfil (real en Hito 2, HU-08)
├── test/widget_test.dart          ← HU-01→HU-04: flujo de navegación y lista
├── test/form_validation_test.dart ← HU-05: validación del formulario (3 casos)
├── test/alfa_test.dart            ← Día 5: pruebas alfa (HU-06, conteo HU-03, borde HU-04)
├── test/draft_provider_test.dart  ← Día 6: borrador HU-07 + repositorio + provider (5 pruebas)
├── pubspec.yaml                   ← dependencias (go_router, flutter_riverpod, shared_preferences), versión 0.5.0+1
└── analysis_options.yaml          ← reglas de estilo (flutter_lints)
```

## Qué practicar con esta versión

1. **Arquitectura (Día 6)**: compara `reports_list_screen.dart` con el tag
   `v0.3.0-dia4`: antes la UI llamaba a `cargarReportes()`, hoy pide el estado
   a `reportesProvider`. El repositorio es la única puerta a los datos.
2. **Borrador (HU-07)**: escribe medio reporte, cierra la app del todo y
   reábrelo: aparece "Borrador restaurado de tu última sesión". Envía el
   reporte completo: el borrador se limpia.
3. **Pestañas (HU-02)**: cambia entre Inicio/Mapa/Nuevo/Perfil; vuelve a Inicio:
   la lista NO se recarga (el `StatefulShellRoute` conserva el estado).
4. **Lista (HU-03)**: observa el indicador de carga (600 ms simulados) y las
   tarjetas con título, categoría y fecha. Ahora los 4 estados vienen de
   `AsyncValue.when()` en lugar del `FutureBuilder` del Día 4.
5. **Detalle (HU-04)**: toca un reporte; la ruta cambia a `/reporte/RPT-00x`.
   Ese parámetro `:id` es lo que pedirá la BD en el Día 8.
6. **Formulario (HU-05)**: envía vacío → 3 mensajes de error; llena bien →
   SnackBar de confirmación. El `GlobalKey<FormState>` y los `validator`
   son la lección del día.
7. **Tema oscuro (HU-06)**: activa el modo oscuro del sistema; la app cambia
   sola. Los dos temas viven en `app_theme.dart` con la misma semilla.
8. **Pruebas (Días 5-6)**: `fvm flutter test` deja 14 pruebas verdes; los casos
   manuales de la planilla `docs/17-casos-prueba-alfa.md` y el borrador HU-07
   son la evidencia continua del Hito 2.
9. **Reto**: rompe a propósito la regla de capas — importa `mock_reports.dart`
   en una pantalla y llama a `cargarReportes()` — y discute en el equipo por qué
   eso rompería el cambio a Supabase del Día 8.

## Regla del curso

El SDK está fijado con FVM: usa siempre `fvm flutter ...` en lugar de `flutter ...`
para que todos los equipos trabajen con la misma versión congelada del semestre.
