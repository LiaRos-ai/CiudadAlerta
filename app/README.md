# app/ — Primera app Flutter de CiudadAlerta

Carpeta creada en el **Día 2** con `flutter create` (equivalente). Es la app
contador estándar: sirve para verificar la instalación del entorno (Flutter SDK
con FVM, VS Code, Android Studio + emulador) y practicar el hot reload.

## Cómo ejecutarla

```bash
cd app
fvm flutter pub get          # descarga dependencias (versión fija del curso)
fvm flutter run              # elige el emulador AVD o tu celular por USB
```

- **Hot reload**: guarda el archivo (`Ctrl+S`) → la pantalla se actualiza sin recompilar.
- **Hot restart**: `Shift+R` en la terminal → reinicia el estado de la app.

## Estructura

```
app/
├── lib/main.dart            ← código de la app (pantalla contador, StatefulWidget)
├── test/widget_test.dart    ← pruebas de widgets
├── pubspec.yaml             ← dependencias y metadatos (versión 0.1.0+1)
└── analysis_options.yaml    ← reglas de estilo (flutter_lints)
```

## Regla del curso

El SDK está fijado con FVM: usa siempre `fvm flutter ...` en lugar de `flutter ...`
para que todos los equipos trabajen con la misma versión congelada del semestre.
