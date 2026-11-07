# app/ — App Flutter de CiudadAlerta

Creada con `flutter create` en el **Día 2** y **transformada en el Día 3** en la
primera versión real de CiudadAlerta: pantalla de bienvenida e inicio de sesión
(HU-01, solo UI), tema propio con `ThemeData` y Material 3, y la librería de
widgets reutilizables que usarán todas las pantallas del sprint.

## Cómo ejecutarla

```bash
cd app
fvm flutter pub get          # descarga dependencias (versión fija del curso)
fvm flutter run              # elige el emulador AVD o tu celular por USB
fvm flutter test             # pruebas de widgets (HU-01)
fvm flutter analyze          # sin advertencias antes de cada commit
```

- **Hot reload**: guarda el archivo (`Ctrl+S`) → la pantalla se actualiza sin recompilar,
  conservando el estado (pruébalo con la contraseña visible).
- **Hot restart**: `Shift+R` en la terminal → reinicia el estado de la app.

## Estructura

```
app/
├── lib/
│   ├── main.dart                 ← entrada: MaterialApp + tema + WelcomeScreen
│   ├── theme/app_theme.dart      ← ThemeData del curso (Material 3, semilla #329B67)
│   ├── widgets/custom_button.dart  ← botón reutilizable (hereda el tema)
│   ├── widgets/custom_input.dart   ← campo de texto reutilizable
│   ├── widgets/report_card.dart    ← tarjeta de reporte (primer StatelessWidget con datos)
│   └── screens/welcome_screen.dart ← HU-01: bienvenida y login solo UI (setState)
├── test/widget_test.dart    ← prueba de widgets de la HU-01
├── pubspec.yaml             ← dependencias y metadatos (versión 0.2.0+1)
└── analysis_options.yaml    ← reglas de estilo (flutter_lints)
```

## Qué practicar con esta versión

1. Toca **Mostrar/Ocultar contraseña**: es el `setState` del Día 3 (estado local).
2. Rota el emulador: la HU-01 no debe romper el layout en 2 tamaños de pantalla
   (`SingleChildScrollView` + `ConstrainedBox(maxWidth: 420)`).
3. Cambia el `seedColor` de `app_theme.dart`, guarda y observa el hot reload:
   el estilo vive en `ThemeData`, no en cada widget.

## Regla del curso

El SDK está fijado con FVM: usa siempre `fvm flutter ...` en lugar de `flutter ...`
para que todos los equipos trabajen con la misma versión congelada del semestre.
