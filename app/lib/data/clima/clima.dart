// CiudadAlerta - Modelo del clima (Día 11 / Sprint 3)
//
// Primera pieza del Hito 3: la app aprende a CONSUMIR APIs REST externas.
// La API elegida para el debut es Open-Meteo (https://open-meteo.com):
//   - PÚBLICA y gratuita para uso no comercial: NO exige API key, por eso
//     es perfecta para la primera demo (cero secretos, cero facturación).
//   - Devuelve JSON; cuando pedimos `&current=...` trae la sección
//     "current" con la temperatura, el código de clima (WMO) y el viento.
//
// La regla del día: la app NUNCA parsea JSON suelto dentro de las
// pantallas. El modelo centraliza el fromJson (igual que Report lo hace
// desde el Día 2) y la UI solo recibe objetos tipados.

/// Estado del clima en la sede del proyecto (La Paz / El Alto).
class Clima {
  final double temperatura; // °C
  final int codigo;         // código WMO de Open-Meteo (0 = despejado, 61 = lluvia...)
  final double vientoKmh;   // km/h
  final DateTime hora;      // hora local que reporta la API

  const Clima({
    required this.temperatura,
    required this.codigo,
    required this.vientoKmh,
    required this.hora,
  });

  /// fromJson de Open-Meteo. La respuesta real llega anidada:
  /// {"latitude": -16.5, "current": {"temperature_2m": 12.4,
  ///  "weather_code": 2, "wind_speed_10m": 14.8, "time": "2026-..."}}
  /// La sección `current` puede venir ausente si la petición fue mal
  /// formada: en ese caso usamos valores neutros (deterioro elegante,
  /// no excepciones en cascada hacia la UI).
  factory Clima.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map<String, dynamic>?) ?? const {};
    return Clima(
      temperatura: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      codigo: (current['weather_code'] as num?)?.toInt() ?? -1,
      vientoKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      hora: DateTime.tryParse(current['time'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// toJson para la bitácora y la colección Postman del equipo:
  /// la misma estructura que devuelve la API, ya tipada.
  Map<String, dynamic> toJson() => {
        'current': {
          'time': hora.toIso8601String(),
          'temperature_2m': temperatura,
          'weather_code': codigo,
          'wind_speed_10m': vientoKmh,
        },
      };

  @override
  String toString() =>
      'Clima(${temperatura.toStringAsFixed(1)}°C, código $codigo, '
      'viento ${vientoKmh.toStringAsFixed(1)} km/h)';
}
