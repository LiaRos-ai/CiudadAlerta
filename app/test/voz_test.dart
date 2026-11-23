// CiudadAlerta - Pruebas del Día 14 (voz y avisos de estado)
// Lógica pura de voz_service.dart y aviso_estado.dart: sin micrófono,
// sin motor TTS y sin Firebase — la misma política del curso desde el
// Día 5: la prueba no depende del hardware (el GPS del Día 13 tampoco
// entró a las pruebas; su LÓGICA sí).
import 'package:flutter_test/flutter_test.dart';

import 'package:ciudadalerta/data/notificaciones/aviso_estado.dart';
import 'package:ciudadalerta/data/voz/voz_service.dart';

void main() {
  group('HU-16 · dictado por voz (lógica pura)', () {
    test('limpiarTranscripcion recorta, colapsa espacios y capitaliza', () {
      expect(limpiarTranscripcion('  bache   grande en  la avenida  '),
          'Bache grande en la avenida');
    });

    test('limpiarTranscripcion devuelve vacío para ruido o silencio', () {
      expect(limpiarTranscripcion('   '), isEmpty);
      expect(limpiarTranscripcion(''), isEmpty);
    });

    test('transcripcionSuficiente usa la MISMA regla de 10 del validador '
        'HU-05', () {
      expect(transcripcionSuficiente('Bache'), isFalse); // 5 caracteres
      expect(transcripcionSuficiente('123456789'), isFalse); // justo 9
      expect(transcripcionSuficiente('Bache en la Av. Buenos Aires'),
          isTrue);
      expect(transcripcionSuficiente('1234567890'), isTrue); // justo 10
    });

    test('localeTts elige el mejor español instalado y respalda con es', () {
      expect(localeTts(['en_US', 'es_MX', 'es_ES']), 'es_MX');
      expect(localeTts(['en_US']), isNull); // enumeró y no hay español
      expect(localeTts([]), 'es'); // motor sin enumerar: candidato base
    });

    test('textoParaLeer arma la locución del detalle (HU-19)', () {
      final texto = textoParaLeer(
        codigo: 'RPT-001',
        titulo: 'Bache en la Av. Buenos Aires',
        estado: 'Recibido',
        zona: 'Miraflores',
        descripcion: 'Hundimiento de 40 cm frente al mercado.',
      );
      expect(texto, contains('Reporte RPT-001'));
      expect(texto, contains('Estado: Recibido'));
      expect(texto, contains('Zona: Miraflores'));
      expect(texto, contains('Hundimiento de 40 cm frente al mercado.'));
    });
  });

  group('HU-17 · aviso de cambio de estado (lógica pura)', () {
    test('el ciclo avanza Recibido -> En proceso -> Resuelto', () {
      expect(siguienteEstado('Recibido'), 'En proceso');
      expect(siguienteEstado('En proceso'), 'Resuelto');
      expect(siguienteEstado('Resuelto'), 'Recibido'); // el ciclo da la vuelta
      expect(siguienteEstado('Estado inventado'), isNull);
    });

    test('el cuerpo del aviso menciona ambos estados con el título', () {
      final cuerpo = cuerpoAvisoEstado(
        titulo: 'Bache en la Av. Buenos Aires',
        estadoAnterior: 'Recibido',
        estadoNuevo: 'En proceso',
      );
      expect(cuerpo, contains('Bache en la Av. Buenos Aires'));
      expect(cuerpo, contains('de Recibido a En proceso'));
    });

    test('mereceAviso exige reporte PROPIO y cambio REAL (anti-spam)', () {
      expect(
          mereceAviso(
              propio: true, antes: 'Recibido', despues: 'En proceso'),
          isTrue);
      expect(
          mereceAviso(
              propio: true, antes: 'En proceso', despues: 'En proceso'),
          isFalse); // sin cambio real: nada que avisar
      expect(
          mereceAviso(
              propio: false, antes: 'Recibido', despues: 'En proceso'),
          isFalse); // reporte ajeno: nunca avisa
    });
  });
}
