// CiudadAlerta - Pruebas del Dia 6 (Clase 6)
// Cubre las dos piezas nuevas del Sprint 2:
//   1. HU-07: borradores con shared_preferences (persisten, se restauran,
//      se limpian).
//   2. Capa repositorio + Riverpod: MockReportsRepository y el
//      reportesProvider (AsyncValue con datos).
//
// Clave de las pruebas sin dispositivo:
//   SharedPreferences.setMockInitialValues({}) registra un mock del canal
//   de plataforma: SharedPreferences.getInstance() funciona en tests.
//   El repositorio mock tarda 600 ms: para el provider usamos pumpAndSettle
//   dentro de testWidgets (zone de async del framework de pruebas).
//
// Comandos: fvm flutter test test/draft_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/data/draft_store.dart';
import 'package:ciudadalerta/data/mock_reports.dart';
import 'package:ciudadalerta/data/reports_repository.dart';
import 'package:ciudadalerta/providers/reports_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HU-07: borradores con shared_preferences', () {
    setUp(() {
      // Mock del canal de plataforma: cada prueba arranca con storage vacio
      SharedPreferences.setMockInitialValues({});
    });

    test('un borrador recien creado esta vacio y no debe restaurarse', () async {
      final store = DraftStore();
      final borrador = await store.cargar();
      expect(borrador.vacio, isTrue,
          reason: 'Sin datos guardados, el formulario NO debe restaurarse');
    });

    test('el borrador se guarda, se restaura igual y persiste', () async {
      final store = DraftStore();
      await store.guardar(const BorradorReporte(
        titulo: 'Fuga de agua en la calle Murillo',
        categoria: 'Agua',
        descripcion: 'La fuga lleva dos dias y inunda la vereda.',
      ));

      // "Reinicio" de la app: nueva instancia que lee el mismo storage
      final restaurado = await store.cargar();
      expect(restaurado.vacio, isFalse);
      expect(restaurado.titulo, 'Fuga de agua en la calle Murillo');
      expect(restaurado.categoria, 'Agua');
      expect(restaurado.descripcion,
          'La fuga lleva dos dias y inunda la vereda.');
    });

    test('limpiar() borra el borrador tras el envio exitoso', () async {
      final store = DraftStore();
      await store.guardar(const BorradorReporte(
        titulo: 'Luminaria apagada en Miraflores',
        categoria: 'Luminaria',
        descripcion: 'La cuadra entera esta a oscuras desde el lunes.',
      ));
      await store.limpiar();

      final borrador = await store.cargar();
      expect(borrador.vacio, isTrue,
          reason: 'Al enviar con exito el borrador ya no debe existir');
    });
  });

  group('Arquitectura por capas: repositorio y provider', () {
    test('MockReportsRepository devuelve los 8 reportes y busca por id',
        () async {
      const repo = MockReportsRepository();

      final reportes = await repo.obtenerReportes();
      expect(reportes.length, 8);
      expect(reportes.first.id, 'RPT-001');

      final encontrado = repo.buscarPorId('RPT-001');
      expect(encontrado, isNotNull);
      expect(encontrado!.titulo, contains('Bache'));

      // Contrato null-safe: id inexistente devuelve null (HU-04)
      expect(repo.buscarPorId('RPT-999'), isNull);
    });

    testWidgets('reportesProvider expone los datos via AsyncValue',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Primera lectura: cargando (el mock tarda 600 ms)
      container.listen(reportesProvider, (_, __) {});
      expect(container.read(reportesProvider), isA<AsyncLoading<List<Report>>>());

      // El framework de pruebas y pumpAndSettle esperan el Future del mock
      await tester.pumpAndSettle();

      final valor = container.read(reportesProvider);
      expect(valor, isA<AsyncData<List<Report>>>());
      expect(valor.value!.length, 8);
    });
  });
}
