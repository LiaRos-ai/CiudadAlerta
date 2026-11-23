// CiudadAlerta - WeatherService: el primer cliente REST de la app
// (Día 11 / Sprint 3)
//
// Qué enseña este archivo:
//   1. El paquete `http` es el cliente REST más simple de Dart:
//      GET/POST/PUT/DELETE son métodos con la misma forma que el quiz
//      repasó al inicio de la clase.
//   2. Consumir una API es más que `get()`: hay que manejar el
//      TIMEOUT (la red del aula no siempre responde), los CÓDIGOS DE
//      ESTADO (200 vs 429 vs 5xx) y traducirlos a mensajes amigables.
//   3. El cliente se INYECTA (http.Client): así los tests usan un
//      MockClient sin abrir sockets reales (misma idea del repositorio
//      mock/Supabase del Día 8).
//
// Seguridad: Open-Meteo no exige API key, pero el servicio ya está
// escrito con ApiConfig para que las APIs del Día 12-15 (Maps, FCM,
// Lambda) reutilicen el mismo camino.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import 'clima.dart';

/// Error de una API externa traducido a lenguaje de usuario.
/// La UI solo necesita `message`; `statusCode` queda para la bitácora.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class WeatherService {
  final http.Client _client;
  final ApiConfig _config;
  final Duration timeout;

  WeatherService({
    http.Client? client,
    ApiConfig? config,
    this.timeout = const Duration(seconds: 8),
  })  : _client = client ?? http.Client(),
        _config = config ?? ApiConfig.fromEnvironment();

  /// La petición GET que probamos ANTES en Postman (Paso B del lab):
  /// query params por URL, sin cuerpo. La URL es reproducible: el mismo
  /// link abre en el navegador y en Postman y da el mismo JSON.
  Uri construirUrl({
    double latitud = SedeCiudadAlerta.latitud,
    double longitud = SedeCiudadAlerta.longitud,
  }) {
    return Uri.parse(_config.openMeteoUrl).replace(queryParameters: {
      'latitude': latitud.toStringAsFixed(4),
      'longitude': longitud.toStringAsFixed(4),
      'current': 'temperature_2m,weather_code,wind_speed_10m',
      'timezone': SedeCiudadAlerta.zonaHoraria,
    });
  }

  Future<Clima> obtenerClimaActual() async {
    final http.Response resp;
    try {
      resp = await _client.get(construirUrl()).timeout(timeout);
    } on TimeoutException {
      // La lección del Review 2: la app vive sin la función opcional.
      throw const ApiException(
          'El clima tardó demasiado y la app sigue sin él. Reintenta '
          'más tarde desde la tarjeta.');
    }
    return _interpretar(resp);
  }

  /// Los códigos de estado son el idioma de REST: la app los traduce
  /// a mensajes que un ciudadano entiende (quiz del día, preguntas 5-8).
  Clima _interpretar(http.Response resp) {
    if (resp.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      return Clima.fromJson(data);
    }
    if (resp.statusCode == 429) {
      throw const ApiException(
          'Cuota de la API agotada: se superó el límite de consultas '
          'gratis. Reintenta más tarde (el día 11 lo vimos en teoría).',
          statusCode: 429);
    }
    if (resp.statusCode >= 500) {
      throw ApiException(
          'La API del clima falló (HTTP ${resp.statusCode}). Es un '
          'problema del servidor, no de tu reporte: reintenta.',
          statusCode: resp.statusCode);
    }
    throw ApiException(
        'La API del clima respondió con HTTP ${resp.statusCode}.',
        statusCode: resp.statusCode);
  }
}
