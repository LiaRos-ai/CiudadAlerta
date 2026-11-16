// CiudadAlerta - Pruebas de la evidencia fotografica (Clase 9 / Dia 9)
//
// Cubre HU-11 SIN dispositivo y SIN red (regla del curso):
//   1. validarImagen: formato (jpg/png/webp) y peso maximo (5 MB).
//   2. rutaDeFoto: la ruta determinista {usuario}/{codigo}-{nombre-seguro}
//      dentro del bucket (lo que la politica de Storage acota).
//   3. Normalizacion de nombres bolivianos con espacios y acentes.
//   4. MockPhotoRepository: el flujo async de subida devuelve un URL
//      publico coherente con la ruta.
//   5. La subida FALLA rapido si faltan datos (ArgumentError).
//
// La subida REAL a Supabase Storage se prueba en el laboratorio con los
// casos SP-09/SP-10 de docs/36-casos-prueba-seguridad.md.
//
// Comandos: fvm flutter test test/photo_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:ciudadalerta/data/photo_storage.dart';

void main() {
  group('validarImagen: formato y peso (fallar rapido, antes de subir)', () {
    test('acepta los formatos de foto del proyecto', () {
      expect(validarImagen('foto1.jpg'), isNull);
      expect(validarImagen('foto1.jpeg'), isNull);
      expect(validarImagen('foto1.PNG'), isNull, reason: 'mayusculas ok');
      expect(validarImagen('foto1.webp'), isNull);
    });

    test('rechaza formatos que no son foto', () {
      expect(validarImagen('documento.pdf'), isNotNull);
      expect(validarImagen('animacion.gif'), isNotNull);
      expect(validarImagen('sin-extension'), isNotNull);
    });

    test('rechaza fotos que superan 5 MB', () {
      const cincoMB = 5 * 1024 * 1024;
      expect(validarImagen('a.jpg', tamanoBytes: cincoMB), isNull);
      expect(validarImagen('a.jpg', tamanoBytes: cincoMB + 1), isNotNull,
          reason: 'una foto de 5MB+1 no pasa');
      expect(validarImagen('a.jpg', tamanoBytes: 2 * 1024 * 1024), isNull,
          reason: 'foto de camara tipica (2 MB) pasa');
    });
  });

  group('rutaDeFoto: ruta determinista dentro del bucket', () {
    test('arma usuario/codigo-nombre.ext', () {
      final ruta = rutaDeFoto(
        usuarioId: 'abc-123',
        codigoReporte: 'RPT-011',
        nombreArchivo: 'bache.jpg',
      );
      expect(ruta, 'abc-123/RPT-011-bache.jpg');
      expect(ruta.startsWith('abc-123/'), isTrue,
          reason: 'una carpeta por usuario: la politica de Storage la acota');
    });

    test('normaliza espacios y acentes (URLs sin %20 ni %C3)', () {
      final ruta = rutaDeFoto(
        usuarioId: 'u1',
        codigoReporte: 'RPT-001',
        nombreArchivo: 'Foto La Paz Ñ.jpg',
      );
      expect(ruta, 'u1/RPT-001-foto_la_paz_n.jpg');
      expect(ruta.contains(' '), isFalse);
      expect(ruta.contains('%'), isFalse);
    });

    test('rechaza datos vacios y formatos invalidos con ArgumentError',
        () {
      expect(
        () => rutaDeFoto(usuarioId: '', codigoReporte: 'RPT-001', nombreArchivo: 'a.jpg'),
        throwsArgumentError,
        reason: 'sin usuario no hay carpeta acotada',
      );
      expect(
        () => rutaDeFoto(usuarioId: 'u1', codigoReporte: '', nombreArchivo: 'a.jpg'),
        throwsArgumentError,
      );
      expect(
        () => rutaDeFoto(usuarioId: 'u1', codigoReporte: 'RPT-001', nombreArchivo: 'a.pdf'),
        throwsArgumentError,
      );
    });

    test('un nombre vacio tras normalizar queda como "foto"', () {
      final ruta = rutaDeFoto(
        usuarioId: 'u1',
        codigoReporte: 'RPT-002',
        nombreArchivo: '???.jpg',
      );
      expect(ruta, 'u1/RPT-002-foto.jpg');
    });
  });

  group('MockPhotoRepository: flujo async de subida en modo demo', () {
    test('subirFoto devuelve un URL publico coherente con la ruta', () async {
      final repo = MockPhotoRepository();
      final url = await repo.subirFoto(
        usuarioId: 'uid-9',
        codigoReporte: 'RPT-010',
        rutaLocal: '/cache/foto%20del%20bache.JPG',
      );
      expect(url, startsWith('https://demo.supabase.co/storage/v1/object/public/'));
      expect(url, contains('/$bucketFotos/'));
      expect(url, contains('uid-9/RPT-010-foto_del_bache.JPG'.toLowerCase()));
      expect(url.endsWith('.jpg'), isTrue, reason: 'extension normalizada');
    });

    test('el URL del demo no es null ni vacio y siempre incluye el bucket',
        () async {
      final repo = MockPhotoRepository();
      final url = await repo.subirFoto(
        usuarioId: 'uid-1',
        codigoReporte: 'RPT-001',
        rutaLocal: '/tmp/luminaria.png',
      );
      expect(url.isNotEmpty, isTrue);
      expect(url.contains(bucketFotos), isTrue);
    });
  });
}
