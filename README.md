# CiudadAlerta — Proyecto Guía · Aplicaciones Móviles I (SIS-0180)

**Sprint 3 · Día 11 — Sprint Planning 3: concepto de API, REST, JSON y consumo seguro**

CiudadAlerta es la app móvil del Proyecto Guía de la asignatura **Aplicaciones Móviles I**
(Ingeniería de Sistemas · Octavo semestre). Permite a los ciudadanos de **La Paz y El Alto**
reportar problemas urbanos (baches, luminarias, basura, riesgos) con foto, voz y ubicación,
y dar seguimiento transparente al estado de cada reporte.

El docente actúa como **Product Owner** del Proyecto Guía y lo desarrolla en vivo (live coding);
cada equipo, en paralelo, aplica el mismo día lo aprendido en su **proyecto paralelo**.


## Seguridad del Día 9 (Clase 9 · Día 9)

Este snapshot corresponde al **cuarto día del Hito 2**: tema *"Autenticación,
seguridad de datos y recursos nativos"*. La app del Día 8 (CRUD y consultas)
hoy **sabe quién es el ciudadano** y la BD decide qué puede tocar: la evidencia
oficial del día son los **Casos de prueba de seguridad SP-01..SP-12 (lista de
cotejo)**.

| Carpeta / archivo | Qué contiene |
|---|---|
| `app/lib/data/auth_session.dart` | **SessionUser + validadores** (correo, contraseña 8+/mayúscula/número) y `SessionStore` (secure storage vs memoria) |
| `app/lib/data/auth_repository.dart` | Interfaz de auth + **MockAuthRepository** (modo demo con sesión persistente simulada) |
| `app/lib/data/supabase_auth_repository.dart` | **Supabase Auth real**: signUp/signIn/signOut, JWT y traducción de errores amigable |
| `app/lib/providers/auth_provider.dart` | **Sesión como estado global** (`sesionActualProvider`) con Riverpod |
| `app/lib/screens/register_screen.dart` | **Registro HU-08**: política de contraseña pedida dos veces, errores claros |
| `app/lib/screens/welcome_screen.dart` | **Login real + acceso demo** + "Continuar como…" (sesión persistente) |
| `app/lib/screens/profile_screen.dart` | **Perfil con sesión**: nombre, correo, `auth.uid()` y cierre de sesión |
| `app/lib/data/photo_storage.dart` | **HU-11**: rutas `{uid}/{codigo}-{nombre-seguro}.ext`, `validarImagen`, mock/Storage |
| `app/lib/screens/new_report_screen.dart` | **Foto en 3 pasos**: elegir (permisos) → validar → subir tras el INSERT |
| `app/lib/screens/report_detail_screen.dart` | **Miniatura** de la evidencia (select anidado `report_photos(url)`) |
| `db/rls_dia9.sql` | **RLS por usuario** (reports/comments/photos/profiles) + bucket `fotos-reportes` + verificación |
| `app/test/` | Suite de **53 pruebas** (auth 12, foto 9, CRUD 12, borradores 5, widgets 4, contrato 3, alfa 3, formulario 3, stats 2) |
| `docs/35-seguridad-auth-rls.md` | Decisiones: auth, JWT, RLS, Storage y OWASP MASVS básico |
| `docs/36-casos-prueba-seguridad.md` | **Evidencia oficial**: SP-01..SP-12 con consultas de apoyo |
| `docs/37-avance-git-dia9.md` | Guía de commits del Día 9 y etiqueta `v0.8.0-dia9` |
| `docs/38-bitacora-dia9.md` | Bitácora del Día 9 con la prueba cruzada entre equipos |

**Cómo correr la app hoy:**

```bash
fvm flutter run   # modo DEMO: registro local, login y CRUD en memoria

# contra tu proyecto Supabase del Día 7 (claves fuera del repo):
fvm flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU-CLAVE-ANON
```

**Avance del producto**: tag `v0.8.0-dia9` (historial: `v0.0.0-sprint0` →
`v0.1.0-dia2` → `v0.2.0-dia3` → `v0.3.0-dia4` → `v0.4.0-dia5` → `v0.5.0-dia6` →
`v0.6.0-dia7` → `v0.7.0-dia8` → `v0.8.0-dia9`), `fvm flutter analyze` sin
advertencias y `fvm flutter test` en verde (53 pruebas). Evidencia oficial del
día: **Casos de prueba de seguridad (lista de cotejo)**.

### Camino del Sprint 2 (Hito 2)

| Día | Tema | HU |
|---|---|---|
| 6 ✅ | Arquitectura por capas, Riverpod y persistencia local | HU-07 |
| 7 ✅ | Bases de datos: modelado ER, SQL y Supabase | esquema + seed |
| 8 ✅ | CRUD, consultas y presentación de datos | HU-09, HU-10, HU-13 |
| 9 ✅ | Autenticación, seguridad (RLS) y recurso nativo | HU-08, HU-11 |
| 10 ✅ | Distribuciones: APK release y cierre del sprint | HU-12 + Informe 2 |

### Camino del Sprint 3 (Hito 3)

| Día | Tema | HU / API |
|---|---|---|
| 11 ✅ | Sprint Planning 3: API, REST, JSON y consumo seguro | clima Open-Meteo + cuadro de APIs (docs/46) |
| 12 | APIs de Google: Maps Platform, claves y configuración | HU-14 |
| 13 | Geolocalización, Geocoding y rutas | HU-15, HU-20 |
| 14 | Voz y notificaciones (speech, TTS y push) | HU-16, HU-17, HU-19 |
| 15 | Servicios de Amazon (AWS) y cierre del Sprint 3 | HU-18 + Informe 3 |

## APIs del Día 11 (Clase 11 · Día 11)

El Sprint 3 (Hito 3) abre con la **primera API externa consumida por la
app**: el clima de Open-Meteo (pública, sin API key) en la pantalla de
reportes. La pieza sigue la arquitectura por capas: `ApiConfig`
(`lib/data/api/`, claves por `--dart-define`, ninguna en el repo), modelo
`Clima` con `fromJson` centralizado, `WeatherService` con cliente `http`
inyectable, timeout de 8 s y errores HTTP traducidos a mensajes amigables
(200/429/5xx), `climaActualProvider` (Riverpod) y `ClimaCard` con
deterioro elegante (la lista NUNCA se bloquea; reintento al tocar). La
colección Postman de la app y de la API vive en `api/postman_collection.json`;
la evidencia oficial del día es el **Cuadro comparativo de APIs (Matriz 3)**
(`docs/46`) junto al Sprint Backlog 3 (`docs/45`), la guía REST (`docs/47`),
la guía técnica del clima (`docs/48`), el avance git (`docs/49`) y la
bitácora (`docs/50`). Tag del día: `v1.0.0-dia11` (129 commits).

## Distribución del Día 10 (Clase 10 · Día 10)

El Sprint 2 (Hito 2) cierra con el **APK release instalable (HU-12)** y el
**Informe 2** sustentado (`docs/42`, Matriz 2). La identidad de la app quedó
fija: `version: 0.9.0+1` en el pubspec, `applicationId com.ciudadalerta.app`
y `minSdk 23` en `android/app/build.gradle`, ícono adaptativo y splash
nativa generados desde `app/assets/icon/`, y los 3 permisos mínimos en el
AndroidManifest. La firma release usa un keystore **local** (key.properties
y *.jks están en `android/.gitignore`: MASVS — el keystore nunca entra al
repo y se respalda fuera de él). El build verificable vive en
`scripts/build_release.sh` (clean → pub get → analyze → 65 pruebas →
`flutter build apk --release`) y la guía completa en `docs/39`. El cierre
del sprint quedó documentado en el acta del Review 2 (`docs/40`), la
retrospectiva con compromisos (`docs/41`) y la bitácora del refinamiento
del Sprint 3 (`docs/44`). Tag de cierre: `v0.9.0-dia10` (112 commits).

## Cierre del Sprint 1 (referencia · Día 5)

El Hito 1 cerró con el release v0.1 (tag `v0.4.0-dia5`): tema claro/oscuro (HU-06),
pruebas alfa documentadas (`docs/17`), actas de Review y Retrospectiva (`docs/18-19`),
Informe 1 (`docs/20`) y guía de release (`docs/21-22`). Ese incremento es la base
estable sobre la que arranca el Sprint 2.

## Visión del producto

> Para ciudadanos de La Paz y El Alto que necesitan reportar problemas urbanos
> (baches, luminarias, basura, riesgos), **CiudadAlerta** es una app móvil que permite
> crear reportes geolocalizados con foto y voz, a diferencia de los canales actuales
> dispersos, y da seguimiento transparente al estado de cada reporte.

Detalle completo en [`docs/01-product-vision-board.md`](docs/01-product-vision-board.md).

## Stack tecnológico del curso

| Capa | Tecnología |
|---|---|
| Lenguaje | Dart (null safety) |
| Framework multiplataforma | Flutter (versión fija con **FVM**) |
| Navegación | go_router |
| Estado y arquitectura | Riverpod + arquitectura por capas |
| UI | Material 3 |
| Base de datos y backend | Supabase (PostgreSQL + Auth + Storage) |
| APIs externas | Open-Meteo (clima) · Google Maps Platform · AWS (S3, Lambda, Rekognition) |
| Notificaciones y voz | Firebase Cloud Messaging · speech_to_text · flutter_tts |
| Control de versiones y Scrum | GitHub (repositorio + Projects + Actions) |

**Regla del curso:** las versiones de Flutter, Dart y paquetes quedan congeladas al inicio
con FVM y `pubspec.lock`. No ejecutar `flutter upgrade` durante el semestre.

## Metodología de trabajo

- **Scrum (Guía 2020)**: 4 sprints de 5 días de clase (15 h cada uno).
- **Eventos**: Sprint Planning (día 1 de cada sprint), Daily Scrum (inicio de cada clase),
  Sprint Review + Retrospectiva (día 5), Refinamiento (cierre del día 5).
- **Tablero GitHub Projects**: `Backlog → Ready → En curso → En revisión → Hecho`
  (máximo 2 tarjetas "En curso" por persona).
- **Definition of Done**: código en repositorio con PR revisado, app compilando en
  emulador y dispositivo real, criterios de aceptación cumplidos, sin claves en el
  repositorio, evidencia (captura o video) y tarjeta movida a "Hecho".

## Estructura del repositorio

```
ciudadalerta/
├── README.md                  ← este archivo
├── docs/                      ← artefactos del Sprint 0 y bitácoras diarias
│   ├── 01-product-vision-board.md
│   ├── 02-personas.md
│   ├── 03-product-backlog.md  (27 historias de usuario, 118 puntos)
│   ├── 04-definition-of-done.md
│   ├── 05-definition-of-ready.md
│   ├── 06-working-agreement.md
│   ├── 07-convenciones-git.md
│   ├── 08-sprint-planning-1.md
│   ├── 09-matriz-decision-framework.md
│   ├── 10-bitacora-dia2.md
│   ├── 12-avance-git-dia2.md
│   ├── 13-bitacora-dia3.md
│   ├── 14-avance-git-dia3.md
│   ├── 15-bitacora-dia4.md
│   ├── 16-avance-git-dia4.md
│   ├── 17-casos-prueba-alfa.md
│   ├── 18-sprint-review-1.md
│   ├── 19-retrospectiva-1.md
│   ├── 20-informe-1.md
│   ├── 21-avance-git-dia5.md
│   ├── 22-bitacora-dia5.md
│   ├── 23-sprint-planning-2.md
│   ├── 24-arquitectura-capas.md
│   ├── 25-avance-git-dia6.md
│   ├── 26-bitacora-dia6.md
│   ├── 27-modelo-er.md
│   ├── 28-script-sql.md
│   ├── 29-avance-git-dia7.md
│   ├── 30-bitacora-dia7.md
│   ├── 31-conexion-supabase.md
│   ├── 32-demo-crud-consultas.md
│   ├── 33-avance-git-dia8.md
│   ├── 34-bitacora-dia8.md
│   ├── 35-seguridad-auth-rls.md
│   ├── 36-casos-prueba-seguridad.md
│   ├── 37-avance-git-dia9.md
│   ├── 38-bitacora-dia9.md
│   ├── 39-distribucion-apk.md
│   ├── 40-sprint-review-2.md
│   ├── 41-retrospectiva-2.md
│   ├── 42-informe-2.md
│   ├── 43-avance-git-dia10.md
│   ├── 44-bitacora-dia10.md
│   ├── 45-sprint-backlog-3.md
│   ├── 46-cuadro-comparativo-apis.md
│   ├── 47-api-rest-json.md
│   ├── 48-servicio-clima-open-meteo.md
│   ├── 49-avance-git-dia11.md
│   └── 50-bitacora-dia11.md
├── api/                       ← colección Postman de la app y de Open-Meteo (Día 11)
├── db/                        ← SQL de Supabase: schema, seed, consultas (Día 7) y RLS + Storage (Día 9)
├── android/                   ← build.gradle (applicationId + firma), AndroidManifest y key.properties.example (Día 10)
├── scripts/                   ← build_release.sh: build release verificable (Día 10)
├── matriz_decision/           ← plantilla de matriz de decisión (Día 2)
├── wireframes/                ← plantilla de wireframes (Día 2)
└── app/                       ← código Flutter (HU-01..HU-13 + clima del Día 11; APIs del Sprint 3)
```

## Equipo y roles Scrum

| Rol | Responsable | Responsabilidad |
|---|---|---|
| Product Owner (Proyecto Guía) | Docente | Prioriza el Product Backlog y acepta el incremento en el Review. |
| Scrum Master | Rotativo por sprint | Facilita eventos, gestiona impedimentos, cuida el tablero. |
| Developers | Estudiantes | Diseñan, programan, prueban y documentan; todos hacen commits y revisan PR. |

## Cómo contribuir (resumen)

1. Toma una historia del tablero y muévela a **En curso**.
2. Crea una rama: `git switch -c feature/HU-05-formulario-reporte`.
3. Haz commits convencionales: `feat:`, `fix:`, `docs:`, `chore:` (ver
   [`docs/07-convenciones-git.md`](docs/07-convenciones-git.md)).
4. Abre un **Pull Request** y pide revisión a un compañero.
5. Al aprobarse, merge y mueve la tarjeta a **Hecho** con su evidencia.

## Licencia y uso

Material didáctico de la asignatura Aplicaciones Móviles I (SIS-0180). Uso educativo.
No incluir claves ni secretos en este repositorio: se usan variables de entorno
(`--dart-define`) o GitHub Secrets.
