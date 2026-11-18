# 48 · Guía técnica del servicio de clima Open-Meteo (Día 11)

> Cómo está construida la primera integración de API externa del
> Proyecto Guía y por qué cada decisión importa para las APIs de los
> Días 12-15.

## 1. El contrato con la API

```
GET https://api.open-meteo.com/v1/forecast
    ?latitude=-16.4955
    &longitude=-68.1336
    &current=temperature_2m,weather_code,wind_speed_10m
    &timezone=America/La_Paz
```

Respuesta (recortada):

```json
{
  "latitude": -16.5,
  "longitude": -68.15,
  "current": {
    "time": "2026-11-15T09:30",
    "temperature_2m": 12.4,
    "weather_code": 2,
    "wind_speed_10m": 14.8
  }
}
```

La misma petición se ejecutó PRIMERO en Postman (Paso B del laboratorio)
y está guardada en `api/postman_collection.json`. El código WMO de la
sección `current` es un número estándar (0 = despejado, 2 = parcialmente
nublado, 61 = lluvia...): la traducción a íconos vive en
`clima_visual.dart`.

## 2. Las 4 capas de la pieza

| Capa | Archivo | Responsabilidad |
|---|---|---|
| Configuración | `lib/data/api/api_config.dart` | URL pública + futuras claves por `--dart-define` (ninguna clave en el repo) |
| Modelo | `lib/data/clima/clima.dart` | `fromJson`/`toJson` tipado, tolerante a campos faltantes |
| Servicio | `lib/data/clima/weather_service.dart` | GET + timeout + traducción de códigos de estado a `ApiException` amigables |
| Estado y UI | `lib/providers/clima_provider.dart` + `lib/widgets/clima_card.dart` | `FutureProvider<Clima>` + tarjeta con deterioro elegante |

Es la misma arquitectura por capas del Día 6 con un proveedor externo
nuevo en la base: la pantalla sigue sin saber de dónde vienen los datos.

## 3. Decisiones de diseño y su porqué

1. **`http.Client` inyectable**: el constructor acepta un cliente; los
   tests pasan un `MockClient` (`package:http/testing.dart`) y no abren
   sockets. Misma idea del repositorio mock/Supabase del Día 8.
2. **Timeout de 8 segundos**: la red del aula no es confiable y una
   llamada eterna congela la tarjeta. Al vencer el tiempo se lanza
   `ApiException` con mensaje de usuario — nunca un crash.
3. **Errores traducidos por código**: 200 parsea; 429 = "cuota agotada";
   5xx = "falló el servidor, reintenta"; otros = mensaje neutro. El quiz
   del día enseñó los códigos; el servicio los vuelve UX.
4. **Deterioro elegante**: el clima es OPCIONAL. Si la API falla, la
   tarjeta muestra "Clima no disponible (toca para reintentar)" y la
   lista de reportes sigue funcionando — la observación 2 del Review 2
   convertida en patrón.
5. **`ref.invalidate(climaActualProvider)`**: el reintento es el
   mecanismo estándar de Riverpod; la tarjeta no guarda estado propio.

## 4. Cómo se probó (65 pruebas verdes)

`app/test/clima_test.dart` agrega 6 pruebas: 2 del modelo (parseo y
tolerancia), 3 del servicio con `MockClient` (200, 429 y 503) y 1 de
`ApiConfig` (sin claves sin `--dart-define` y URL pública sin
credenciales). El contrato completo queda fijado sin red real: la suite
de la clase corre en cualquier laptop del aula.

## 5. Qué reutiliza el resto del sprint

- **Día 12 (HU-14)**: la clave de Maps llega por `--dart-define`
  (`mapsApiKey` ya existe en `ApiConfig`) y se restringe por SHA-1.
- **Día 13 (HU-15/HU-20)**: geolocator y Directions usan el mismo patrón
  servicio + modelo + provider; el reverse geocoding cacheará resultados
  para cuidar la cuota.
- **Día 15 (HU-18)**: Lambda + API Gateway son "un WeatherService con
  proxy": la app habla con NUESTRO endpoint y la clave AWS nunca baja
  al teléfono.
