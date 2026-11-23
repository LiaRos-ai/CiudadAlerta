// CiudadAlerta - Estado global del clima (Día 11 / Sprint 3)
//
// El clima entra a la arquitectura por capas con el MISMO patrón que la
// lista de reportes desde el Día 6: la pantalla no llama al servicio,
// mira un provider (UI -> providers -> servicio -> API externa).
//
// Diferencia con reportesProvider: el clima NO es imprescindible. Si la
// API falla, la lista de reportes debe seguir funcionando; por eso la
// ClimaCard interpreta el AsyncValue con deterioro elegante y NO hay
// estados que bloqueen la navegación.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/api/api_config.dart';
import '../data/clima/clima.dart';
import '../data/clima/weather_service.dart';

/// Servicio de clima como dependencia inyectable (los tests lo
/// reemplazan con un MockClient; el widget nunca construye clientes).
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(
    client: http.Client(),
    config: ApiConfig.fromEnvironment(),
  );
});

/// Consulta del clima actual en la sede del Proyecto Guía.
/// La ClimaCard hace `ref.invalidate(climaActualProvider)` para reintentar.
final climaActualProvider = FutureProvider<Clima>((ref) async {
  final servicio = ref.watch(weatherServiceProvider);
  return servicio.obtenerClimaActual();
});
