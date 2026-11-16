# 38 · Bitácora del Día 9 — CiudadAlerta (Sprint 2)

> Registro de la sesión del Día 9 ("Autenticación, seguridad de datos y
> recursos nativos") tal como ocurrió: bloque por bloque, con lo que se
> demostró en vivo y las incidencias que hubo que resolver. Esta bitácora
> es el borrador del acta para el Informe 2 (Hito 2 se cierra el Día 10).

## Datos de la sesión

| Campo | Valor |
|---|---|
| Día / Sprint / Hito | 9 · Sprint 2 · Hito 2 |
| Tema (Cronograma) | Autenticación, seguridad de datos y recursos nativos |
| Nivel Bloom / Evento Scrum | Aplicar / Evaluar · Daily Scrum |
| Historias del día | **HU-08** (registro e inicio de sesión, 5 pts) · **HU-11** (foto con Storage, 5 pts) |
| Evidencia oficial | Casos de prueba de seguridad SP-01..SP-12 (docs/36, lista de cotejo) |
| Sprint Backlog | 13 de 31 pts hechos al cerrar el día (HU-07, HU-08, HU-09, HU-10, HU-11, HU-13) |

## Bloques de la sesión (180 min)

- **00–15 · Daily Scrum + quiz de activación**: diferencia
  autenticación/autorización y qué es RLS (quiz 12 preguntas). Los equipos
  reportan: proyecto Supabase del Día 7 listo y script `rls_dia9.sql`
  ejecutado (bloqueo resuelto en el Día 8: 2 equipos).
- **15–60 · Teoría + live coding**: JWT (header.payload.signature demo en
  jwt.io), sesión segura (secure storage vs shared_preferences),
  autenticación vs autorización, RLS refinada (`auth.uid()`), permisos
  nativos con permission_handler y OWASP MASVS básico. Live coding: se
  firma el INSERT con `auth.uid()` y la política del Día 7 acepta la fila.
- **60–120 · Laboratorio HU-08 y HU-11** (pasos A-G de la guía práctica):
  registro y login con Supabase Auth, RLS por usuario, cámara/galería,
  subida a Storage y miniatura en el detalle. Modo demo disponible sin
  credenciales (mock de auth con SessionStore).
- **120–165 · Proyecto paralelo**: cada equipo implementa autenticación +
  un recurso nativo en SU entidad (cámara, galería o ubicación) con RLS.
- **165–180 · Cierre**: **prueba cruzada** — cada equipo intenta editar un
  reporte ajeno desde la app de otro equipo (SP-07). Todos los intentos
  fallaron (RLS correcta); se llenó la lista de cotejo con las capturas.

## Demo del día (secuencia usada en clase)

1. `fvm flutter run` en modo demo: crear cuenta local y cerrar sesión.
2. Con `--dart-define` del proyecto real: registro rosa.test, login,
   INSERT de reporte firmado por auth.uid() (SP-09 OK).
3. Cámara con permiso denegado (SP-10) y subida con foto (SP-11):
   miniatura visible en el detalle y fila nueva en `report_photos`.
4. Prueba cruzada con carlos.test sobre RPT-001 (SP-07): error RLS,
   captura proyectada, título sin cambios verificado por SQL.

## Incidencias y decisiones

| Incidencia | Decisión |
|---|---|
| 3 equipos no tenían cuenta de Supabase Auth habilitada (email confirmation ON) | Se demostró el mensaje "Confirma tu correo…"; para la clase se desactivó la confirmación en el panel (Auth > Providers > Email) |
| Dos equipos preguntaron si guardar el JWT en shared_preferences era válido | No: MASVS-STORAGE-1; se mostró SecureSessionStore vs DraftStore (HU-07) como contraste |
| Un equipo logró "editar" un reporte ajeno (SP-07)… era el suyo: había creado los 8 reportes con su auth.uid() re-ejecutando el seed | Se aclaró que el seed firma con UUIDs fijos del Día 7; se re-ejecutó el SELECT de auditoría de docs/36 |
| Costo de reintentos de Storage (409 duplicado) | `upsert: true` con ruta determinista: misma ruta = reemplazo idempotente |

## Estado al cierre del día

- Suite de pruebas: **53 verdes** (9 archivos: auth 12, foto 9, CRUD 12,
  borradores 5, widgets 4, contrato 3, alfa 3, formulario 3, stats 2).
- Tag del día: `v0.8.0-dia9` (19 commits desde `v0.7.0-dia8`).
- Pendiente para el Día 10 (Hito 2 se cierra): HU-12 (APK release),
  Sprint Review 2, Retrospectiva y **Informe 2** (Matriz 2, 20 pts) —
  las capturas de SP-01..SP-12 ya son anexos del informe.
