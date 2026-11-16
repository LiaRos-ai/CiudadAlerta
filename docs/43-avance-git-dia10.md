# 43 · Avance Git del Día 10 — CiudadAlerta (Sprint 2)

> Registro de los **17 commits** del Día 10 ("Distribuciones por
> plataforma (Android / iOS) y cierre del Sprint 2"). Un commit por pieza:
> cada uno compila por separado y cuenta una historia revisable en el PR.
> La guía de convenciones vive en `docs/07-convenciones-git.md`.

## Estado de partida

- Tag del día anterior: `v0.8.0-dia9` (auth + RLS por usuario + foto con
  Storage; 53 pruebas verdes).
- La distribución era el eslabón faltante: la app corría solo desde
  `flutter run`, con el ícono y la splash por defecto de Flutter y sin
  firma release.

## Commits del Día 10

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Dependencias de íconos y splash | `app/pubspec.yaml` | `chore: dependencias flutter_launcher_icons y flutter_native_splash` |
| 2 | Ícono adaptativo del pin 1024px (HU-12) | `app/assets/icon/`, `app/pubspec.yaml` | `feat: ícono adaptativo de la app generado desde el pin (HU-12)` |
| 3 | Splash nativa con marca y color del tema (HU-12) | `app/assets/icon/splash.png`, `app/pubspec.yaml` | `feat: splash nativa con la marca y color del tema (HU-12)` |
| 4 | applicationId y firma release en build.gradle | `android/app/build.gradle` | `feat: applicationId com.ciudadalerta.app y firma release en build.gradle` |
| 5 | Permisos mínimos en AndroidManifest | `android/app/src/main/AndroidManifest.xml` | `feat: permisos mínimos en AndroidManifest para cámara, galería e internet` |
| 6 | key.properties.example y gitignore del keystore (MASVS) | `android/key.properties.example`, `android/.gitignore` | `chore: key.properties.example y gitignore del keystore (MASVS)` |
| 7 | Configuración de release como código (HU-12) | `app/lib/release/release_config.dart` | `feat: configuración de release como código (ReleaseConfig, HU-12)` |
| 8 | Script del build release verificable (HU-12) | `scripts/build_release.sh` | `feat: script del build release con análisis y verificación (HU-12)` |
| 9 | Versión del paquete para el cierre del Sprint 2 | `app/pubspec.yaml` | `chore: versión 0.9.0+1 para el cierre del Sprint 2` |
| 10 | Suite de pruebas al Día 10 (59 verdes) | `app/test/` (10 archivos) | `test: configuración de release y distribución (59 pruebas verdes)` |
| 11 | Guía de distribución y firma del APK | `docs/39-distribucion-apk.md` | `docs: guía de distribución y firma del APK (Día 10)` |
| 12 | Acta del Sprint Review 2 | `docs/40-sprint-review-2.md` | `docs: acta del Sprint Review 2 con las observaciones` |
| 13 | Retrospectiva del Sprint 2 | `docs/41-retrospectiva-2.md` | `docs: retrospectiva del Sprint 2 con compromisos` |
| 14 | Informe 2 del Hito 2 (evidencia oficial) | `docs/42-informe-2.md` | `docs: Informe 2 del Hito 2 (evidencia oficial)` |
| 15 | Guía de commits del día | `docs/43-avance-git-dia10.md` | `docs: guía de commits del día 10` |
| 16 | Bitácora del día | `docs/44-bitacora-dia10.md` | `docs: bitácora del día 10 con el refinamiento del Sprint 3` |
| 17 | README raíz y de la app | `README.md`, `app/README.md` | `docs: READMEs actualizados con el APK y el cierre del Sprint 2` |

## Flujo Git del día

```bash
git switch dev && git pull origin dev
git switch -c feature/dia10-distribucion-apk
# ... pasos A-G del laboratorio con un commit por pieza ...
git push -u origin feature/dia10-distribucion-apk
# Pull Request hacia dev + revisión por pares (regla del curso)

git tag -a v0.9.0-dia10 -m "Clase 10 (Día 10): APK release firmado e
instalable (HU-12) con ícono y splash propios + Sprint Review 2 y
Retrospectiva del Sprint 2 + Informe 2 del Hito 2; suite en 59 pruebas
verdes"
```

## Verificación del historial

- `git log --oneline v0.8.0-dia9..HEAD` debe listar 17 commits con el
  formato `tipo: descripción` (feat/chore/test/docs).
- `git log -p | grep -iE "storePassword|keyPassword"` solo muestra
  `CAMBIAME_EN_LOCAL` y comentarios: el keystore y key.properties NO
  entran al repo (android/.gitignore).
- La suite de pruebas queda en **59 verdes** (`fvm flutter test`).
- El APK del día NO se versiona: `build/` está en .gitignore del curso;
  la evidencia es la captura de la instalación y el sha256 en la bitácora.
