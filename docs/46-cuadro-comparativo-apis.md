# 46 · Cuadro comparativo de APIs del Día 11 (evidencia oficial · Matriz 3)

> Evidencia oficial del Día 11 según el plan de la asignatura: **"Cuadro
> comparativo de APIs (Matriz 3)"**. Cada equipo repite este ejercicio con
> al menos 3 APIs candidatas de SU proyecto paralelo (bloque 120-165); el
> Proyecto Guía documenta aquí su selección completa.

## 1. Criterios de comparación (los 6 del plan)

1. **Función**: qué problema del producto resuelve.
2. **Costo**: plan gratuito real y precio por millón de solicitudes.
3. **Cuota**: límites por segundo/día del plan gratuito (rate limit).
4. **Autenticación**: API key, OAuth 2.0, JWT o pública.
5. **Ventajas**: documentación, SDK Flutter, calidad del JSON, latencia.
6. **Desventajas**: claves expuestas, cuotas cortas, dependencia externa.

## 2. Cuadro del Proyecto Guía (CiudadAlerta)

| API | Función en CiudadAlerta | Costo (plan free) | Cuota | Autenticación | Ventajas | Desventajas |
|---|---|---|---|---|---|---|
| **Open-Meteo** ✅ (Día 11) | Clima actual en la lista de reportes (contexto del reporte) | Gratis para uso no comercial | ~10.000 req/día | **Pública, sin key** | Sin secretos, JSON simple, ideal para aprender REST | Sin SLA comercial; no cubre pronóstico a 16 días con alta resolución |
| **Google Maps Platform** (HU-14, Día 12) | Mapa con marcadores de reportes | USD 200/mes de crédito (2.5 k cargas de mapa estático) | ~28.000 cargas/mes con crédito | API key + restricción por app (SHA-1) | SDK oficial `google_maps_flutter`, latencia y cobertura excelentes | Requiere cuenta con facturación; la clave filtrada cuesta dinero |
| **Google Directions / Routes** (HU-20, Día 13) | Ruta desde el ciudadano hasta el reporte | Dentro del crédito de USD 200 | Cuota por elemento de ruta | API key restringida | Distancia y tiempo reales | Consumo rápido del crédito si no se cachéa |
| **Firebase Cloud Messaging** (HU-17, Día 14) | Push cuando cambia el estado del reporte | Gratis | Sin límite práctico para el alcance del curso | Token OAuth/JWT del dispositivo + server key en Edge Function | Integración nativa con FlutterFire; envío gratis | Configuración inicial (proyecto Firebase + tokens) no trivial |
| **OpenWeather** (alternativa al clima) | Igual que Open-Meteo | Free: 60 llamadas/min | 1M llamadas/mes | API key en query | Documentación famosa, modelos listos | La key viaja en la URL: fácil de filtrar si se expone |
| **AWS Rekognition + Lambda + API Gateway** (HU-18, Día 15) | Etiquetas sugeridas para la foto del reporte | Free tier 12 meses (5k imágenes Rekognition/mes) | Free tier por servicio | Firma AWS (IAM) desde Lambda, la app solo habla con el proxy | La app NUNCA ve la clave AWS (patrón proxy) | Configurar IAM/Lambda toma tiempo; hay que vigilar Budgets |
| **Twilio** (descartada) | SMS para verificación | Prueba limitada con crédito | Por SMS enviado | API key + OAuth | La mejor API de mensajería | No hay plan gratuito continuo; fuera del alcance del hito |

## 3. Selección del sprint (justificación)

| Prioridad | API | Por qué gana para CiudadAlerta |
|---|---|---|
| 1 | **Google Maps Platform** | La HU-14 (Must) es la cara visible del hito; el crédito de USD 200 cubre el semestre con restricciones aplicadas |
| 2 | **FCM** (o Supabase Edge Functions como alternativa aprobada) | HU-17 completa el ciclo del reporte: el ciudadano entera de cambios sin abrir la app |
| 3 | **AWS Rekognition vía Lambda** | HU-18 aprovecha el patrón "clave nunca en la app"; alternativa aprobada: funciones de Supabase |
| Debut | **Open-Meteo** | Aprende el patrón REST sin secretos; su integración (Día 11) es el molde de las demás |

## 4. Cómo llenar el cuadro en el proyecto paralelo (45 min)

1. Elegir 3 APIs candidatas para MoviPaz / SaludCerca / EmprendeLocal /
   CulturaAndina (una de mapas/ubicación, una de datos y una opcional).
2. Por cada API llenar las 6 columnas CON FUENTE: la página de pricing y
   la de rate limits se citan en el informe (Matriz 3).
3. Consumir UNA de prueba con `http` (el molde del clima del Proyecto
   Guía) y capturar la respuesta.
4. Registrar en el tablero: tarjeta "APIs candidatas documentadas"
   movida a Hecho con el enlace al cuadro.

> **Pregunta de examen del día**: ¿qué columna del cuadro FALLA primero
> si la app se vuelve viral? — la **cuota**, no el costo: por eso la
> teoría enseña a cachear y a monitorear el consumo antes de escalar.
