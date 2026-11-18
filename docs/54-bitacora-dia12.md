# 54 · Bitácora del Día 12 — CiudadAlerta (mapa de reportes, HU-14)

> Registro operativo de la sesión de 180 minutos. Lo escriben piloto y
> copiloto de la pareja del día; lo firma el Scrum Master.

## Daily Scrum + quiz de activación (00-15)

- Ayer: tag `v1.0.0-dia11` empujado; clima Open-Meteo funcionando con
  deterioro elegante; cuadro comparativo de APIs entregado (Matriz 3).
- Hoy: Maps Platform en la consola, clave restringida, marcadores de
  los reportes y ventana emergente al detalle (HU-14).
- Impedimentos: el aula tuvo que relogguearse en Google Cloud (la
  sesión de laboratorio expira); se resolvió en 3 minutos.
- Quiz de activación (12 preguntas, Kahoot) sobre API key,
  restricciones y cuotas: buena tasa en "dónde vive la clave"; la más
  fallada fue la diferencia entre restricción de APLICACIÓN (paquete +
  SHA-1) y restricción de API — se refuerza en el live coding porque es
  exactamente la mitad de la evidencia del día.

## Teoría + live coding (15-60)

- APIs más conocidas del ecosistema móvil: Google Maps Platform,
  Firebase/FCM, AWS, OpenWeather, pasarelas de pago y Twilio; cada una
  con su esquema de autenticación y su cuota.
- Consola de Google Cloud paso a paso: proyecto → habilitar Maps SDK
  for Android → API key → restricciones (app Android `com.ciudadalerta.app`
  + SHA-1 debug con keytool) → restricción de API → presupuesto.
- Mapas en Flutter: `google_maps_flutter`, `GoogleMap`,
  `CameraPosition` (zoom 10 / 12 / 15 probados en vivo),
  `Marker`, `InfoWindow` y `MarkerId` estable.
- La clave viaja por `--dart-define` y el manifest la recibe como
  placeholder: se mostró el manifest compilado con el valor inyectado y
  `git log -p | grep AIza` vacío.

## Laboratorio guiado (60-120)

- **Paso A — Consola (15 min)**: cada pareja creó el proyecto
  `ciudadalerta-curso`, habilitó Maps SDK for Android, creó la clave y
  la restringió. Evidencia capturada con los dígitos del medio tapados.
- **Paso B — Dependencia y plataforma (15 min)**: `google_maps_flutter`
  en pubspec, meta-data en el AndroidManifest, dart-defines decodificados
  en build.gradle. Incidencia 10:32 — una pareja copió mal el SHA-1
  (falta del último par `:b2`): el mapa salía en blanco con el logo de
  Google; la consola mostraba `AUTHENTICATION_FAILED`. Arreglo en 2
  minutos re-comparando la huella del keytool: quedó documentado en
  docs/51, tabla de errores.
- **Paso C — Datos con coordenadas (15 min)**: migración
  `db/ubicaciones_dia12.sql` en el SQL Editor (8 filas actualizadas),
  modelo `Report` con `latitud`/`longitud` opcionales y mock con las
  mismas ubicaciones para el modo demo.
- **Paso D — MapaScreen (15 min)**: `GoogleMap` con cámara en La Paz
  (zoom 12), marcadores desde `marcadoresDe`, InfoWindow que navega a
  `/reporte/:id`. Prueba del panel sin clave (correr SIN dart-define):
  instrucciones amigables y cero crash. Tocar el marcador de RPT-001
  abrió el detalle del bache de Miraflores: HU-14 aceptada.

## Proyecto paralelo (120-165)

- Cada equipo montó el mapa de SU app con datos de SU base:
  MoviPaz marcó paradas de minibus, SaludCerca centros de salud con
  horarios, EmprendeLocal negocios del rubro y CulturaAndina espacios
  culturales. Todos aplicaron restricciones a SU clave y registraron el
  primer consumo en la consola de Google Cloud (compromiso del trabajo
  autónomo: completar el mapa y revisar el panel de consumo).

## Cierre del día (165-180)

- **Revisión de configuración**: checklist de claves — restricciones
  aplicadas, `git log -p` sin `AIza`, capturas con la clave tapada, y
  ninguna clave compartida en chats del equipo.
- Suite en verde: **71 pruebas** (65 + 6 del mapa).
- Tablero actualizado: HU-14 pasa a Resuelto (8 pts), HU-15 y HU-20 en
  En proceso para el Día 13 (geolocalización, geocoding y rutas).

## Estado al cierre

- Tag: `v1.1.0-dia12` · versión de la app: 1.1.0+3 · 146 commits.
- Riesgos abiertos: SHA-1 release pendiente para el APK de la Review 3
  (se genera cuando el equipo firme el build release con su keystore).
