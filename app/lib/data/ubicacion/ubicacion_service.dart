// CiudadAlerta - Servicio de ubicación (Día 13 / Sprint 3, HU-15)
//
// "Como ciudadano quiero ver mi ubicación actual en el mapa y que el
// reporte se cree en el lugar donde estoy".
//
// Tres reglas de la clase:
//   1. El permiso se pide EN CONTEXTO (justo cuando la función lo
//      necesita), nunca al abrir la app: consentimiento informado.
//   2. deniedForever NO es un error: es un estado. La app abre Ajustes
//      (openAppSettings) y sigue funcionando SIN ubicación (deterioro
//      elegante del Día 11 aplicado al mundo físico).
//   3. La lógica pura (distancias y mensajes) vive AQUÍ, probada sin
//      GPS; la pantalla solo llama al servicio.
//
// Precisión y batería: getCurrentPosition usa LocationAccuracy.high
// para la lectura PUNTUAL del reporte (una medición con tope de
// tiempo); el punto azul del mapa NO abre un stream continuo: la app
// no rastrea al ciudadano, lo ubica cuando él lo pide.

import 'package:geolocator/geolocator.dart';

class UbicacionService {
  const UbicacionService();

  /// Pregunta 1: ¿el hardware está encendido?
  Future<bool> servicioActivo() => Geolocator.isLocationServiceEnabled();

  /// Pregunta 2: ¿la app puede usar la ubicación?
  /// PIDE EN CONTEXTO: si el permiso estaba 'denied', esta llamada
  /// levanta el diálogo del sistema; si el usuario ya dijo "nunca",
  /// devuelve false (la pantalla abre Ajustes, no insiste).
  Future<bool> permisoConcedido() async {
    if (!await servicioActivo()) return false;
    var estado = await Geolocator.checkPermission();
    if (estado == LocationPermission.denied) {
      estado = await Geolocator.requestPermission();
    }
    return estado == LocationPermission.whileInUse ||
        estado == LocationPermission.always;
  }

  /// ¿El usuario eligió "no volver a preguntar"? La pantalla decide si
  /// ofrece abrir Ajustes (openAppSettings) — nunca insiste en loop.
  Future<bool> denegadoParaSiempre() async =>
      await Geolocator.checkPermission() == LocationPermission.deniedForever;

  /// Pregunta 3: ¿dónde estoy? UNA lectura puntual con tope de tiempo:
  /// en interiores el GPS puede tardar demasiado; con timeLimit la app
  /// avisa y sigue sin ubicación (nunca bloquea el formulario).
  Future<Position?> posicionActual() async {
    if (!await permisoConcedido()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {
      return null; // timeout o sensor ocupado: deterioro elegante
    }
  }
}

// ------------------------------------------------------------ lógica pura
// Probable sin GPS: Geolocator.distanceBetween es matemática pura
// (haversine), por eso la prueba no necesita un dispositivo.

/// Distancia en metros entre dos coordenadas (la usa el proyecto
/// paralelo: "la parada/centro/negocio más cercano").
double distanciaA({
  required double latOrigen,
  required double lngOrigen,
  required double latDestino,
  required double lngDestino,
}) =>
    Geolocator.distanceBetween(
        latOrigen, lngOrigen, latDestino, lngDestino);

/// 842.0 -> "842 m" ; 1680.0 -> "1.7 km" (lo que entiende un ciudadano).
String distanciaLegible(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  return '${(metros / 1000).toStringAsFixed(1)} km';
}

/// Mensaje según el estado del permiso (el widget solo lo muestra).
String mensajePermiso(bool servicioActivo, bool denegadoSiempre) {
  if (!servicioActivo) return 'El GPS del dispositivo está apagado.';
  if (denegadoSiempre) {
    return 'La ubicación está bloqueada para esta app. Actívala en '
        'Ajustes > Aplicaciones > CiudadAlerta > Permisos.';
  }
  return 'Sin permiso de ubicación: el reporte se crea sin coordenadas.';
}
