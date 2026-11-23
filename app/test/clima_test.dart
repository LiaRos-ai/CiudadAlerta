// CiudadAlerta - Pruebas del clima y de la configuración de APIs
// (Día 11 / Sprint 3)
//
// 6 pruebas nuevas (59 -> 65). Las tres del servicio usan el MockClient
// de package:http/testing.dart: sin red, sin sockets, sin Open-Meteo
// real. La API se PEROCA en Postman (Paso B del laboratorio); los tests
// solo fijan el CONTRATO (200/429/5xx -> mensajes amigables).
//
// Regla del curso: una pieza nueva llega a "Hecho" con pruebas, no con
// "funcionó una vez en el emulador".

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ciudadalerta/data/api/api_config.dart';
import 'package:ciudadalerta/data/clima/clima.dart';
import 'package:ciudadalerta/data/clima/weather_service.dart';

http.Response _json(Map<String, dynamic> body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

const _respuestaOpenMeteo = {
  'latitude': -16.5,
  'longitude': -68.15,
  'timezone': 'America/La_Paz',
  'current': {
    'time': '2026-11-15T09:30',
    'temperature_2m': 12.4,
    'weather_code': 2,
    'wind_speed_10m': 14.8,
  },
};

void main() {
  group('Modelo Clima: fromJson de Open-Meteo', () {
    test('parsea la sección current (temperatura, código WMO y viento)',
        () {
      final clima = Clima.fromJson(_respuestaOpenMeteo);
      expect(clima.temperatura, 12.4);
      expect(clima.codigo, 2); // parcialmente nublado
      expect(clima.vientoKmh, 14.8);
      expect(clima.hora, DateTime(2026, 11, 15, 9, 30));
    });

    test('tolera campos faltantes con valores neutros (deterioro elegante)',
        () {
      final clima = Clima.fromJson({'current': null});
      expect(clima.temperatura, 0.0);
      expect(clima.codigo, -1); // "clima desconocido" en el mapeo visual
      expect(clima.vientoKmh, 0.0);
    });
  });

  group('WeatherService con MockClient (sin red real)', () {
    test('HTTP 200 devuelve el Clima tipado', () async {
      final servicio = WeatherService(
        client: MockClient((_) async => _json(_respuestaOpenMeteo)),
      );
      final clima = await servicio.obtenerClimaActual();
      expect(clima.temperatura, 12.4);
      expect(clima.codigo, 2);
    });

    test('HTTP 429 (cuota agotada) lanza ApiException amigable', () async {
      final servicio = WeatherService(
        client: MockClient((_) async => _json({'error': true}, 429)),
      );
      expect(
        servicio.obtenerClimaActual(),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.message, 'message', contains('Cuota'))),
      );
    });

    test('HTTP 5xx (servidor caído) sugiere reintentar, no culpa al usuario',
        () async {
      final servicio = WeatherService(
        client: MockClient((_) async => _json({}, 503)),
      );
      expect(
        servicio.obtenerClimaActual(),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.message, 'message', contains('reintenta'))),
      );
    });
  });

  group('ApiConfig: claves fuera del repositorio', () {
    test('sin --dart-define no hay claves y la URL pública es Open-Meteo',
        () {
      final config = ApiConfig.fromEnvironment();
      expect(config.mapsApiKey, isNull,
          reason: 'Ninguna clave puede existir sin --dart-define');
      expect(config.openMeteoUrl, startsWith('https://api.open-meteo.com'));
      expect(config.openMeteoUrl, isNot(contains('apikey=')),
          reason: 'La URL pública jamás lleva credenciales');
    });
  });
}
