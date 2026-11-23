# 61 · Avance Git del Día 14 — CiudadAlerta (Sprint 3)

17 commits convencionales desde `v1.2.0-dia13` hasta `v1.3.0-dia14`,
uno por pieza, siguiendo docs/07-convenciones-git.md:

| # | Commit | Qué deja el repo |
|---|--------|------------------|
| 1 | `chore:` dependencias speech_to_text, flutter_tts, local y FCM (HU-16/HU-17/HU-19) | pubspec con las 5 dependencias nuevas |
| 2 | `feat:` permisos RECORD_AUDIO y POST_NOTIFICATIONS en el manifest | declaración mínima con su comentario de contexto |
| 3 | `fix:` contrato heredado - mock acepta las coordenadas que guarda y buscarPorId pasa a Future | interfaz, mock y tests homologados (incidencia del Día 13) |
| 4 | `feat:` servicio de voz con speech_to_text, flutter_tts y lógica pura | `lib/data/voz/voz_service.dart` |
| 5 | `feat:` dictado por voz de la descripción en el formulario (HU-16) | micrófono en el campo + chip de escucha |
| 6 | `feat:` botón Escuchar el reporte con texto a voz (HU-19) | `_BotonEscuchar` en el detalle |
| 7 | `feat:` servicio de notificaciones locales y registro de token FCM (HU-17) | `lib/data/notificaciones/` (aviso + servicio) |
| 8 | `feat:` activar avisos de estado con token FCM y aviso local (HU-17) | `_BotonAvisos` reemplaza el placeholder |
| 9 | `feat:` tabla push_tokens con RLS y trigger de aviso de estado (HU-17) | `db/push_tokens_dia14.sql` |
| 10 | `chore:` gitignore protege google-services.json del repositorio | la configuración de Firebase nunca entra al repo |
| 11 | `chore:` bump de versión 1.3.0+5 | pubspec version |
| 12 | `test:` lógica pura del dictado, locale TTS y avisos de estado (6 pruebas) | `test/voz_test.dart` |
| 13 | `docs:` guía de voz, dictado y texto a voz (docs/59) | permisos, locales y checklist |
| 14 | `docs:` guía de notificaciones, FCM y Edge Function (docs/60) | la ruta completa del push |
| 15 | `docs:` avance git del día 14 (docs/61) | este archivo |
| 16 | `docs:` bitácora del día 14 con la demo de voz y avisos (docs/62) | incidencias y demo |
| 17 | `docs:` READMEs actualizados con la voz y los avisos | README.md + app/README.md |

Verificación del cierre:

- `git log --oneline v1.2.0-dia13..HEAD` -> 17 commits.
- `git rev-list --count HEAD` -> 180.
- `git log -p | grep -cE "AIza[A-Za-z0-9_-]{30,}"` -> 0 (ninguna clave
  real en el historial; los "AIza..." de la documentación son ejemplos).
- `git log -p | grep -ic "google-services"` -> solo la regla del
  .gitignore y las referencias de docs/60: el .json no está en el repo.
- `fvm flutter test` -> 83 pruebas verdes (77 + 6 del Día 14).
