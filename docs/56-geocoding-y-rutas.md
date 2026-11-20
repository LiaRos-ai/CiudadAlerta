# 56 · Geocoding, caché y rutas — CiudadAlerta (Día 13)

> Guía técnica del reverse geocoding (coordenadas → dirección legible),
> de la caché con contador de llamadas y de la ruta costo cero (HU-20).
> Complemento de `docs/55` (permisos) y de la Guía Práctica del día.

## Reverse geocoding: dos caminos

1. **Geocoder del sistema (paquete `geocoding`)**: corre en el
   dispositivo, sin API key y sin costo por solicitud. Es la primera
   opción del curso.
2. **Geocoding API de Google**: mayor cobertura y consistencia; cobra
   por solicitud con la cuenta del proyecto (misma clave restringida
   del Día 12). Es el plan B.

El `Placemark` trae `thoroughfare` (calle), `subLocality` (barrio) y
`locality` (ciudad); `direccionLegible()` los une en
"Calle, Barrio, Ciudad" con respaldos (`name`, `street`) y un mensaje
honesto ("Ubicación sin dirección") si no hay datos.

## La caché: no llamar en cada rebuild

- **Clave**: coordenadas formateadas a 5 decimales (~1 metro): el
  jitter del GPS no dispara llamadas nuevas.
- **Contador de llamadas**: métrica didáctica que el trabajo autónomo
  reporta (cuántas llamadas reales, cuántas ahorró la caché).
- **Ubicación**: la llamada vive en el SERVICIO (cuando cambia el
  dato), nunca en el `build` del widget.

## Costos por solicitud (verificar precios vigentes en la tabla de precios de Maps Platform)

| Servicio | Cobra por solicitud | Uso en el curso |
|---|---|---|
| Geocoder del sistema (`geocoding`) | No | Día 13, primera opción |
| Geocoding API de Google | Sí | Plan B |
| Places Autocomplete | Sí | Extensión (Hito 4) |
| Directions / Routes API | Sí | Extensión (Hito 4) |
| `url_launcher` con la app de Google Maps | No | HU-20 (hoy) |

## La ruta costo cero (HU-20)

```
https://www.google.com/maps/dir/?api=1&origin=lat,lng&destination=lat,lng&travelmode=walking
```

- Con origen: ruta desde la posición actual del ciudadano.
- Sin origen (permiso negado o GPS apagado): solo `destination`.
- `launchUrl(..., mode: LaunchMode.externalApplication)`; si devuelve
  false, SnackBar de aviso (nunca un crash).
- La polilínea embebida con Directions API queda para el Hito 4, con su
  costo medido y defendido en el Informe 3.

## Checklist del cierre

- [ ] `direccionLegible` arma "calle, barrio, ciudad" con respaldos.
- [ ] La caché evita la segunda llamada (el contador no sube).
- [ ] "Cómo llegar" abre Google Maps desde el dispositivo.
- [ ] El equipo reportó su medición de llamadas (Informe 3).
