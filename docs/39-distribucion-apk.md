# 39 · Guía de distribución y firma del APK — Día 10 (HU-12)

> Del código del emulador al teléfono del ciudadano. Este documento resume
> las decisiones de distribución del Día 10 que el equipo debe poder
> defender: identidad de la app, ícono y splash, permisos, firma con
> keystore, APK vs AAB y el camino de iOS sin Mac. La evidencia oficial del
> día es el **APK instalable** + el **Informe 2** (Matriz 2, 20 pts).

## 1. Identidad de la app

| Pieza | Dónde vive | Valor del Proyecto Guía | Regla |
|---|---|---|---|
| Versión (versionName + versionCode) | `app/pubspec.yaml` → `version: 0.9.0+1` | 0.9.0 + build 1 | Se sube el build number en cada release; nunca se reusa |
| applicationId | `android/app/build.gradle` | `com.ciudadalerta.app` | Es PERMANENTE: cambiarlo = otra app distinta en Play Store |
| minSdk | `android/app/build.gradle` | 23 | `flutter_secure_storage` (Keystore) lo exige desde el Día 9 |
| Ícono | `flutter_launcher_icons` + `app/assets/icon/` | pin 1024px, adaptativo | `dart run flutter_launcher_icons` regenera los mipmaps |
| Splash | `flutter_native_splash` + `assets/icon/splash.png` | color #0F1913 + logo | `dart run flutter_native_splash:create` |

## 2. Modo debug vs modo release

| Aspecto | Debug | Release |
|---|---|---|
| Compilación Dart | JIT (rápida de compilar, lenta de correr) | AOT (lenta de compilar, fluida en el teléfono) |
| Tamaño típico | ~30 MB | ~9 MB (R8 + tree-shaking + shrinkResources) |
| Firma | debug.keystore automático | keystore de upload propio |
| Hot reload | Sí | No |
| `flutter analyze` y tests | Recomendados | OBLIGATORIOS antes del build |

## 3. Firma con keystore (una sola vez por equipo)

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
# Copia android/key.properties.example -> android/key.properties (local)
# y escribe ahí tus contraseñas. El .gitignore del Día 10 excluye:
#   key.properties, *.jks, *.keystore
```

Reglas de seguridad (continuidad del Día 9):

1. El keystore y `key.properties` **nunca** entran al repositorio (MASVS).
2. Se respalda en un lugar seguro (nube personal del equipo, no en el repo):
   **si pierdes el keystore, no puedes actualizar la app publicada**.
3. `git log -p | grep -i "storePassword"` debe dar solo `CAMBIAME_EN_LOCAL`.

## 4. Compilación y verificación

```bash
bash scripts/build_release.sh          # clean -> pub get -> analyze -> test -> build
fvm flutter build apk --release        # APK directo para instalar (HU-12)
fvm flutter build appbundle            # AAB para Google Play (futuro)
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Checklist de instalación en el dispositivo:

- [ ] El ícono en el launcher es el pin de CiudadAlerta (no el de Flutter).
- [ ] La splash nativa aparece al abrir (no pantalla blanca).
- [ ] `Acerca de`/Perfil muestra la versión 0.9.0+1.
- [ ] Login demo + reporte nuevo funcionan SIN cable (datos reales de red).
- [ ] La cámara pide su permiso en el dispositivo real (no en el emulador).

## 5. APK vs AAB

| Criterio | APK | AAB (Android App Bundle) |
|---|---|---|
| Qué es | Instalable directo en el teléfono | Formato de publicación de Play Store |
| Instalación manual (adb/sideload) | Sí | No |
| Play Store | Acepta pero exige cuenta y revisión | Es el formato EXIGIDO por Play |
| Optimización | Un APK para todas las densidades/ABIs | Play genera APKs por dispositivo (split) |
| Firma | Con tu keystore | Firma con Play App Signing además del upload key |

## 6. iOS sin Mac (teoría del día, práctica del Hito 4)

1. iOS exige **macOS con Xcode** y cuenta **Apple Developer** (USD 99/año).
2. Sin Mac: CI en la nube con runner macOS — **Codemagic** (cortesía Flutter)
   o GitHub Actions; TestFlight para distribuir betas a los evaluadores.
3. Equivalencias: bundle id ↔ applicationId; Info.plist ↔ AndroidManifest
   (permisos con textos de uso: "la cámara se usa para la foto del reporte").

## 7. Google Play Console (panorama)

- Cuenta de desarrollador (USD 25, única) → app con el applicationId del
  build.gradle → pista **interna** (hasta 100 testers) → cerrada → producción.
- El sprint del curso llega hasta la pista interna como práctica documentada;
  la publicación real queda fuera del alcance del Hito 2.

## 8. Decisiones registradas

| # | Decisión | Alternativa descartada | Por qué |
|---|---|---|---|
| D1 | APK para el Hito 2 (installación directa en clase) | AAB desde el día 1 | El docente prueba en 20+ teléfonos sin Play Console |
| D2 | Keystore por equipo, fuera del repo | Keystore compartido en el repo | MASVS + perder el keystore = no actualizar la app |
| D3 | minSdk 23 | minSdk 21 | secure_storage exige Keystore (API 23+); cubre >97% de dispositivos |
| D4 | applicationId com.ciudadalerta.app | bo.edu.upev.ciudadalerta | Identidad de producto (no de aula) y shorter; se define UNA vez |
