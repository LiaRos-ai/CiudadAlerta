# 55 · Permisos y ubicación con geolocator — CiudadAlerta (Día 13)

> Guía de la evidencia técnica del Día 13 (HU-15): qué permisos declara
> la app, cuándo los pide y cómo reacciona a cada estado. Complemento
> de `docs/56` (geocoding y rutas) y de la Guía Práctica del día.

## Los permisos del manifest (mínimo privilegio)

| Permiso | Qué habilita | Por qué lo pide CiudadAlerta |
|---|---|---|
| `ACCESS_FINE_LOCATION` | GPS de precisión (metros) | El punto azul del mapa y las coordenadas del reporte (HU-15) |
| `ACCESS_COARSE_LOCATION` | Ubicación aproximada | La mínima que el sistema exige junto a FINE |
| `ACCESS_BACKGROUND_LOCATION` | Rastreo con la app cerrada | NO se declara: la app no rastrea en segundo plano (minimización) |

## El permiso runtime: tres preguntas en orden

1. `isLocationServiceEnabled()` — ¿el hardware está encendido?
2. `checkPermission()` y, si está `denied`, `requestPermission()` — el
   diálogo del sistema EN CONTEXTO: al tocar "Usar mi ubicación", nunca
   al abrir la app (consentimiento contextual).
3. `getCurrentPosition(desiredAccuracy: LocationAccuracy.high,
   timeLimit: Duration(seconds: 8))` — UNA lectura puntual; el punto
   azul NO abre un stream continuo (batería y privacidad).

## Estados del permiso y respuesta de la app

| Estado | Respuesta de CiudadAlerta |
|---|---|
| `denied` | La siguiente llamada a `requestPermission` levanta el diálogo |
| `deniedForever` | SnackBar con explicación + "Abrir Ajustes" (`openAppSettings`); nunca insiste en loop |
| `whileInUse` | Punto azul + captura de ubicación (suficiente para todo el curso) |
| `always` | No se pide: la app no rastrea en segundo plano |

## Precisión y batería

- `high` para la lectura puntual del reporte (una medición con tope de
  tiempo); el mapa no mantiene stream: la precisión se justifica con la
  HU, no con el entusiasmo.
- `timeLimit` de 8 s: en interiores el GPS puede tardar; el timeout
  avisa con un SnackBar y el reporte sigue sin coordenadas.

## Privacidad (consentimiento y minimización)

- Consentimiento contextual (se pide cuando la función lo necesita).
- Propósito explicado (diálogo y SnackBar dicen para qué se usa).
- Minimización de datos (solo el punto del reporte; sin rastro ni
  historial de movimiento).
- Mínimo privilegio (`whileInUse`; `always` no se pide).
- Rechazo sin castigo (el reporte se crea igual, sin crash).

## Checklist del cierre

- [ ] Manifest con los dos permisos y sin `always`.
- [ ] El diálogo aparece SOLO al tocar el botón de ubicación.
- [ ] `deniedForever` muestra SnackBar con "Abrir Ajustes".
- [ ] Sin permiso, el reporte se crea sin coordenadas y sin crash.
- [ ] La incidencia del aula quedó escrita en `docs/58`.
