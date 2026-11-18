// CiudadAlerta - Configuración de APIs externas (Día 11 / Sprint 3)
//
// Regla de seguridad heredada del Día 8 y extendida al Hito 3: las claves
// NUNCA viven en el código ni en el repositorio. Llegan por --dart-define
// en el momento del build/run:
//
//   fvm flutter run --dart-define=MAPS_API_KEY=AIza...
//
// Open-Meteo (la API de hoy) es pública y no exige key: su URL vive aquí
// con un valor por defecto para que la demo del Día 11 corra sin
// configurar nada. El Día 12 (HU-14, Google Maps) SOLO agrega MAPS_API_KEY
// y las restricciones en la consola de Google Cloud: el patrón ya existe.
//
// Verificación MASVS del curso: `git log -p` no debe mostrar ninguna
// clave real; el repo solo conoce el NOMBRE de la variable, no el valor.

class ApiConfig {
  /// Endpoint público de Open-Meteo (sin API key).
  final String openMeteoUrl;

  /// Clave de Google Maps Platform (Día 12 / HU-14). Null = aún no
  /// configurada: el mapa muestra su pantalla de espera, no un crash.
  final String? mapsApiKey;

  const ApiConfig.fromEnvironment()
      : openMeteoUrl = String.fromEnvironment(
          'OPEN_METEO_URL',
          defaultValue: 'https://api.open-meteo.com/v1/forecast',
        ),
        mapsApiKey = _mapsKeyOrNull();

  static String? _mapsKeyOrNull() {
    const key = String.fromEnvironment('MAPS_API_KEY');
    return key.isEmpty ? null : key;
  }
}

/// Sede del Proyecto Guía: centro de La Paz. El Día 13 (HU-15) el punto
/// será la ubicación REAL del ciudadano (geolocator); por ahora es una
/// constante documentada.
class SedeCiudadAlerta {
  static const double latitud = -16.4955;
  static const double longitud = -68.1336;
  static const String zonaHoraria = 'America/La_Paz';
}
