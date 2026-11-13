// CiudadAlerta - Pruebas del CRUD y de las estadisticas (Clase 8 / Dia 8)
//
// Cubre las piezas nuevas del Dia 8 SIN red (regla del curso: las pruebas
// corren contra el mock; la BD real se prueba en el laboratorio):
//   1. HU-10 en modo demo: crear, actualizar y eliminar contra el mock.
//   2. HU-09: el filtro por categoria del repositorio.
//   3. HU-13: los agregados GROUP BY (categoria y estado) del mock.
//   4. Mapeo de la fila de Supabase -> Report (filaAReporte) y el
//      formateo de timestamptz -> texto legible.
//   5. El grafico siempre incluye las 5 categorias del catalogo (LEFT
//      JOIN: las que no tienen reportes cuentan 0).
//
// Comandos: fvm flutter test test/crud_demo_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/data/estadistica.dart';
import 'package:ciudadalerta/data/mock_reports.dart';
import 'package:ciudadalerta/data/reports_repository.dart';
import 'package:ciudadalerta/data/supabase_reports_repository.dart';

void main() {
  group('HU-10 en modo demo: CRUD contra el mock', () {
    test('crearReporte inserta RPT-009 y lo devuelve con estado Recibido',
        () async {
      final repo = MockReportsRepository();

      final creado = await repo.crearReporte(
        titulo: 'Basura acumulada en la calle Murillo',
        categoria: 'Residuos',
        descripcion: 'El contenedor lleva una semana sin vaciarse.',
        zona: 'Miraflores, La Paz',
      );

      expect(creado.id, 'RPT-009');
      expect(creado.estado, 'Recibido');
      expect(creado.categoria, 'Residuos');

      final lista = await repo.obtenerReportes();
      expect(lista.length, 9); // 8 del mock + 1 creado
      expect(lista.first.id, 'RPT-009'); // el nuevo aparece primero
    });

    test('actualizarReporte cambia titulo y descripcion del reporte',
        () async {
      final repo = MockReportsRepository();

      await repo.actualizarReporte(
        'RPT-002',
        titulo: 'Luminaria apagada en la calle Illampu (tercera vez)',
        descripcion: 'Reporte actualizado con mas detalle del tramo oscuro.',
      );

      final editado = repo.buscarPorId('RPT-002')!;
      expect(editado.titulo, contains('tercera vez'));
      expect(editado.descripcion, contains('tramo oscuro'));
      expect(editado.categoria, 'Luminaria'); // la FK no cambia en la edicion
    });

    test('eliminarReporte quita el reporte y deja los demas intactos',
        () async {
      final repo = MockReportsRepository();

      await repo.eliminarReporte('RPT-006');

      expect(repo.buscarPorId('RPT-006'), isNull);
      final lista = await repo.obtenerReportes();
      expect(lista.length, 7);
      expect(lista.any((r) => r.id == 'RPT-001'), isTrue);
    });

    test('actualizar un id inexistente falla con mensaje claro', () async {
      final repo = MockReportsRepository();

      expect(
        () => repo.actualizarReporte('RPT-999', titulo: 'No existe'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('HU-09: filtro por categoria y orden', () {
    test('el filtro Residuos devuelve solo los 2 reportes de residuos',
        () async {
      final repo = MockReportsRepository();

      final filtrados = await repo.obtenerReportes(categoria: 'Residuos');

      expect(filtrados.length, 2);
      expect(filtrados.every((r) => r.categoria == 'Residuos'), isTrue);
    });

    test('el filtro Todas equivale a la consulta sin WHERE (8 reportes)',
        () async {
      final repo = MockReportsRepository();

      final todas = await repo.obtenerReportes(categoria: 'Todas');
      final sinFiltro = await repo.obtenerReportes();

      expect(todas.length, 8);
      expect(sinFiltro.length, todas.length);
    });
  });

  group('HU-13: agregados GROUP BY (categoria y estado)', () {
    test('estadisticasPorCategoria replica el C06 del Dia 7 (2/2/2/1/1)',
        () async {
      final repo = MockReportsRepository();

      final stats = await repo.estadisticasPorCategoria();
      final porNombre = {
        for (final s in stats) s.categoria: s.total,
      };

      expect(porNombre['Via'], 2);
      expect(porNombre['Luminaria'], 2);
      expect(porNombre['Residuos'], 2);
      expect(porNombre['Riesgo'], 1);
      expect(porNombre['Agua'], 1);
      expect(stats.fold<int>(0, (a, s) => a + s.total), 8);
    });

    test('estadisticasPorEstado cuenta los 4 estados del curso', () async {
      final repo = MockReportsRepository();

      final estados = await repo.estadisticasPorEstado();
      final porEstado = {for (final e in estados) e.estado: e.total};

      expect(porEstado['Recibido'], 3);
      expect(porEstado['En revision'], 2);
      expect(porEstado['En proceso'], 2);
      expect(porEstado['Resuelto'], 1);
    });

    test('agruparPorCategoria conserva el catalogo completo (LEFT JOIN)',
        () {
      // Solo Via y Agua aparecen: las otras 3 categorias deben contar 0,
      // igual que el LEFT JOIN desde categories del Dia 7.
      final stats = agruparPorCategoria(
        const [(categoria: 'Via'), (categoria: 'Agua'), (categoria: 'Via')],
        categorias: categoriasCiudadAlerta,
      );

      final porNombre = {for (final s in stats) s.categoria: s.total};
      expect(porNombre.length, 5); // las 5 categorias SIEMPRE
      expect(porNombre['Luminaria'], 0);
      expect(porNombre['Residuos'], 0);
      expect(porNombre['Riesgo'], 0);
      expect(porNombre.first.categoria, 'Via'); // la mayor va primero
    });
  });

  group('Mapeo de la fila de Supabase -> Report', () {
    test('filaAReporte resuelve el select anidado categories(nombre)',
        () {
      final fila = <String, dynamic>{
        'id': 'a1b2c3d4-0000-1111-2222-333333333333',
        'codigo': 'RPT-001',
        'titulo': 'Bache profundo en la Av. Buenos Aires',
        'descripcion': 'Bache de aproximadamente 1 metro.',
        'estado': 'Recibido',
        'zona': 'Miraflores, La Paz',
        'urgente': true,
        'creado_en': '2026-11-03T08:15:00-04:00',
        'categories': {'nombre': 'Via'},
      };

      final reporte = SupabaseReportsRepository.filaAReporte(fila);

      expect(reporte.id, 'RPT-001'); // codigo legible sobre el uuid
      expect(reporte.categoria, 'Via'); // del JOIN embebido, no de texto
      expect(reporte.urgente, isTrue);
    });

    test('fila sin categories anidado cae en Sin categoria (sin crash)',
        () {
      final fila = <String, dynamic>{
        'id': 'uuid-x',
        'codigo': 'RPT-999',
        'titulo': 'Reporte de prueba',
        'descripcion': 'Sin categoria en el JSON anidado.',
        'estado': 'Recibido',
        'zona': 'La Paz',
        'urgente': false,
        'creado_en': null,
        'categories': null,
      };

      final reporte = SupabaseReportsRepository.filaAReporte(fila);

      expect(reporte.categoria, 'Sin categoria');
      expect(reporte.fecha, '—'); // sin creado_en no rompe la UI
    });

    test('fechaLegible convierte timestamptz ISO a dd/mm/aaaa hh:mm', () {
      expect(
        SupabaseReportsRepository.fechaLegible('2026-11-03T08:15:00-04:00'),
        '03/11/2026 08:15',
      );
      expect(SupabaseReportsRepository.fechaLegible(null), '—');
      expect(SupabaseReportsRepository.fechaLegible('no-es-fecha'), 'no-es-fecha');
    });
  });
}
