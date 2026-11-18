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
//
// NOVEDAD Dia 9 (HU-08 + HU-11):
//   - El autor del INSERT ya no es el perfil semilla del Dia 7: es
//     auth.uid(), el usuario logueado por Supabase Auth. Asi la politica
//     RLS "insertar solo mis reportes" (with check auth.uid() = usuario_id)
//     acepta la fila; con otro uid, la BD la rechaza con error 403.
//   - El select anidado agrega 'report_photos(url)': la evidencia llega
//     embebida como el JOIN de categories, y el detalle (HU-11) muestra
//     la miniatura sin una segunda consulta.
//   - adjuntarFoto() INSERTa en report_photos tras subir a Storage.

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
  /// El select anidado trae DOS joins por FK (Dia 8 + Dia 9):
  ///   - categories(nombre): la etiqueta de la categoria (3FN)
  ///   - report_photos(url): las evidencias del reporte (HU-11)
  @override
  Future<List<Report>> obtenerReportes({String? categoria}) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> consulta = _client
        .from('reports')
        .select(
            'id, codigo, titulo, descripcion, estado, zona, urgente, '
            'creado_en, categories(nombre), report_photos(url)')
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
            'creado_en, categories(nombre), report_photos(url)')
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
  /// NOVEDAD Dia 9 (HU-08): el autor es auth.uid() (el usuario logueado);
  /// el perfil semilla queda SOLO como respaldo si la app corre sin sesion
  /// (demo contra BD: casos de prueba SP-05/SP-06 en docs/36).
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
          // Dia 9: RLS exige auth.uid() = usuario_id; el seed es fallback
          'usuario_id': _authUid ?? usuarioDemoId,
          'categoria_id': catalogo['id'],
        })
        .select('*, categories(nombre), report_photos(url)')
        .single();
    return filaAReporte(fila);
  }

  /// El id del usuario autenticado (auth.uid() en SQL).
  /// null = sin sesion; la BD aplicara sus politicas igual (denegara).
  String? get _authUid => _client.auth.currentUser?.id;

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
  @override
  Future<void> eliminarReporte(String codigo) async {
    await _client.from('reports').delete().eq('codigo', codigo);
  }

  /// Dia 9 (HU-11): registra la evidencia fotografica en report_photos.
  ///
  /// La tabla del Dia 7 referencia reports.id (uuid), pero la app navega
  /// con el codigo legible (RPT-001): se resuelve con un SELECT puntual.
  /// La politica RLS "insertar fotos de mis reportes" (db/rls_dia9.sql)
  /// valida que el reporte sea del usuario; si no lo es, la BD rechaza.
  @override
  Future<void> adjuntarFoto(String codigo, String urlFoto) async {
    final reporte = await _client
        .from('reports')
        .select('id')
        .eq('codigo', codigo)
        .limit(1)
        .single();
    await _client.from('report_photos').insert({
      'reporte_id': reporte['id'],
      'url': urlFoto,
    });
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
  ///
  /// Dia 9 (HU-11): la evidencia llega embebida en report_photos (lista
  /// por el JOIN); la miniatura usa la PRIMERA foto. Si no hay fotos, la
  /// clave no existe o llega vacia: fotoUrl queda null y la UI no dibuja
  /// la miniatura (mismo contrato que el Dia 7).
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
      fotoUrl: _primeraFoto(fila),
      // Dia 12 (HU-14): coordenadas de la migracion db/ubicaciones_dia12.sql.
      // Un reporte viejo sin ubicacion llega con null y el mapa lo excluye
      // con elegancia (mismo criterio que fotoUrl en el Dia 9).
      latitud: (fila['latitud'] as num?)?.toDouble(),
      longitud: (fila['longitud'] as num?)?.toDouble(),
    );
  }

  static String? _primeraFoto(Map<String, dynamic> fila) {
    final fotos = fila['report_photos'];
    if (fotos is List && fotos.isNotEmpty) {
      final primera = fotos.first;
      if (primera is Map && primera['url'] != null) {
        return primera['url'] as String;
      }
    }
    return null;
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
