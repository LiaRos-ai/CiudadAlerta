# 58 · Bitácora del Día 13 — CiudadAlerta (geolocalización y rutas)

> Registro operativo de la sesión de 180 minutos. Lo escriben piloto y
> copiloto de la pareja del día; lo firma el Scrum Master.

## Daily Scrum + quiz de activación (00-15)

- Ayer: tag `v1.1.0-dia12` empujado; mapa con marcadores e InfoWindow;
  claves restringidas verificadas en el cierre.
- Hoy: permisos de ubicación, punto azul, dirección legible y ruta
  hacia el reporte (HU-15 y HU-20) con demo en dispositivo físico.
- Impedimentos: dos teléfonos sin depuración USB activada; se resolvió
  instalando los drivers en los primeros 10 minutos.
- Quiz de activación (12 preguntas, Kahoot) sobre permisos de ubicación
  y privacidad: buena tasa en reverse geocoding y caché; la más fallada
  fue CUÁNDO se pide el permiso runtime (consentimiento contextual) —
  se refuerza en el live coding porque es la decisión que gobierna
  todo el laboratorio.

## Teoría + live coding (15-60)

- geolocator: las tres preguntas en orden (hardware → permiso →
  posición); estados del permiso y respuesta de la app a cada uno.
- Precisión y batería: high para la lectura puntual; sin stream para el
  punto azul (la precisión se justifica con la HU).
- Reverse geocoding con el Geocoder del sistema: Placemark →
  "Calle, Barrio, Ciudad"; la Geocoding API de Google como plan B.
- Caché con clave a 5 decimales y contador de llamadas: la demo contó
  5 capturas y 2 llamadas reales.
- Privacidad: consentimiento contextual y minimización; preparación
  del foro del LMS ("¿cuándo es ético pedir la ubicación?").

## Laboratorio guiado (60-120) — incidencias del aula

- **La incidencia estrella**: contra Supabase (BD real) los 8 marcadores
  del seed DESAPARECEN; con el mock funcionaban. Causa: los select
  explícitos no pedían `latitud, longitud`. Fix en un commit `fix:`
  separado; lección: la demo en dispositivo contra la BD real está en la
  Definition of Done porque el mock puede esconder un bug de contrato.
- Permiso "no volver a preguntar" en un teléfono de pruebas: SnackBar
  con "Abrir Ajustes" funcionó a la primera; quedó capturado para la
  evidencia.
- GPS lento en interiores: el timeLimit de 8 s dispara el deterioro
  elegante; las parejas terminaron la demo en el pasillo (afuera el
  fix tardó ~3 segundos en dar fix de GPS).
- "Cómo llegar" en el equipo sin app de Google Maps: `launchUrl`
  devolvió false y el SnackBar avisó — nunca un crash.

## Proyecto paralelo (120-165)

- MoviPaz: parada más cercana con `distanciaA` + ruta.
- SaludCerca: centro de salud más cercano con dirección legible.
- EmprendeLocal: dirección del negocio y botón "Cómo llegar".
- CulturaAndina: ruta al espacio cultural desde la posición actual.
- Todos entregaron la medición de llamadas del geocoding (insumo del
  Informe 3).

## Cierre del día (165-180) — demo en dispositivo físico

- Cada pareja demostró: punto azul tras conceder, cámara centrada,
  reporte nuevo con zona real ("usar mi ubicación"), dirección legible
  en el detalle y ruta abierta en Google Maps.
- Verificación final: suite en 77 pruebas verdes, 17 commits
  convencionales, tag `v1.2.0-dia13`, `git log -p | grep -cE
  'AIza[A-Za-z0-9_-]{30,}'` = 0 (ninguna clave real; los `AIza...` de
  los docs son ejemplos).
- Lista de cotejo del Día 13 llenada por pareja (12 ítems) e insumo de
  la Matriz 3.
- Compromisos para el Día 14: leer `firebase_messaging` y el tutorial
  de Edge Functions; quiz de activación sobre tokens de notificación y
  permisos de micrófono.
