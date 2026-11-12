// CiudadAlerta - Contrato de datos app <-> BD (Clase 7 / Dia 7)
//
// Desde el Dia 7 la base de datos tiene su seed (db/seed.sql) que replica
// los 8 reportes del mock. Este test verifica el CONTRATO entre la app y la
// BD: si alguien cambia una categoria en un lado y no en el otro, esta
// prueba lo detecta antes que el usuario del Dia 8 (HU-09/HU-10).
//
// Regla que enseña: la app y la BD deben hablar el MISMO idioma
// (mismas categorias, mismos estados, mismos códigos de reporte).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/data/mock_reports.dart';

void main() {
  // Localiza db/seed.sql desde la raíz del paquete (app/) o un nivel arriba
  // (repo raíz), según desde dónde corra `flutter test`.
  File localizarSeed() {
    final candidatos = [
      File('db/seed.sql'),           // si el cwd fuera la raiz del repo
      File('../db/seed.sql'),        // cwd tipico de `flutter test` = app/
    ];
    for (final f in candidatos) {
      if (f.existsSync()) return f;
    }
    fail('No se encontro db/seed.sql: el contrato app-BD debe versionarse');
  }

  group('Contrato de categorias app <-> BD (seed.sql)', () {
    test('las 5 categorias de la app existen como filas en el seed', () {
      final seed = localizarSeed().readAsStringSync();
      for (final categoria in categoriasCiudadAlerta) {
        expect(seed.contains(categoria), isTrue,
            reason: 'La categoria "$categoria" de la app falta en db/seed.sql');
      }
    });

    test('los 5 estados del curso existen en el schema (check) o el seed', () {
      final schema = File('../db/schema.sql').readAsStringSync();
      for (final estado in estadosCiudadAlerta) {
        expect(schema.contains("'$estado'") || seedContiene(estado), isTrue,
            reason: 'El estado "$estado" de la app no aparece en la BD');
      }
    });

    test('el seed replica los 8 codigos de reporte del mock (RPT-001..008)',
        () {
      final seed = localizarSeed().readAsStringSync();
      for (final r in reportesMock) {
        expect(seed.contains(r.id), isTrue,
            reason: 'El reporte ${r.id} (${r.titulo}) no esta en el seed');
      }
      expect(reportesMock.length, 8);
    });
  });
}

bool seedContiene(String estado) {
  final f = File('../db/seed.sql');
  return f.existsSync() && f.readAsStringSync().contains("'$estado'");
}
