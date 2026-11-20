// CiudadAlerta - Ruta hacia un reporte (Día 13 / Sprint 3, HU-20)
//
// "Como ciudadano quiero una ruta hacia el reporte para llegar al
// problema y verificarlo" (HU-20).
//
// Decisión de costo de la clase: Directions / Routes API dibuja la
// ruta DENTRO del mapa con geometría y duración, pero cobra por
// solicitud. El laboratorio usa la alternativa de costo CERO:
// url_launcher abre la app de Google Maps (o el navegador) con la URL
// universal dir/?api=1 — Google Maps hace la navegación, la app solo
// construye el enlace. La polilínea embebida con Directions API queda
// como extensión del Hito 4 (con su costo medido en el Informe 3).

/// URL universal de Google Maps para la ruta (lógica pura, sin red).
/// Con origen: ruta desde donde está el ciudadano hasta el reporte.
/// Sin origen (permiso negado o GPS apagado): Google Maps centra en el
/// destino y el usuario mueve el punto de partida — nunca un crash.
String urlRuta({
  required double destinoLat,
  required double destinoLng,
  double? origenLat,
  double? origenLng,
  String modo = 'walking', // walking | driving | transit | bicycling
}) {
  final destino = '$destinoLat,$destinoLng';
  if (origenLat == null || origenLng == null) {
    return 'https://www.google.com/maps/dir/?api=1'
        '&destination=$destino&travelmode=$modo';
  }
  final origen = '$origenLat,$origenLng';
  return 'https://www.google.com/maps/dir/?api=1'
      '&origin=$origen&destination=$destino&travelmode=$modo';
}
