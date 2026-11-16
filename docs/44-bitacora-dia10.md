# 44 · Bitácora del Día 10 — CiudadAlerta (cierre del Sprint 2)

> Registro operativo de la sesión de 180 minutos. Lo escriben piloto y
> copiloto de la pareja del día; lo firma el Scrum Master.

## Daily Scrum + prueba individual (00-15)

- Ayer: casos SP-01..SP-12 ejecutados y capturados; tag `v0.8.0-dia9` empujado.
- Hoy: identidad + firma + build + instalación (HU-12), Review 2, Retro 2.
- Impedimentos: ninguno al abrir; el plan gratuito de Supabase sigue activo
  (proyecto de respaldo creado tras la Retro, compromiso 1 de docs/41).
- Prueba individual del Sprint 2 en el LMS (15 min): SQL, CRUD y
  autenticación; promedio del equipo 8.2/10 (registro del docente).

## Teoría (15-60): distribuciones por plataforma

- versionName vs versionCode (pubspec → build.gradle), applicationId
  permanente, ícono adaptativo + splash nativa.
- Debug (JIT, ~30 MB) vs release (AOT, ~9 MB con R8 + shrink).
- Keystore: keytool, key.properties local, gitignore; pérdida = sin
  actualización futura (respaldo acordado).
- APK vs AAB; iOS sin Mac (Xcode + Apple Developer + TestFlight, o CI con
  runner macOS); Play Console y pistas internas.

## Laboratorio (60-120): pasos del día

| Paso | Min | Resultado |
|---|---|---|
| A. Identidad | 5 | pubspec 0.9.0+1, íconos y splash generados con los dos comandos `dart run` |
| B. Firma y permisos | 5 | keytool local, key.properties (gitignored), manifest con 3 permisos |
| C. Build release | 5 | `bash scripts/build_release.sh`: analyze 0 issues, 59 tests, APK ~9.2 MB |
| D. Instalación | 5 | `adb install -r app-release.apk` en 3 teléfonos; ícono, splash y versión 0.9.0+1 verificados |
| E. Sprint Review 2 | 20 | Acta docs/40: 31/31 puntos, 4 observaciones del PO, Hito 2 aceptado |
| F. Retrospectiva 2 | 20 | Acta docs/41: Start/Stop/Continue + 3 compromisos medibles |

## Proyecto paralelo (120-165)

- Cada equipo generó el APK release de su app (MoviPaz, SaludCerca,
  EmprendeLocal, CulturaAndina) e instaló al menos uno.
- Sustentación de 5 min por equipo del Informe 2: modelo ER, consultas,
  auth/RLS con su caso "atacante rechazado" y el APK en el teléfono.
- Notas del PO por equipo registradas en el tablero (pulidos para el
  Sprint 3; el Hito 2 queda entregado, Matriz 2 en evaluación).

## Cierre (165-180): refinamiento del Sprint 3

- HU-14..HU-20 re-estimadas con Planning Poker (34 puntos del sprint).
- Prioridad Must para el arranque: HU-14 (mapa) y HU-15 (ubicación) el
  Día 12-13; preparación: lectura de APIs REST + Postman (autónomo).
- Crear el proyecto en Google Cloud con alertas de presupuesto antes del
  Día 12 (autónomo): la clave de Maps restringida por applicationId.

## Incidencias

| Hora | Qué pasó | Cómo se resolvió |
|---|---|---|
| 10:20 | Build release falló: key.properties ausente en la laptop 2 | Se copió desde la laptop 1 (gitignored); lección: backup acordado → compromiso 3 de la Retro |
| 11:05 | Ícono cortado en launcher con máscara circular | Regenerar foreground respetando la zona segura 66% (observación 3 del Review) |
| 11:40 | La splash quedó blanca en un Android 12 | flutter_native_splash con android_12 configurado y regenerar |

## Evidencias del día

- APK instalado en 3 dispositivos + sha256 del artefacto en la salida del script.
- Actas docs/40 (Review) y docs/41 (Retro); Informe 2 en docs/42.
- Tag `v0.9.0-dia10` creado y empujado; 17 commits del día en docs/43.
