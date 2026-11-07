# app/ — App Flutter de CiudadAlerta

Creada con `flutter create` en el **Día 2**, con primera pantalla en el **Día 3**
y **convertida en flujo navegable en el Día 4**: navegación con `go_router`
(HU-02), lista de reportes con datos mock (HU-03), detalle con parámetro de
ruta (HU-04) y formulario validado (HU-05).

## Cómo ejecutarla

```bash
cd app
fvm flutter pub get          # descarga dependencias (go_router, versión fija del curso)
fvm flutter run              # elige el emulador AVD o tu celular por USB
fvm flutter test             # pruebas de widgets y del formulario (6 en total)
fvm flutter analyze          # sin advertencias antes de cada commit
```

- **Flujo del Día 4**: Entrar → shell de 4 pestañas (Inicio · Mapa · Nuevo · Perfil)
  → toca un reporte → detalle `/reporte/RPT-001` → pestaña Nuevo → formulario.
- **Hot reload**: guarda el archivo (`Ctrl+S`) → la pantalla se actualiza sin recompilar.

## Estructura

```
app/
├── lib/
│   ├── main.dart                    ← entrada: MaterialApp.router + routerConfig
│   ├── routing/app_router.dart      ← go_router: rutas, ShellRoute y /reporte/:id
│   ├── data/report.dart             ← modelo Report (fromJson / toJson)
│   ├── data/mock_reports.dart       ← datos simulados + cargarReportes() async
│   ├── theme/app_theme.dart         ← ThemeData del curso (Material 3, semilla #329B67)
│   ├── widgets/custom_button.dart   ← botón reutilizable (hereda el tema)
│   ├── widgets/custom_input.dart    ← campo de texto reutilizable
│   ├── widgets/report_card.dart     ← tarjeta de reporte (la usa la lista HU-03)
│   └── screens/
│       ├── welcome_screen.dart      ← HU-01: bienvenida; Entrar navega a /inicio
│       ├── home_shell.dart          ← HU-02: NavigationBar con 4 pestañas
│       ├── reports_list_screen.dart ← HU-03: ListView.builder + estados de datos
│       ├── report_detail_screen.dart← HU-04: detalle con parámetro de ruta
│       ├── new_report_screen.dart   ← HU-05: Form + TextFormField + validators
│       ├── map_placeholder_screen.dart ← pestaña Mapa (real en Sprint 3, HU-14)
│       └── profile_screen.dart         ← pestaña Perfil (real en Hito 2, HU-08)
├── test/widget_test.dart          ← HU-01→HU-04: flujo de navegación y lista
├── test/form_validation_test.dart ← HU-05: validación del formulario (3 casos)
├── pubspec.yaml                   ← dependencias (go_router ^14.2.0), versión 0.3.0+1
└── analysis_options.yaml          ← reglas de estilo (flutter_lints)
```

## Qué practicar con esta versión

1. **Pestañas (HU-02)**: cambia entre Inicio/Mapa/Nuevo/Perfil; vuelve a Inicio:
   la lista NO se recarga (el `StatefulShellRoute` conserva el estado).
2. **Lista (HU-03)**: observa el indicador de carga (600 ms simulados) y las
   tarjetas con título, categoría y fecha. Busca `ListView.builder` y fíjate
   que solo construye lo visible.
3. **Detalle (HU-04)**: toca un reporte; la ruta cambia a `/reporte/RPT-00x`.
   Ese parámetro `:id` es lo que pedirá la BD en el Hito 2.
4. **Formulario (HU-05)**: envía vacío → 3 mensajes de error; llena bien →
   SnackBar de confirmación. El `GlobalKey<FormState>` y los `validator`
   son la lección del día.
5. **Reto**: rompe a propósito un `validator` (quita el `trim()`) y mira qué
   pasa con "   " (solo espacios). Así se aprende a escribir validadores.

## Regla del curso

El SDK está fijado con FVM: usa siempre `fvm flutter ...` en lugar de `flutter ...`
para que todos los equipos trabajen con la misma versión congelada del semestre.
