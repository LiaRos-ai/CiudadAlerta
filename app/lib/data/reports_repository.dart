// CiudadAlerta - Repositorio de reportes (Clase 6 -> 8)
// Sprint 2 (Hito 2): arquitectura por capas y conexion a la BD.
//
// Capas del curso:
//   UI (screens/widgets)  ->  providers (Riverpod)  ->  repositorio  ->  datos
//
// Regla de dependencias: la UI NUNCA llama a los datos directamente;
// el repositorio es la UNICA puerta de entrada a los datos y expone
// funciones async.
//
// Dia 8: la interfaz crece con el CRUD y las estadisticas que piden
// HU-09/HU-10/HU-13. Dos implementaciones, UNA interfaz:
//
//   MockReportsRepository        -> modo demo sin credenciales (lista en
//                                   memoria con sus 8 reportes RPT-001..008;
//                                   el CRUD vive y muere con el proceso)
//   SupabaseReportsRepository    -> la API REST autogenerada por Supabase
//                                   (dia 7: schema.sql + seed.sql + RLS)
//
// El proveedor reportsRepositoryProvider decide cual usar segun existan
// las variables --dart-define=SUPABASE_URL / SUPABASE_ANON_KEY.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'estadistica.dart';
import 'mock_reports.dart';
import 'report.dart';
import 'supabase_config.dart';
import 'supabase_reports_repository.dart';

/// Contrato de la capa de datos para reportes.
/// El resto de la app solo conoce esta interfaz, no el origen real.
abstract class ReportsRepository {
  /// Lista de reportes con filtro opcional por categoria y orden por
  /// fecha descendente (HU-09).
  Future<List<Report>> obtenerReportes({String? categoria});

  /// Busqueda puntual por id/codigo. Devuelve null si no existe: la UI
  /// decide como mostrar ese caso (HU-04).
  Report? buscarPorId(String id);

  /// HU-10: crea, edita y elimina (CRUD). Crear devuelve el Report con
  /// sus datos finales (id/codigo/fecha generados).
  Future<Report> crearReporte({
    required String titulo,
    required String categoria,
    required String descripcion,
    required String zona,
    bool urgente = false,
  });

  Future<void> actualizarReporte(
    String id, {
    String? titulo,
    String? descripcion,
    String? zona,
    String? estado,
    bool? urgente,
  });

  Future<void> eliminarReporte(String id);

  /// HU-13: agregados para la pantalla de estadisticas (GROUP BY).
  Future<List<EstadisticaCategoria>> estadisticasPorCategoria();
  Future<List<EstadisticaEstado>> estadisticasPorEstado();
}

/// Implementacion mock (Sprint 1 / modo demo): misma latencia de 600 ms
/// y ahora tambien CRUD en memoria, para que la demo del Dia 8 funcione
/// sin credenciales. Los cambios viven en una copia editable: el mock
/// original const se preserva intacto.
class MockReportsRepository implements ReportsRepository {
  MockReportsRepository() : _datos = List.of(reportesMock);

  final List<Report> _datos;

  @override
  Future<List<Report>> obtenerReportes({String? categoria}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    Iterable<Report> resultado = _datos;
    if (categoria != null && categoria != 'Todas') {
      resultado = resultado.where((r) => r.categoria == categoria);
    }
    final lista = resultado.toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha)); // mock: fecha texto
    return lista;
  }

  @override
  Report? buscarPorId(String id) => buscarReportePorId(id);

  @override
  Future<Report> crearReporte({
    required String titulo,
    required String categoria,
    required String descripcion,
    required String zona,
    bool urgente = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final numero = _datos.length + 1;
    final nuevo = Report(
      id: 'RPT-${numero.toString().padLeft(3, '0')}',
      titulo: titulo,
      categoria: categoria,
      descripcion: descripcion,
      fecha: 'hoy',
      estado: 'Recibido',
      zona: zona,
      urgente: urgente,
    );
    _datos.insert(0, nuevo);
    return nuevo;
  }

  @override
  Future<void> actualizarReporte(
    String id, {
    String? titulo,
    String? descripcion,
    String? zona,
    String? estado,
    bool? urgente,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final i = _datos.indexWhere((r) => r.id == id);
    if (i == -1) {
      throw StateError('No existe el reporte $id (modo demo)');
    }
    final viejo = _datos[i];
    _datos[i] = Report(
      id: viejo.id,
      titulo: titulo ?? viejo.titulo,
      categoria: viejo.categoria,
      descripcion: descripcion ?? viejo.descripcion,
      fecha: viejo.fecha,
      estado: estado ?? viejo.estado,
      zona: zona ?? viejo.zona,
      urgente: urgente ?? viejo.urgente,
    );
  }

  @override
  Future<void> eliminarReporte(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _datos.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<EstadisticaCategoria>> estadisticasPorCategoria() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return agruparPorCategoria(
      [for (final r in _datos) (categoria: r.categoria)],
      categorias: categoriasCiudadAlerta,
    );
  }

  @override
  Future<List<EstadisticaEstado>> estadisticasPorEstado() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return agruparPorEstado(
      [for (final r in _datos) (estado: r.estado)],
      estados: estadosCiudadAlerta,
    );
  }
}

/// Provider del repositorio (Riverpod).
/// La linea que el Dia 6 prometio cambiar: si hay credenciales compiladas
/// (--dart-define), la app habla con Supabase; si no, modo demo con mock.
/// NINGUNA pantalla cambia en ninguno de los dos casos.
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  if (cliente != null) {
    return SupabaseReportsRepository(cliente);
  }
  return MockReportsRepository(); // modo demo sin credenciales
});
