# 37 · Avance Git del Día 9 — CiudadAlerta (Sprint 2)

> Registro de los **19 commits** del Día 9 ("Autenticación, seguridad de
> datos y recursos nativos"). Un commit por pieza: cada uno compila por
> separado y cuenta una historia revisable en el PR. La guía de
> convenciones vive en `docs/07-convenciones-git.md`.

## Estado de partida

- Tag del día anterior: `v0.7.0-dia8` (CRUD, consultas y estadísticas
  contra Supabase; 31 pruebas verdes).
- La autenticación era la promesa pendiente: la bienvenida del Día 4 tenía
  el botón "Crear cuenta" apagado y el INSERT de reportes firmaba con el
  perfil semilla del Día 7.

## Commits del Día 9

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Dependencias de recursos nativos y sesión segura | `app/pubspec.yaml` | `chore: dependencias image_picker, permission_handler y flutter_secure_storage` |
| 2 | Modelo de sesión y validadores (Dart puro) | `app/lib/data/auth_session.dart` | `feat: modelo de sesión y validadores de credenciales (HU-08)` |
| 3 | Repositorio de autenticación demo con sesión persistente | `app/lib/data/auth_repository.dart` | `feat: repositorio de autenticación con modo demo y sesión persistente` |
| 4 | Autenticación real contra Supabase Auth | `app/lib/data/supabase_auth_repository.dart` | `feat: autenticación contra Supabase Auth con JWT del usuario (HU-08)` |
| 5 | Sesión como estado global | `app/lib/providers/auth_provider.dart` | `feat: sesión como estado global con Riverpod` |
| 6 | Registro con política de contraseña + CustomInput con Form | `app/lib/screens/register_screen.dart`, `app/lib/widgets/custom_input.dart` | `feat: pantalla de registro con política de contraseña (HU-08)` |
| 7 | Bienvenida que autentica + acceso demo | `app/lib/screens/welcome_screen.dart` | `feat: inicio de sesión real en la bienvenida con acceso demo (HU-08)` |
| 8 | Perfil con sesión, auth.uid() y cierre | `app/lib/screens/profile_screen.dart` | `feat: perfil con sesión real y cierre de sesión (HU-08)` |
| 9 | Report con fotoUrl + adjuntarFoto en el repositorio | `app/lib/data/report.dart`, `app/lib/data/reports_repository.dart`, `app/lib/data/supabase_reports_repository.dart` | `feat: Report con fotoUrl y adjuntarFoto en el repositorio (HU-11)` |
| 10 | Selector de foto, subida a Storage y miniatura | `app/lib/data/photo_storage.dart`, `app/lib/screens/new_report_screen.dart`, `app/lib/screens/report_detail_screen.dart` | `feat: foto elegida con permisos, subida a Storage y miniatura (HU-11)` |
| 11 | Ruta /registro y mapa del Día 9 | `app/lib/routing/app_router.dart`, `app/lib/main.dart` | `feat: ruta /registro y mapa de rutas del Día 9` |
| 12 | Versión del paquete para el avance del Sprint 2 | `app/pubspec.yaml` | `chore: versión 0.8.0+1 para el avance del Sprint 2` |
| 13 | Suite de pruebas al Día 9 (53 verdes) | `app/test/` (9 archivos) | `test: autenticación, foto y perfil (53 pruebas verdes)` |
| 14 | RLS por usuario + bucket de Storage | `db/rls_dia9.sql` | `docs: políticas RLS por usuario y bucket de Storage (Día 9)` |
| 15 | Decisiones de seguridad | `docs/35-seguridad-auth-rls.md` | `docs: decisiones de seguridad (auth, JWT, RLS, Storage y MASVS)` |
| 16 | Casos de prueba de seguridad (evidencia oficial) | `docs/36-casos-prueba-seguridad.md` | `docs: casos de prueba de seguridad (evidencia oficial del día)` |
| 17 | Guía de commits del día | `docs/37-avance-git-dia9.md` | `docs: guía de commits del día 9` |
| 18 | Bitácora del día | `docs/38-bitacora-dia9.md` | `docs: bitácora del día 9 con la prueba cruzada` |
| 19 | README raíz y de la app | `README.md`, `app/README.md` | `docs: READMEs actualizados con la autenticación y la foto` |

## Flujo Git del día

```bash
git switch dev && git pull origin dev
git switch -c feature/dia9-auth-rls-recursos-nativos
# ... pasos A-G del laboratorio con un commit por pieza ...
git push -u origin feature/dia9-auth-rls-recursos-nativos
# Pull Request hacia dev + revisión por pares (regla del curso)

git tag -a v0.8.0-dia9 -m "Clase 9 (Día 9): autenticación con Supabase
Auth (HU-08) + RLS por usuario (SP-01..SP-12) + foto con permisos y
Storage (HU-11); suite en 53 pruebas verdes"
```

## Verificación del historial

- `git log --oneline v0.7.0-dia8..HEAD` debe listar 19 commits con el
  formato `tipo: descripción` (feat/chore/test/docs).
- `git log -p | grep -i "supabase.co"` NO debe mostrar claves reales ni
  contraseñas de verdad: los casos SP usan cuentas de prueba.
- La suite de pruebas queda en **53 verdes** (`fvm flutter test`).
