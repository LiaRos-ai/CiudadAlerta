# 35 · Seguridad del Día 9 — Autenticación, RLS y recursos nativos

> Decisiones técnicas del Día 9 ("Autenticación, seguridad de datos y
> recursos nativos"), Sprint 2 · Hito 2. Complementa `docs/31` (conexión a
> la BD del Día 8) y deja listo el terreno del Hito 4 (HU-24: checklist
> MASVS y secretos fuera del repo).

## 1. Autenticación: qué se eligió y por qué

| Decisión | Elección | Justificación (y qué NO se eligió) |
|---|---|---|
| Proveedor | **Supabase Auth** (email/contraseña) | Ya usamos Supabase como BD: la sesión y el `auth.uid()` quedan integrados con RLS. Un OAuth con Google exige configurar credenciales en cada console (Google Cloud) y queda como práctica del Hito 4. |
| Sesión persistente | **JWT gestionado por supabase_flutter** | El cliente guarda access/refresh token y lo renueva solo. En modo demo, el mismo contrato se simula con `SessionStore` (secure storage). No se guardan JWTs en `shared_preferences` (texto plano). |
| Almacén seguro | **flutter_secure_storage** | Keystore de Android / Keychain de iOS: cifrado gestionado por el SO (MASVS-STORAGE-1). El borrador HU-07 puede vivir en `shared_preferences`; el token NO. |
| Contraseñas | Política del curso: **8+, 1 mayúscula, 1 número** | Validada DOS veces (formulario y repositorio: defensa en profundidad). Supabase Auth permite subir el mínimo a nivel de proyecto. |
| Errores | `AuthError` con mensajes traducidos | "Credenciales inválidas" genérico para login: no se revela si el correo existe (evita enumerar cuentas). Registro sí distingue "correo ya registrado" porque es útil al ciudadano. |
| Autorización | **RLS (Día 7) refinada hoy** | La BD es la ÚLTIMA barrera: aunque la app tuviera un bug, PostgreSQL rechaza la fila ajena. La UI oculta botones (UX) pero la seguridad NO vive en la UI. |

## 2. Flujo de la sesión (lo que la clase ejecuta en vivo)

```text
Registro/Login (app)
   └─> Supabase Auth  ──>  valida credenciales (auth.users)
          └─> devuelve SessionUser + JWT (access ~1h + refresh)
                 └─> supabase_flutter guarda el JWT (secure storage)
                        └─> cada petición REST lleva el JWT en el header
                               └─> PostgreSQL: auth.uid() = dueño de la fila
                                      └─> RLS aplica (docs: db/rls_dia9.sql)
```

- `auth.uid()` es la "llave" que conecta autenticación con autorización:
  las políticas comparan `usuario_id` (FK a `profiles`) contra `auth.uid()`.
- Cierre de sesión: `signOut()` borra el token; las políticas siguen
  protegiendo la BD (sin JWT = solo lectura pública).

## 3. Recursos nativos: cámara, galería y permisos

| Recurso | Plugin | Permiso (manifiesto) | Comportamiento si el ciudadano niega |
|---|---|---|---|
| Cámara | `image_picker` (source: camera) | `Permission.camera.request()` con `permission_handler` | SnackBar claro; la app sigue sin foto (el reporte nunca depende del permiso). |
| Galería | `image_picker` (source: gallery) | En Android 13+ usa el selector del sistema (sin permiso de app); en iOS `PHPicker` | Igual: se envía el reporte sin evidencia. |
| Archivo | Subida a Storage | No pide permiso (viaja por red) | Error de red → el reporte YA quedó guardado; la foto se puede reintentar. |

- La foto viaja en 3 pasos: **elegir → validar (formato/peso) → subir
  después del INSERT**. Si la subida falla, el reporte no se pierde.
- Bucket `fotos-reportes` público de LECTURA, escritura SOLO en la carpeta
  `{auth.uid()}/` del usuario (política de Storage en `db/rls_dia9.sql`).

## 4. OWASP MASVS: qué aplicamos HOY (versión básica del curso)

| Control MASVS | Cómo lo cumple CiudadAlerta | Caso de prueba (docs/36) |
|---|---|---|
| MASVS-STORAGE-1 (credenciales cifradas) | JWT en secure storage; cero claves en el repo (`--dart-define`) | SP-08 |
| MASVS-AUTH-1 (autenticación segura) | Supabase Auth + política de contraseñas + mensajes genéricos | SP-02, SP-04 |
| MASVS-AUTH-2 (autorización por usuario) | RLS `auth.uid() = usuario_id` en reports/comments/photos | SP-05, SP-06, SP-07 |
| MASVS-RESILIENCE-1 (entrada validada) | `validarImagen` (formato/peso) y validadores de formulario | SP-09 |
| MASVS-PLATFORM-1 (permisos mínimos) | Solo `camera`; galería via selector del sistema | SP-10 |

Pendiente del Hito 4 (HU-24): ofuscación/release firmado, claves
restringidas por bundle id y checklist MASVS completo.

## 5. Mapa de archivos nuevos del Día 9

| Archivo | Rol |
|---|---|
| `app/lib/data/auth_session.dart` | `SessionUser`, `AuthError`, validadores y `SessionStore` (secure vs memoria) |
| `app/lib/data/auth_repository.dart` | Interfaz de auth + `MockAuthRepository` (demo) |
| `app/lib/data/supabase_auth_repository.dart` | Implementación real: signUp/signIn/signOut + traducción de errores |
| `app/lib/providers/auth_provider.dart` | Sesion como estado global (`sesionActualProvider`) |
| `app/lib/data/photo_storage.dart` | Rutas deterministas, `validarImagen`, `PhotoRepository` (mock/Storage) |
| `app/lib/screens/register_screen.dart` | Registro HU-08 con política de contraseña |
| `db/rls_dia9.sql` | RLS por usuario (reports/comments/photos/profiles) + bucket + verificación |
| `docs/36-casos-prueba-seguridad.md` | **Evidencia oficial**: SP-01..SP-12 |
