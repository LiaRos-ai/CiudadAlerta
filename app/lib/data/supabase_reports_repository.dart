// CiudadAlerta - Repositorio de reportes contra Supabase (Clase 8 / Dia 8)
// Sprint 2 (Hito 2): CRUD y consultas contra PostgreSQL (HU-09, HU-10, HU-13).
//
// Promesa cumplida del Dia 6: "en el Dia 8 SupabaseReportsRepository
// implementara la MISMA interfaz y ninguna pantalla cambiara una linea".
// La interfaz ReportsRepository sigue siendo la unica puerta de datos;
// lo que cambia es la implementacion: de lista en memoria a la API REST
// autogenerada por Supabase (PostgREST).
//
// Mapa SQL del Dia 7 -> API del cliente supabase_flutter:
//
//   SELECT * FROM reports ORDER BY creado_en DESC
//     -> .select().order('creado_en', ascending: false)
//
//   WHERE categories.nombre = 'Residuos'   (filtro HU-09)
//     -> .eq('categories.nombre', categoria)   (filtro sobre la tabla anidada)
//
//   SELECT *, categories(nombre) FROM reports   (JOIN embebido)
//     -> .select('*, categories(nombre)')       (select anidado por FK)
//
//   INSERT / UPDATE / DELETE
//     -> .insert(map) / .update(map).eq(...) / .delete().eq(...)

import 'package:supabase_flutter/supabase_flutter.dart';

import 'estadistica.dart';
import 'report.dart';
import 'reports_repository.dart';

/// Implementacion remota del repositorio (Dia 8).
/// Implementa la MISMA interfaz que el mock: por eso ninguna pantalla
/// cambia una linea al pasar de datos simulados a PostgreSQL.
class SupabaseReportsRepository implements ReportsRepository {
  SupabaseReportsRepository(this._client);

  final SupabaseClient _client;

  /// HU-09: lista desde la BD con filtro por categoria y orden por fecha.
  ///
  /// El select anidado 'categories(nombre)' trae el nombre de la categoria
  /// por la FK categoria_id (el JOIN del Dia 7) sin copiar datos: 3FN.
  Future<List<Report>> obtenerReportes({String? categoria}) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> consulta = _client
        .from('reports')
        .select(
            'id, codigo, titulo, descripcion, estado, zona, urgente, '
            'creado_en, categories(nombre)')
        .order('creado_en', ascending: false);

    if (categoria != null && categoria != 'Todas') {
      consulta = consulta.eq('categories.nombre', categoria);
    }

    final filas = await consulta;
    return [for (final fila in filas) filaAReporte(fila)];
  }

  /// HU-04: busqueda puntual por codigo (WHERE codigo = X).
  /// Devuelve null si no existe: la UI decide como mostrar el caso.
  @override
  Future<Report?> buscarPorId(String id) async {
    final filas = await _client
        .from('reports')
        .select(
            'id, codigo, titulo, descripcion, estado, zona, urgente, '
            'creado_en, categories(nombre)')
        .eq('codigo', id)
        .limit(1);
    if (filas.isEmpty) return null;
    return filaAReporte(filas.first);
  }

  /// HU-10: crea un reporte (INSERT) y devuelve el Report ya mapeado.
  ///
  /// Dos pasos honestos del curso: (1) el formulario habla de "Residuos"
  /// (nombre), pero la BD guarda categoria_id smallint (3FN): se resuelve
  /// con una consulta al catalogo; (2) .select() detras del insert hace
  /// RETURNING: la fila vuelve con el id uuid, el codigo y el creado_en.
  ///
  /// El autor es hoy el usuario semilla del Dia 7 (perfil demo); el Dia 9
  /// (HU-08) auth.uid() lo sustituye por el usuario logueado.
  static const String usuarioDemoId =
      '11111111-1111-1111-1111-111111111101'; // Rosa Quispe (seed.sql)

  Future<Report> crearReporte({
    required String titulo,
    required String categoria,
    required String descripcion,
    required String zona,
    bool urgente = false,
  }) async {
    final catalogo = await _client
        .from('categories')
        .select('id')
        .eq('nombre', categoria)
        .limit(1)
        .single();
    final fila = await _client
        .from('reports')
        .insert({
          'titulo': titulo,
          'descripcion': descripcion,
          'zona': zona,
          'urgente': urgente,
          'estado': 'Recibido',
          'usuario_id': usuarioDemoId,
          'categoria_id': catalogo['id'],
        })
        .select('*, categories(nombre)')
        .single();
    return filaAReporte(fila);
  }

  /// HU-10: edita un reporte existente (UPDATE ... WHERE codigo = ...).
  Future<void> actualizarReporte(
    String codigo, {
    String? titulo,
    String? descripcion,
    String? zona,
    String? estado,
    bool? urgente,
  }) async {
    final cambios = <String, dynamic>{
      if (titulo != null) 'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      if (zona != null) 'zona': zona,
      if (estado != null) 'estado': estado,
      if (urgente != null) 'urgente': urgente,
      'actualizado_en': DateTime.now().toUtc().toIso8601String(),
    };
    await _client.from('reports').update(cambios).eq('codigo', codigo);
  }

  /// HU-10: elimina un reporte (DELETE). Los comentarios y fotos se van
  /// por ON DELETE CASCADE (schema.sql del Dia 7): nadie queda huerfano.
  Future<void> eliminarReporte(String codigo) async {
    await _client.from('reports').delete().eq('codigo', codigo);
  }

  /// HU-13: estadisticas por categoria (el C06 del Dia 7 desde la app).
  ///
  /// PostgREST expone count con 'count=exact' y head:true; el agrupado
  /// se hace con agruparPorCategoria() (estadistica.dart), que replica
  /// el GROUP BY preservando el catalogo completo (LEFT JOIN).
  Future<List<EstadisticaCategoria>> estadisticasPorCategoria(
      {List<String> catalogo = const []}) async {
    final filas = await _client
        .from('reports')
        .select('categories(nombre), estado');
    return agruparPorCategoria(
      [for (final f in filas) (categoria: _nombreCategoria(f))],
      categorias: catalogo,
    );
  }

  /// HU-13: estadisticas por estado (GROUP BY estado).
  Future<List<EstadisticaEstado>> estadisticasPorEstado(
      {List<String> catalogo = const []}) async {
    final filas = await _client.from('reports').select('estado');
    return agruparPorEstado(
      [for (final f in filas) (estado: f['estado'] as String)],
      estados: catalogo,
    );
  }

  static String _nombreCategoria(Map<String, dynamic> fila) {
    final cat = fila['categories'];
    if (cat is Map && cat['nombre'] != null) return cat['nombre'] as String;
    return 'Sin categoria';
  }

  /// Mapeo fila de la API -> modelo Report (estatico para poder probarlo
  /// sin red: la prueba del contrato de forma vive en test/).
  static Report filaAReporte(Map<String, dynamic> fila) {
    return Report(
      id: (fila['codigo'] as String?) ?? (fila['id'] as String),
      titulo: fila['titulo'] as String,
      categoria: _nombreCategoria(fila),
      descripcion: fila['descripcion'] as String,
      fecha: fechaLegible(fila['creado_en'] as String?),
      estado: fila['estado'] as String,
      zona: fila['zona'] as String,
      urgente: (fila['urgente'] as bool?) ?? false,
    );
  }

  /// '2026-11-03T08:15:00-04:00' -> '03/11/2026 08:15'.
  /// El formateo se hace en Dart (regla del Dia 7: timestamptz en la BD,
  /// presentacion en la app; sin dependencia intl por ahora).
  static String fechaLegible(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final f = DateTime.tryParse(iso);
    if (f == null) return iso;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
  }
}
