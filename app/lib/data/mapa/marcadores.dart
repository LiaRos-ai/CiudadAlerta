// CiudadAlerta - Construcción de marcadores para el mapa (Día 12 / Sprint 3)
//
// HU-14: "Como ciudadano quiero ver los reportes en el mapa de mi ciudad
// para saber qué ocurre cerca de mí".
//
// El criterio clave de HU-14 es la VENTANA EMERGENTE que lleva al detalle:
// tocar el marcador abre su InfoWindow y tocar la InfoWindow navega a
// /reporte/:id con go_router (la navegación de la HU-04, Día 4).
//
// Por qué vive en data/ y no dentro de la pantalla:
//   - Construir marcadores es LÓGICA PURA (entrada: List<Report>, salida:
//     Set<Marker>): se prueba sin levantar GoogleMap ni platform channels,
//     igual que los agregados estadísticos del Día 8.
//   - La pantalla (mapa_screen.dart) solo arma el GoogleMap y pasa el
//     callback de navegación: regla del curso UI -> providers -> data.

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../report.dart';

/// Sede del Proyecto Guía (centro de La Paz): cámara inicial del mapa.
/// El Día 13 (HU-15) este punto será la ubicación REAL del ciudadano
/// con geolocator; hoy es la constante documentada de ApiConfig.
const LatLng sedeLaPaz = LatLng(-16.4955, -68.1336);

/// Zoom de la cámara inicial: 12 muestra La Paz y El Alto juntas.
/// Menos zoom las separa en distritos; más zoom pierde la vista general.
const double zoomInicial = 12;

/// Extrae las coordenadas de un reporte; null si no las tiene (los
/// reportes anteriores a la migración db/ubicaciones_dia12.sql). El mapa
/// los excluye sin romper la app: el deterioro elegante del Día 11
/// aplicado a los DATOS, no solo a las APIs.
LatLng? coordenadasDe(Report reporte) {
  final lat = reporte.latitud;
  final lng = reporte.longitud;
  if (lat == null || lng == null) return null;
  return LatLng(lat, lng);
}

/// Construye el Set<Marker> de la HU-14:
///   - MarkerId = id del reporte (RPT-001...): estable y navegable.
///   - InfoWindow.title = titulo; snippet = estado · zona.
///   - onTap de la InfoWindow -> callback (la pantalla navega al detalle).
/// Los reportes sin coordenadas NO generan marcador.
Set<Marker> marcadoresDe(
  List<Report> reportes, {
  required void Function(Report reporte) alTocarInfoWindow,
}) {
  final marcadores = <Marker>{};
  for (final reporte in reportes) {
    final coords = coordenadasDe(reporte);
    if (coords == null) continue;
    marcadores.add(Marker(
      markerId: MarkerId(reporte.id),
      position: coords,
      infoWindow: InfoWindow(
        title: reporte.titulo,
        snippet: '${reporte.estado} · ${reporte.zona}',
        onTap: () => alTocarInfoWindow(reporte),
      ),
    ));
  }
  return marcadores;
}
