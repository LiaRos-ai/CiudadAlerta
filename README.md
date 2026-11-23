# CiudadAlerta — Proyecto Guía · Aplicaciones Móviles I (SIS-0180)

**Sprint 3 · Día 14 — Voz y notificaciones: reconocimiento de voz, texto a voz y push**

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
| 12 ✅ | APIs de Google: Maps Platform, claves y configuración | HU-14 mapa + claves restringidas (docs/51-52) |
| 13 ✅ | Geolocalización, Geocoding y rutas | HU-15/HU-20 demo en dispositivo (docs/55-56) |
| 14 ✅ | Voz y notificaciones (speech, TTS y push) | HU-16/HU-17/HU-19 demo de voz y avisos (docs/59-60) |
| 15 | Servicios de Amazon (AWS) y cierre del Sprint 3 | HU-18 + Informe 3 |

## Voz y avisos del Día 14 (Clase 14 · Día 14)

El Día 14 le pone **voz y avisos** a la app con las HU-16, HU-17 y
HU-19. El dictado (HU-16) entra al formulario con `speech_to_text` y
el motor del sistema: el permiso `RECORD_AUDIO` se pide **en contexto**
(al tocar el micrófono del campo, nunca al abrir la app) y el texto
aparece EN VIVO con los resultados parciales; sin permiso o sin motor,
el teclado sigue (el dictado mejora el reporte, jamás lo bloquea). El
detalle **escucha** (HU-19): `flutter_tts` lee codigo, título, estado,
zona y descripción con el mejor español instalado y se silencia al
salir — accesibilidad real sobre los Semantics del Día 4. Y el botón
placeholder "Avisarme cuando cambie el estado" se vuelve HU-17: un tap
pide POST_NOTIFICATIONS (Android 13+), UPSERTa el token FCM en
`push_tokens` (RLS por usuario) y muestra el aviso EXACTO que la Edge
Function enviará — el trigger `trg_estado_cambio` deja el cambio en
`avisos_pendientes` y docs/60 documenta la ruta completa (Firebase ->
token -> trigger -> Edge Function con service_role en secretos). Sin
google-services.json el push no existe, pero la app NO crashea: el
aviso LOCAL demuestra el mismo payload (deterioro elegante). El día
dejó además la **incidencia heredada** en la bitácora: la firma del
mock no aceptaba las coordenadas que su cuerpo ya usaba y
`buscarPorId` quedó a medias entre sync (Día 6) y async (Día 8) — el
`fix:` del Día 14 homologa el contrato con los tests actualizados. La
evidencia oficial es la **demo de voz / notificaciones** con la prueba
cruzada entre equipos (docs/59 voz, docs/60 notificaciones, docs/61
avance git y docs/62 bitácora). Tag del día: `v1.3.0-dia14` (180 commits).

## Ubicación del Día 13 (Clase 13 · Día 13)

El Día 13 vuelve el mapa **vivo** con las HU-15 y HU-20. La pieza
mantiene la arquitectura por capas y las reglas del curso: el permiso
se pide **en contexto** (al tocar "Usar mi ubicación", nunca al abrir
la app) y `deniedForever` abre Ajustes sin crash; `geolocator` da UNA
lectura puntual (`high`, `timeLimit` 8 s) y el punto azul
(`myLocationEnabled`) solo se enciende tras conceder; el geocoding
inverso con el **Geocoder del sistema** (sin costo por solicitud)
convierte las coordenadas en **dirección legible** con una **caché por
clave redondeada a 5 decimales** y un contador que MIDE las llamadas
(insumo del Informe 3); el formulario guarda coordenadas y la zona real
en el INSERT (mock y Supabase con los mismos parámetros opcionales); y
la ruta hacia el reporte (HU-20) se abre con **url_launcher** sobre la
URL universal `dir/?api=1` de Google Maps — costo cero — con SnackBar
si no hay app de mapas. El día dejó además la incidencia estrella en la
bitácora: los select explícitos de Supabase no pedían `latitud/longitud`
(con el mock funcionaba) — el `fix:` del Día 13 demuestra por qué la
demo en dispositivo contra la BD real está en la Definition of Done.
La evidencia oficial es la **demo en dispositivo físico** (docs/55 con
permisos y privacidad, docs/56 con geocoding y rutas, docs/57 avance
git y docs/58 bitácora). Tag del día: `v1.2.0-dia13` (163 commits).

## Mapa del Día 12 (Clase 12 · Día 12)

El Día 12 convierte el placeholder del Día 4 en el **mapa real de los
reportes (HU-14)** con Google Maps Platform. La pieza mantiene la
arquitectura por capas: el modelo `Report` gana `latitud`/`longitud`
opcionales (patrón del `fotoUrl` del Día 9), el repositorio Supabase las
mapea con cast tolerante, `db/ubicaciones_dia12.sql` agrega las columnas
y llena los 8 reportes del seed, y `lib/data/mapa/marcadores.dart`
construye el `Set<Marker>` como lógica pura y probada. `MapaScreen` arma
el `GoogleMap` con cámara inicial en La Paz (zoom 12) y aplica el criterio
clave de la HU: la **ventana emergente del marcador navega al detalle**
(`/reporte/:id` con go_router). La clave `MAPS_API_KEY` llega por
`--dart-define`, Gradle la inyecta al AndroidManifest como placeholder y
NUNCA se versiona; sin clave la pestaña muestra su panel de instrucciones
(deterioro elegante). La evidencia oficial es el **Mapa funcional + claves
restringidas** (docs/51 con el paso a paso de la consola y docs/52 con la
guía técnica), junto al avance git (docs/53) y la bitácora (docs/54).
Tag del día: `v1.1.0-dia12` (146 commits).

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
`scripts/build_release.sh` (clean → pub get → analyze → 83 pruebas →
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
| APIs externas | Google Maps Platform (mapa Día 12 · ubicación y rutas Día 13) · Open-Meteo (clima) · Firebase Cloud Messaging (push, Día 14) · AWS (S3, Lambda, Rekognition) |
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
│   ├── 50-bitacora-dia11.md
│   ├── 51-consola-google-cloud.md
│   ├── 52-mapa-google-flutter.md
│   ├── 53-avance-git-dia12.md
│   ├── 54-bitacora-dia12.md
│   ├── 55-permisos-y-ubicacion.md
│   ├── 56-geocoding-y-rutas.md
│   ├── 57-avance-git-dia13.md
│   ├── 58-bitacora-dia13.md
│   ├── 59-voz-y-notificaciones.md
│   ├── 60-notificaciones-push-fcm.md
│   ├── 61-avance-git-dia14.md
│   └── 62-bitacora-dia14.md
├── api/                       ← colección Postman de la app y de Open-Meteo (Día 11)
├── db/                        ← SQL de Supabase: schema, seed, consultas (Día 7), RLS + Storage (Día 9) y ubicaciones (Día 12)
├── android/                   ← build.gradle (applicationId + firma), AndroidManifest y key.properties.example (Día 10)
├── scripts/                   ← build_release.sh: build release verificable (Día 10)
├── matriz_decision/           ← plantilla de matriz de decisión (Día 2)
├── wireframes/                ← plantilla de wireframes (Día 2)
└── app/                       ← código Flutter (HU-01..HU-17 y HU-19-20 + clima, mapa y voz; APIs del Sprint 3)
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
