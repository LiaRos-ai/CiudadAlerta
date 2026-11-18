// CiudadAlerta - Pruebas del mapa y de las coordenadas (Día 12 / Sprint 3)
//
// 6 pruebas nuevas (65 -> 71). Ninguna abre GoogleMap real (necesitaría
// platform channels y una clave): se prueba la LÓGICA PURA —marcadores,
// coordenadas y el contrato JSON extendido— y el PANEL SIN CLAVE del
// widget, que es Flutter puro. El mapa renderizado se demuestra en el
// emulador del laboratorio; los tests fijan el CONTRATO, como siempre
// en el curso.
//
// Importante para el equipo: los Marker/InfoWindow/LatLng de
// google_maps_flutter son clases de Dart corrientes; solo el RENDER
// necesita la plataforma. Por eso esta suite corre verde en CI.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ciudadalerta/data/mapa/marcadores.dart';
import 'package:ciudadalerta/data/report.dart';
import 'package:ciudadalerta/screens/mapa_screen.dart';

Report _reporte({
  String id = 'RPT-001',
  double? lat = -16.4993,
  double? lng = -68.1190,
}) =>
    Report(
      id: id,
      titulo: 'Bache profundo en la Av. Buenos Aires',
      categoria: 'Via',
      descripcion: 'Bache de aproximadamente 1 metro en el carril derecho.',
      fecha: '03/11/2026',
      estado: 'Recibido',
      zona: 'Miraflores, La Paz',
      urgente: true,
      latitud: lat,
      longitud: lng,
    );

void main() {
  group('Report: coordenadas opcionales (extensión del Día 9)', () {
    test('fromJson lee latitud y longitud numéricas de la BD', () {
      final r = Report.fromJson({
        'id': 'RPT-001',
        'titulo': 'Bache profundo en la Av. Buenos Aires',
        'categoria': 'Via',
        'descripcion': 'Bache de 1 metro.',
        'fecha': '03/11/2026',
        'estado': 'Recibido',
        'zona': 'Miraflores, La Paz',
        'urgente': true,
        'latitud': -16.4993,
        'longitud': -68.1190,
      });
      expect(r.latitud, -16.4993);
      expect(r.longitud, -68.1190);
    });

    test('toJson OMITE las coordenadas cuando son null (contrato Día 7 intacto)',
        () {
      final viejo = _reporte(lat: null, lng: null);
      final json = viejo.toJson();
      expect(json.containsKey('latitud'), isFalse);
      expect(json.containsKey('longitud'), isFalse);
      // Y cuando SÍ las tiene viajan con el nombre de la columna de Supabase.
      final nuevo = _reporte().toJson();
      expect(nuevo['latitud'], -16.4993);
      expect(nuevo['longitud'], -68.1190);
    });
  });

  group('marcadoresDe: de reportes a marcadores (HU-14)', () {
    test('crea un Marker por reporte con coords y MarkerId = id', () {
      final marcadores = marcadoresDe(
        [_reporte(id: 'RPT-001'), _reporte(id: 'RPT-002')],
        alTocarInfoWindow: (_) {},
      );
      expect(marcadores.length, 2);
      final ids = marcadores.map((m) => m.markerId.value).toList();
      expect(ids, containsAll(['RPT-001', 'RPT-002']));
      expect(marcadores.first.position.latitude, -16.4993);
      expect(marcadores.first.position.longitude, -68.1190);
    });

    test('excluye los reportes sin coordenadas sin romper los demás', () {
      final marcadores = marcadoresDe(
        [_reporte(id: 'RPT-001'), _reporte(id: 'RPT-009', lat: null, lng: null)],
        alTocarInfoWindow: (_) {},
      );
      expect(marcadores.length, 1);
      expect(marcadores.first.markerId.value, 'RPT-001');
    });

    test('InfoWindow: title = titulo, snippet = estado · zona y onTap entrega el reporte',
        () {
      Report? tocado;
      final marcadores = marcadoresDe(
        [_reporte(id: 'RPT-001')],
        alTocarInfoWindow: (r) => tocado = r,
      );
      final info = marcadores.first.infoWindow;
      expect(info.title, 'Bache profundo en la Av. Buenos Aires');
      expect(info.snippet, 'Recibido · Miraflores, La Paz');
      // El criterio de HU-14: la ventana emergente lleva al detalle.
      info.onTap!();
      expect(tocado?.id, 'RPT-001');
    });
  });

  group('MapaScreen sin MAPS_API_KEY (deterioro elegante)', () {
    testWidgets('muestra el panel de configuración y NO monta GoogleMap',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: MapaScreen()),
      ));
      await tester.pumpAndSettle();
      // El panel enseña el camino exacto (docs/51) en lugar de crashear.
      expect(find.textContaining('MAPS_API_KEY'), findsWidgets);
      expect(find.byType(GoogleMap), findsNothing);
    });
  });
}
