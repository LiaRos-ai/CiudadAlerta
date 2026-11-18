# 50 · Bitácora del Día 11 — CiudadAlerta (arranque del Sprint 3)

> Registro operativo de la sesión de 180 minutos. Lo escriben piloto y
> copiloto de la pareja del día; lo firma el Scrum Master.

## Daily Scrum + quiz de activación (00-15)

- Ayer: tag `v0.9.0-dia10` empujado; Informe 2 entregado; proyecto de
  Google Cloud creado con alertas de presupuesto (compromiso del Review).
- Hoy: Sprint Planning 3, conceptos de API/REST/JSON, primera API
  (Open-Meteo) en Postman y en la app, Planning Poker del Sprint 3.
- Impedimentos: ninguno al abrir; la red del aula respondió a la primera.
- Quiz de activación (12 preguntas, Kahoot): los métodos HTTP y los
  códigos de estado tuvieron buena tasa de acierto; la pregunta más
  fallada fue la diferencia entre 401 y 403 (se refuerza en el live
  coding con el caso SP-02 del Día 9).

## Teoría + live coding (15-60)

- ¿Qué es una API? Se abrió la caja del SDK de Supabase: el
  `from('reports').select()` del Día 8 ES un `GET /rest/v1/reports`.
- REST: recursos, verbos (tabla GET/POST/PATCH/DELETE) y códigos de
  estado con los casos reales del curso (RLS = 401/403, cuota = 429).
- JSON y `fromJson` centralizado: live coding del modelo `Clima`.
- SDK vs API; autenticación API key / OAuth 2.0 / JWT y por qué una
  clave dentro del APK se considera comprometida (Edge Functions/proxy).
- Cuotas y costos: se abrieron las páginas de pricing de Open-Meteo y
  Google Maps Platform; cada equipo anota números para su cuadro.

## Laboratorio guiado (60-120)

- **Sprint Planning 3 (30 min)**: entradas (refinamiento del Día 10,
  compromisos de la Retro 2, presupuesto de Google Cloud), meta del
  sprint 3 leída del acta del Hito, selección HU-14..HU-20 (34 pts) con
  orden de construcción, riesgos y DoD del sprint. Acta completa en
  `docs/45`; tablero actualizado con las tarjetas del sprint.
- **Paso B — Open-Meteo en Postman (8 min)**: GET con latitude/
  longitude/current/timezone; se guardó en la colección compartida
  (`api/postman_collection.json`). La misma consulta abierta en el
  navegador: Postman no hace magia, solo HTTP.
- **Paso C — WeatherService (12 min)**: modelo `Clima`, servicio con
  `http.Client` inyectable, timeout de 8 s y errores traducidos
  (200/429/5xx). Incidencia 11:05 — una pareja recibió 429 por consultar
  en loop durante el live coding: se usó como demostración del código de
  estado y se bajó la frecuencia de recarga.
- **Paso D — ClimaCard (10 min)**: provider Riverpod + tarjeta arriba de
  la lista; prueba del deterioro elegante apagando el wifi: "Clima no
  disponible (toca para reintentar)" y la lista NUNCA se bloqueó.

## Proyecto paralelo (120-165)

- Cada equipo seleccionó y documentó **3 APIs candidatas** para su app
  (función, costo, cuota, autenticación, ventajas y desventajas) en su
  copia de `docs/46`; MoviPaz eligió Maps + Directions + FCM, SaludCerca
  Maps + Places + FCM, EmprendeLocal Maps + Places + pasarela de pago,
  CulturaAndina Maps + Places + Cloud Vision como alternativa de
  Rekognition.
- Consumo de prueba: cada equipo corrió una petición con `http`
  (la mayoría reutilizó el molde del clima) y capturó la respuesta para
  el Informe 3.

## Cierre del día (165-180)

- **Planning Poker del Sprint 3**: confirmación de las estimaciones del
  refinamiento (34 pts); la discusión más larga fue HU-18 (Rekognition,
  8 pts) por el costo de configurar IAM/Lambda — queda para el Día 15
  con la alternativa aprobada de Edge Functions.
- Tablero actualizado: HU-14 y HU-15 en Ready; deuda técnica del clima
  (cachear la respuesta 15 min) registrada como tarjeta del sprint.
- Lista de cotejo del día llena; PR hacia `dev` abierto; tag
  `v1.0.0-dia11` creado tras las 65 pruebas verdes.

## Compromisos para el Día 12

1. Cada equipo llega con su API key de Maps creada y con las
   restricciones (Android + SHA-1) ya configuradas en la consola.
2. La clave de Maps entra por `--dart-define`, jamás al repositorio
   (verificación con `git log -p` al cierre).
3. El Proyecto Guía suma el mapa con marcadores (HU-14); los equipos
   replican con sus datos reales de Supabase.
