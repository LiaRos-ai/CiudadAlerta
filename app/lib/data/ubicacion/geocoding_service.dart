// CiudadAlerta - Geocoding inverso con caché (Día 13 / Sprint 3, HU-15)
//
// "Como ciudadano quiero que el reporte muestre una dirección legible,
// no un par de números".
//
// Dos decisiones de la clase:
//   1. El geocoder del SISTEMA (paquete geocoding) es la primera
//      opción: corre en el dispositivo, sin API key y sin costo por
//      solicitud. La Geocoding API de Google es el plan B para
//      coberturas que el Geocoder del sistema no resuelve (y cobra
//      por solicitud con la cuenta del proyecto).
//   2. NUNCA se llama al geocoder en cada rebuild del widget: la
//      llamada vive en el servicio (cuando cambia el dato) y la caché
//      guarda el resultado por clave de coordenadas REDONDEADAS a 5
//      decimales (~1 metro). El contador de llamadas permite MEDIR el
//      ahorro: es la métrica que el trabajo autónomo del día reporta.

import 'package:geocoding/geocoding.dart';

class GeocodingService {
  GeocodingService({Future<List<Placemark>> Function(double, double)? resolver})
      // Inyectable para las pruebas: el falso resuelve sin GPS ni red.
      : _resolver = resolver ?? placemarkFromCoordinates;

  final Future<List<Placemark>> Function(double lat, double lng) _resolver;
  final Map<String, String> _cache = {};

  /// Métrica didáctica: cuántas veces preguntamos al geocoder de verdad.
  /// Con caché caliente esta cifra se queda baja.
  int llamadas = 0;

  /// Coordenadas -> dirección legible (null si el geocoder no responde).
  /// La clave formatea a 5 decimales: el jitter del GPS (centímetros)
  /// no dispara llamadas nuevas.
  Future<String?> direccionDe({
    required double latitud,
    required double longitud,
  }) async {
    final clave =
        '${latitud.toStringAsFixed(5)},${longitud.toStringAsFixed(5)}';
    final guardada = _cache[clave];
    if (guardada != null) return guardada;

    llamadas++;
    try {
      final placemarks = await _resolver(latitud, longitud);
      if (placemarks.isEmpty) return null;
      final direccion = direccionLegible(placemarks.first);
      _cache[clave] = direccion;
      return direccion;
    } catch (_) {
      return null; // sin servicio, sin permiso de red, sin datos: null
    }
  }

  /// Lógica PURA: Placemark -> texto para el ciudadano.
  /// "Calle Comercio, Miraflores, La Paz"; si el geocoder no trae
  /// calle, el nombre del sitio y la localidad rescatan la lectura.
  static String direccionLegible(Placemark p) {
    String? texto(String? v) {
      final t = v?.trim() ?? '';
      return t.isEmpty ? null : t;
    }

    final partes = [
      texto(p.thoroughfare) ?? texto(p.name),
      texto(p.subLocality),
      texto(p.locality),
    ].whereType<String>().toList();
    if (partes.isEmpty) return texto(p.street) ?? 'Ubicación sin dirección';
    return partes.join(', ');
  }
}
