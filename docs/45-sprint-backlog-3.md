# 45 · Sprint Planning 3 — CiudadAlerta (Sprint 3 · Hito 3)

> Acta del **Sprint Planning 3** realizado en la Clase 11 (Día 11, 30 min de
> laboratorio). Abre el Sprint 3 (días 11-15, Hito 3: "APIs y servicios
> externos — Google, Amazon"). Su salida — el **Sprint Backlog 3 publicado
> en el tablero** — complementa la evidencia oficial del día, el **Cuadro
> comparativo de APIs (Matriz 3)**, documentado en `docs/46`.

## 1. Entradas del planning

| Entrada | Fuente | Estado |
|---|---|---|
| Product Backlog refinado (HU-14 a HU-20, 34 pts) | Cierre del Día 10 | ✅ Listo |
| Retrospectiva 2 (3 compromisos) | `docs/41-retrospectiva-2.md` | ✅ Incorporados |
| APK 0.9.0+1 instalable (base estable) | tag `v0.9.0-dia10` | ✅ Publicado |
| Proyecto de Google Cloud con alertas de presupuesto | Trabajo autónomo del Día 10 | ✅ Creado por equipos |

## 2. Meta del Sprint 3 (Sprint Goal)

> **"App con al menos 2 APIs externas integradas (mapas/ubicación de
> Google, voz o notificaciones, y un servicio AWS o alternativa aprobada),
> con claves protegidas y consumo monitoreado."**

Meta de producto y de seguridad a la vez: al cierre del Día 15 la app no
solo muestra APIs funcionando — puede demostrar DÓNDE vive cada clave, a
cuánto asciende el consumo y qué pasa si una API no responde.

## 3. Sprint Backlog 3 (HU-14 a HU-20)

Selección confirmada con Planning Poker durante el cierre del día. Total:
**34 puntos** (el sprint más corto del curso por la carga de integración).

| HU | Historia de usuario | Puntos | Día planificado | Criterio de aceptación |
|---|---|---|---|---|
| — | Sprint Planning 3 + conceptos API/REST/JSON + demo clima Open-Meteo | — | Día 11 ✅ | Cuadro comparativo (docs/46) + servicio de clima en la app |
| HU-14 | Ver los reportes en un mapa para ubicarlos fácilmente | 5 | Día 12 | Google Maps con marcadores; toque abre el detalle |
| HU-15 | Que la app detecte mi ubicación y dirección para reportar rápido | 5 | Día 13 | Permiso de ubicación; reverse geocoding; permiso denegado manejado |
| HU-20 | Trazar la ruta hacia un reporte | 3 | Día 13 | Directions API; muestra distancia y tiempo |
| HU-16 | Dictar la descripción por voz para reportar sin escribir | 5 | Día 14 | Reconocimiento de voz en español; edición del texto |
| HU-19 | Escuchar el detalle del reporte (texto a voz) | 3 | Día 14 | Botón "escuchar" con flutter_tts |
| HU-17 | Recibir una notificación cuando cambie el estado de mi reporte | 5 | Día 14 | Push al actualizar estado; token por usuario |
| HU-18 | Sugerencias automáticas de categoría desde la foto (Rekognition) | 8 | Día 15 | Lambda + API Gateway devuelve etiquetas; clave nunca en la app |

Orden de construcción: primero el **cimiento** (Día 11: REST, JSON, claves
y el primer cliente HTTP), luego **mapas y ubicación** (Días 12-13), la
**voz y notificaciones** (Día 14) y el cierre con **AWS + Review 3**
(Día 15).

## 4. Decisiones técnicas del planning

| Decisión | Alternativa descartada | Motivo |
|---|---|---|
| Primera API = Open-Meteo (sin API key) | Arrancar directo con Google Maps | Zero secretos y cero facturación para aprender el patrón REST sin miedo; Maps llega el Día 12 con restricciones ya discutidas |
| Paquete `http` para el primer cliente | `dio` desde el día 1 | `http` es el mínimo común denominador (quiz: "menos abstracción al aprender"); `dio` se introduce el Día 12 con interceptores |
| Modelo `Clima` con `fromJson` centralizado | Parsear JSON en el widget | La regla de la casa desde el Día 2: la UI recibe objetos tipados |
| Claves vía `--dart-define` + Edge Functions/proxy (Día 12+) | Hardcodear en `main.dart` | MASVS; verificado por `test/clima_test.dart` y por el control de `git log -p` |

## 5. Riesgos identificados

| Riesgo | Impacto | Mitigación acordada |
|---|---|---|
| Cuota/rate limit de APIs públicas durante la clase | La demo muestra 429 | Timeout de 8 s + mensajes amigables + deterioro elegante (la lista NUNCA se bloquea) |
| Claves de Maps expuestas al subirlas al repo | Dolor de cabeza de seguridad | Restricción por app/SHA-1 (Día 12) y `--dart-define`; el repo solo lleva el nombre de la variable |
| Red del aula inestable para las demos | Demos interrumpidas | Respuesta JSON de ejemplo capturada en Postman para el replanteo sin red |
| Cuentas de pago accidental en Google Cloud | Facturas sorpresa | Alertas de presupuesto creadas en el autónomo del Día 10 (compromiso del Review 2) |

## 6. Definición de Terminado del Sprint 3

La misma DoD del curso (`docs/04`) con dos añadidos del Hito 3:

1. Toda API integrada muestra su comportamiento de FALLA controlada
   (timeout / 429 / 5xx) con mensaje amigable y sin bloquear la app.
2. Ninguna clave aparece en el repositorio: `git log -p` limpio y las
   restricciones de la clave documentadas en la bitácora del día.
