// CiudadAlerta - Pruebas del Día 13: ubicación, geocoding y rutas.
// La lógica pura se prueba SIN GPS y SIN red: Geolocator.distanceBetween
// es matemática pura, el geocoder es inyectable y la URL de la ruta es
// una función de texto. La captura real se demuestra en el dispositivo
// (la evidencia oficial del día es la demo en dispositivo físico).

import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

import 'package:ciudadalerta/data/ubicacion/geocoding_service.dart';
import 'package:ciudadalerta/data/ubicacion/ruta.dart';
import 'package:ciudadalerta/data/ubicacion/ubicacion_service.dart';

void main() {
  group('distancia y su lectura (lógica pura)', () {
    test('distanciaA entre Miraflores y El Prado ronda el kilómetro y medio',
        () {
      final metros = distanciaA(
        latOrigen: -16.4993, lngOrigen: -68.1190, // Miraflores
        latDestino: -16.5035, lngDestino: -68.1341, // El Prado
      );
      expect(metros, greaterThan(1000));
      expect(metros, lessThan(2500));
    });

    test('distanciaLegible alterna metros y kilómetros', () {
      expect(distanciaLegible(842.4), '842 m');
      expect(distanciaLegible(1680.0), '1.7 km');
    });
  });

  group('dirección legible (Placemark -> texto)', () {
    test('arma "calle, barrio, ciudad" y respalda sin calle', () {
      final completa = GeocodingService.direccionLegible(Placemark(
        thoroughfare: 'Calle Comercio',
        subLocality: 'Miraflores',
        locality: 'La Paz',
      ));
      expect(completa, 'Calle Comercio, Miraflores, La Paz');

      // Sin calle: el nombre del sitio y la ciudad rescatan la lectura.
      final sinCalle = GeocodingService.direccionLegible(Placemark(
        name: 'Estadio Hernando Siles',
        locality: 'La Paz',
      ));
      expect(sinCalle, 'Estadio Hernando Siles, La Paz');

      // Sin nada: mensaje honesto, nunca un crash.
      final vacia = GeocodingService.direccionLegible(Placemark());
      expect(vacia, 'Ubicación sin dirección');
    });

    test('el servicio cachea: la misma clave no vuelve a llamar al geocoder',
        () async {
      var llamadasFalsas = 0;
      final servicio = GeocodingService(resolver: (lat, lng) async {
        llamadasFalsas++;
        return [
          Placemark(
              thoroughfare: 'Av. Buenos Aires',
              subLocality: 'Miraflores',
              locality: 'La Paz'),
        ];
      });

      final primera =
          await servicio.direccionDe(latitud: -16.4993, longitud: -68.1190);
      // Segunda lectura con el jitter del GPS (~14 cm): misma clave de
      // caché (5 decimales), otra llamada NO.
      final jitter =
          await servicio.direccionDe(latitud: -16.4992987, longitud: -68.1190);

      expect(primera, 'Av. Buenos Aires, Miraflores, La Paz');
      expect(jitter, primera);
      expect(llamadasFalsas, 1); // el geocoder real se llamó UNA vez
      expect(servicio.llamadas, 1); // y el contador lo mide
    });
  });

  group('ruta hacia el reporte (HU-20, costo cero)', () {
    test('con origen incluye origin, destination y travelmode', () {
      final url = urlRuta(
        destinoLat: -16.4993,
        destinoLng: -68.1190,
        origenLat: -16.5035,
        origenLng: -68.1341,
      );
      expect(url, contains('dir/?api=1'));
      expect(url, contains('origin=-16.5035,-68.1341'));
      expect(url, contains('destination=-16.4993,-68.1190'));
      expect(url, contains('travelmode=walking'));
    });

    test('sin origen la URL solo lleva destination (nunca crash)', () {
      final url = urlRuta(destinoLat: -16.4993, destinoLng: -68.1190);
      expect(url, contains('dir/?api=1'));
      expect(url, contains('destination=-16.4993,-68.1190'));
      expect(url, isNot(contains('origin=')));
    });
  });
}
