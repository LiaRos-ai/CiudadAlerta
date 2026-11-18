# 52 · Guía técnica: Google Maps en Flutter con marcadores de reportes (HU-14)

> Cómo está construida la pestaña Mapa del Proyecto Guía (Día 12 /
> Sprint 3) y por qué cada decisión importa. La clave vive en la consola
> (docs/51); el código vive en el repo SIN claves.

## 1. La pieza en 4 capas (la misma arquitectura de siempre)

| Capa | Archivo | Responsabilidad |
|---|---|---|
| Modelo | `lib/data/report.dart` | `latitud`/`longitud` opcionales (`double?`), patrón del `fotoUrl` del Día 9 |
| Lógica de mapa | `lib/data/mapa/marcadores.dart` | `Report` → `Set<Marker>`; coordenadas faltantes se excluyen |
| Pantalla | `lib/screens/mapa_screen.dart` | `GoogleMap` + cámara inicial + InfoWindow → detalle |
| Configuración | `lib/data/api/api_config.dart` + `android/` | `MAPS_API_KEY` por `--dart-define` → placeholder del manifest |

La pantalla NO construye marcadores ni conoce coordenadas: solo arma el
widget y pasa el callback de navegación. Es la regla del curso
(UI → providers → data) aplicada al SDK de Google.

## 2. Los datos: columnas opcionales en la BD

`db/ubicaciones_dia12.sql` agrega `latitud` y `longitud`
(double precision) a `reports` y llena los 8 reportes del seed. El
modelo los lee así:

```dart
latitud:  (fila['latitud']  as num?)?.toDouble(),
longitud: (fila['longitud'] as num?)?.toDouble(),
```

El cast tolerante (`as num?`) viene del `Clima.fromJson` del Día 11:
un reporte viejo sin ubicación llega con `null` y NO rompe nada.

## 3. La clave: de --dart-define al manifest (sin versionarla)

**a) En Dart**, `ApiConfig` ya leía la clave desde el Día 11:

```dart
const key = String.fromEnvironment('MAPS_API_KEY');
// null cuando no se define: el mapa muestra su panel, no un crash
```

**b) En Android**, el widget nativo lee la clave del manifest, no de
Dart. La solución estándar es un placeholder inyectado en build:

```xml
<!-- android/app/src/main/AndroidManifest.xml (dentro de <application>) -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${mapsApiKey}"/>
```

```groovy
// android/app/build.gradle (antes de android { ... })
def dartDefines = [:]
if (project.hasProperty('dart-defines')) {
  project.property('dart-defines').split(',').each { entry ->
    def kv = new String(entry.decodeBase64(), 'UTF-8').split('=', 2)
    dartDefines[kv[0]] = kv.length > 1 ? kv[1] : ''
  }
}
// ...y dentro de defaultConfig:
manifestPlaceholders = [mapsApiKey: dartDefines['MAPS_API_KEY'] ?: '']
```

`--dart-define` llega al Gradle codificado en base64 (Flutter lo hace
así desde 2021); el decode devuelve `MAPS_API_KEY=AIza...` y el
placeholder completa el manifest en tiempo de BUILD. Verifica el resultado:

```
fvm flutter run --dart-define=MAPS_API_KEY=AIza... 
# y para auditar el manifest compilado:
# build/app/outputs/apk/debug/AndroidManifest.xml debe tener el valor
```

Con `git log -p` NUNCA debe aparecer la clave: el repo solo conoce el
NOMBRE de la variable.

## 4. El mapa y su cámara

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: sedeLaPaz,      // LatLng(-16.4955, -68.1336), centro de La Paz
    zoom: 12,               // La Paz y El Alto juntas en pantalla
  ),
  markers: marcadoresDe(reportes, alTocarInfoWindow: navegarAlDetalle),
  myLocationEnabled: false,  // la ubicación real llega el Día 13 (HU-15)
)
```

`CameraPosition` es la tríada posición/zoom/bearing que la teoría
ejemplificó: en el live coding se prueba zoom 10 (la ciudad), 12 (las
dos ciudades), 15 (una cuadra) para que el equipo SIENTA el parámetro.

## 5. Marcadores y ventana emergente (el criterio de HU-14)

```dart
Marker(
  markerId: MarkerId(reporte.id),           // RPT-001: estable y navegable
  position: coords,                          // LatLng del reporte
  infoWindow: InfoWindow(
    title: reporte.titulo,
    snippet: '${reporte.estado} · ${reporte.zona}',
    onTap: () => context.push('/reporte/${reporte.id}'),
  ),
)
```

- Tocar el PIN abre la InfoWindow; tocar la InfoWindow navega al detalle
  de la HU-04 (go_router del Día 4, sin pantallas nuevas).
- `markerId` = id del reporte: si la lista se recarga, el marcador no
  se duplica visualmente (Set de marcadores con ids únicos).

## 6. Deterioro elegante en dos frentes

| Frente | Situación | Comportamiento |
|---|---|---|
| Configuración | `MAPS_API_KEY` ausente | Panel con instrucciones y enlace a docs/51; NUNCA un crash |
| Datos | Reporte sin coordenadas | `coordenadasDe` devuelve null; el reporte no genera marcador |
| Datos | Provider en error | Mensaje amigable y reintento desde Inicio (pull-to-refresh) |

## 7. Pruebas (6 nuevas; suite en 71)

`test/mapa_test.dart`: `fromJson` con coords, `toJson` que omite las
nulas (contrato del Día 7 intacto), un `Marker` por reporte con
`MarkerId` correcto, exclusión de nulos, `InfoWindow` (title/snippet/
onTap que entrega el reporte) y el panel sin clave con `testWidgets`.
La regla del curso se mantiene: la lógica se prueba, el render se demuestra.

## 8. Lo que viene (Día 13 y 14)

- **HU-15/HU-20 (Día 13)**: `geolocator` para la ubicación REAL,
  `geocoding` para dirección legible y Directions para rutas: el
  `sedeLaPaz` constante se reemplaza por el punto del GPS.
- **HU-17 (Día 14)**: notificación push cuando cambia el estado de un
  reporte; el mapa es el escenario natural de esa alerta.
