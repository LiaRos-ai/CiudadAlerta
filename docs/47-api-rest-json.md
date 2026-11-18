# 47 · Guía del Día 11 — API, REST, JSON y consumo seguro

> Material de la teoría + live coding (15-60). Es el mapa conceptual del
> Hito 3: todo lo que los Días 12-15 harán con Google y AWS se apoya en
> estas 6 ideas.

## 1. ¿Qué es una API?

Una **API** (Application Programming Interface) es el contrato con el que
un programa le pide servicios a otro. En móvil hablamos casi siempre de
APIs **web**: servidores que exponen funciones por HTTP. CiudadAlerta ya
usa una sin saberlo: el Día 8 el paquete `supabase_flutter` habló con la
**API REST autogenerada** de Supabase (PostgREST); hoy abrimos esa caja
para entender el REST que hay debajo.

- **Ejemplo cercano**: `supabase.from('reports').select()` dispara un
  `GET /rest/v1/reports?select=*` con los headers `apikey` y
  `Authorization: Bearer <JWT>` — exactamente lo que se muestra hoy en
  Postman (`api/postman_collection.json`).
- **Ejemplo nuevo**: `GET api.open-meteo.com/v1/forecast?latitude=...`
  para el clima — sin SDK ni librería especial, solo HTTP.

## 2. REST: recursos, verbos y códigos de estado

REST modela el sistema como **recursos** con **URLs** que se manipulan
con los **verbos HTTP**. La tabla es la del quiz de activación:

| Verbo | Acción REST | En CiudadAlerta (tabla `reports`) | Respuesta típica |
|---|---|---|---|
| GET | Leer | `GET /rest/v1/reports?select=*` | `200 OK` + JSON |
| POST | Crear | `POST /rest/v1/reports` + cuerpo JSON | `201 Created` |
| PATCH | Editar parcial | `PATCH /rest/v1/reports?code=eq.RPT-001` | `200 OK` |
| PUT | Reemplazar completo | (no se usa en el curso) | `200 OK` |
| DELETE | Eliminar | `DELETE /rest/v1/reports?code=eq.X` | `204 No Content` |

Y los **códigos de estado** son el idioma de la respuesta:

| Código | Significado | Caso real del curso |
|---|---|---|
| 200 / 201 | Todo bien / creado | El CRUD del Día 8 |
| 400 | Petición mal formada | JSON mal armado en Postman |
| 401 / 403 | No autenticado / no autorizado | RLS rechazando a un atacante (SP-02) |
| 404 | Recurso inexistente | `reportePorIdProvider` con código falso |
| 429 | Cuota/rate limit agotado | Demasiadas consultas a la API (riesgo del planning) |
| 5xx | Error del servidor | La API del clima caída: la app sigue (deterioro elegante) |

## 3. JSON y `fromJson` en Dart

JSON es el formato de intercambio: texto que replica estructuras de
datos. En Dart la regla de la casa es **un modelo por recurso** con su
`fromJson`/`toJson` centralizado (igual que `Report` desde el Día 2 y
hoy `Clima`):

```dart
factory Clima.fromJson(Map<String, dynamic> json) {
  final current = (json['current'] as Map<String, dynamic>?) ?? const {};
  return Clima(
    temperatura: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
    codigo: (current['weather_code'] as num?)?.toInt() ?? -1,
    ...
  );
}
```

Detalles que evitan errores clásicos: el JSON numérico llega como `num`
(cast explícito a `double`), los campos pueden faltar (operador `?` y
valores neutros) y el cuerpo de la respuesta se decodifica con
`utf8.decode(resp.bodyBytes)` para los acentos.

## 4. SDK vs API

| Aspecto | API REST cruda (`http`) | SDK (`supabase_flutter`, `google_maps_flutter`) |
|---|---|---|
| Qué es | El contrato HTTP en vivo | Librería que envuelve la API |
| Ventaja | Entiendes TODO lo que pasa; funciona para cualquier servicio | Menos código, tipos listos, streams y widgets |
| Riesgo | Repites plumbing (headers, errores) | Caja negra: un error es más difícil de diagnosticar |
| En el curso | Día 11 (clima), día 15 (Lambda) | Día 8 (Supabase), Días 12-14 (Maps, FCM) |

**Regla del curso**: aprende la API primero, usa el SDK después. Quien
leyó el `GET /rest/v1/reports` de hoy depura mejor el SDK del Día 12.

## 5. Autenticación de APIs: key, OAuth 2.0, JWT

| Esquema | Qué es | Dónde vive | Ejemplo en el curso |
|---|---|---|---|
| **API key** | Cadena secreta por proyecto | `--dart-define` + restricciones en la consola | Google Maps (Día 12) |
| **OAuth 2.0** | Delegación con tokens de corta vida y consentimiento | Servidor / Edge Function | Integraciones con cuentas de terceros (fuera del alcance) |
| **JWT** | Token firmado con claims; Supabase Auth ya lo emite | `flutter_secure_storage` (Día 9) | `Authorization: Bearer <JWT>` en cada llamada |

Y la regla de seguridad del hito: **la clave que la app carga es una
clave comprometida** — cualquier APK puede descompilarse. Por eso las
claves se restringen (paquete/SHA-1/referrer), se limitan por cuota y
las más sensibles NUNCA bajan al teléfono: viven en una **Edge Function
o proxy** que firma la llamada por la app.

## 6. Cuotas, costos y consumo monitoreado

Toda API del hito se adopta con tres preguntas escritas en el cuadro
(`docs/46`): ¿cuánto cuesta el plan gratuito?, ¿qué pasa si lo excedo
(429 o factura)?, ¿dónde veo el consumo? — Google Cloud muestra las
métricas por API; AWS, por servicio con **Budgets**; Supabase, en el
panel. El monitoreo NO es burocracia: es la diferencia entre una demo
interrumpida y un sprint tranquilo.

## 7. OpenAPI y Postman

- **OpenAPI** es el estándar para DESCRIBIR una API (endpoints,
  parámetros, respuestas) en un YAML legible por máquinas: Swagger UI
  lo convierte en documentación navegable; muchos servicios lo publican
  (el de Supabase está en `https://TU-PROYECTO.supabase.co/rest/v1/`).
- **Postman** es el cliente visual para probar endpoints ANTES de
  codificar: colecciones, variables y ejemplos de respuesta. El flujo
  del día es Postman → modelo → servicio → widget; la colección del
  Proyecto Guía vive en `api/postman_collection.json` y la del equipo
  se documenta en el trabajo autónomo (45 min).
