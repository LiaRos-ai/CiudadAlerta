// CiudadAlerta - Repositorio de reportes (Clase 6 -> 9)
// Sprint 2 (Hito 2): arquitectura por capas, conexion a la BD y ahora
// la evidencia fotografica ligada a la sesion del ciudadano.
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
// Dia 9 (HU-11): adjuntarFoto() registra el URL de la evidencia en la
// tabla report_photos y el detalle lo muestra como miniatura.
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
  /// FIX Día 14: el contrato pasa a Future. La interfaz del Día 6 lo
  /// declaró sincrónico porque el mock lo era; la implementación de
  /// Supabase (Día 8) devolvía Future y el contrato quedó A MEDIAS:
  /// dos implementaciones con tipos incompatibles no compilan juntas.
  Future<Report?> buscarPorId(String id);

  /// HU-10: crea, edita y elimina (CRUD). Crear devuelve el Report con
  /// sus datos finales (id/codigo/fecha generados).
  /// Dia 13 (HU-15): latitud/longitud opcionales del GPS del ciudadano;
  /// null = reporte sin ubicación (el contrato de los Días 7-12 intacto).
  Future<Report> crearReporte({
    required String titulo,
    required String categoria,
    required String descripcion,
    required String zona,
    bool urgente = false,
    double? latitud,
    double? longitud,
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

  /// Dia 9 (HU-11): registra la evidencia fotografica del reporte.
  /// Recibe el URL publico que devuelve PhotoRepository.subirFoto(); en
  /// Supabase INSERTa en report_photos y en el mock actualiza la lista
  /// para que la miniatura del detalle aparezca al instante.
  Future<void> adjuntarFoto(String id, String urlFoto);

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
  Future<Report?> buscarPorId(String id) async => buscarReportePorId(id);

  @override
  Future<Report> crearReporte({
    required String titulo,
    required String categoria,
    required String descripcion,
    required String zona,
    bool urgente = false,
    // FIX Día 14: el cuerpo de esta firma YA usaba latitud/longitud
    // (el Día 13 añadió la referencia sin añadir el parámetro): con el
    // mock el reporte del modo demo nunca compiló. El contrato se
    // homologa: mismos parámetros opcionales en mock y Supabase.
    double? latitud,
    double? longitud,
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
      latitud: latitud,   // Dia 13 (HU-15): el modo demo también guarda
      longitud: longitud, // las coordenadas del GPS
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
      // Dia 13: TODO campo opcional debe sobrevivir a la reconstrucción
      // del mock (fotoUrl del Día 9 y coordenadas del Día 13).
      fotoUrl: viejo.fotoUrl,
      latitud: viejo.latitud,
      longitud: viejo.longitud,
    );
  }

  @override
  Future<void> eliminarReporte(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _datos.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> adjuntarFoto(String id, String urlFoto) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _datos.indexWhere((r) => r.id == id);
    if (i == -1) {
      throw StateError('No existe el reporte $id (modo demo)');
    }
    final viejo = _datos[i];
    _datos[i] = Report(
      id: viejo.id,
      titulo: viejo.titulo,
      categoria: viejo.categoria,
      descripcion: viejo.descripcion,
      fecha: viejo.fecha,
      estado: viejo.estado,
      zona: viejo.zona,
      urgente: viejo.urgente,
      fotoUrl: urlFoto, // HU-11: la miniatura ya tiene evidencia
      latitud: viejo.latitud,   // Dia 13: las coordenadas sobreviven
      longitud: viejo.longitud, // a la reconstrucción del mock
    );
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
