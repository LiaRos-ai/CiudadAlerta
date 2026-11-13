// CiudadAlerta - Estado global con Riverpod (Clase 6 -> 8)
// Sprint 2 (Hito 2): migracion a FutureProvider y hoy, consulta a la BD.
//
// Por qué Riverpod y no setState:
//   - setState es estado LOCAL de un StatefulWidget: vive y muere con el
//     widget, y no se puede compartir entre pantallas.
//   - La lista (HU-03/HU-09), el detalle (HU-04) y las estadisticas
//     (HU-13) consumen los MISMOS datos: con providers la consulta se
//     hace una vez y las pantallas comparten resultado y cache.
//   - AsyncValue trae los estados cargando/error/datos empaquetados:
//     los 4 estados que escribimos a mano con FutureBuilder (Dia 4)
//     ahora se declaran con .when().
//
// Novedad del Dia 8 (HU-09): el filtro por categoria es ESTADO GLOBAL
// (StateProvider). Al cambiar el chip, reportesProvider se re-ejecuta
// con el nuevo filtro y la UI se refresca sola: esa es la reactividad
// que el Dia 6 anticipaba ("si el repositorio cambia, la UI se actualiza").

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/estadistica.dart';
import '../data/report.dart';
import '../data/reports_repository.dart';

/// Categoria activa del filtro de la lista (HU-09).
/// 'Todas' = sin filtro (equivale a quitar el WHERE de la consulta).
final filtroCategoriaProvider = StateProvider<String>((ref) => 'Todas');

/// Estado global de la lista de reportes.
/// `ref.watch(reportesProvider)` devuelve un AsyncValue<List<Report>>
/// que la UI interpreta con .when(loading:, error:, data:).
final reportesProvider = FutureProvider<List<Report>>((ref) async {
  // ref.watch(filtro): al cambiar el chip de categoria este provider se
  // vuelve a ejecutar con el nuevo valor y dispara la consulta filtrada.
  final filtro = ref.watch(filtroCategoriaProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.obtenerReportes(categoria: filtro);
});

/// Detalle puntual por id (HU-04 / Dia 8): el WHERE codigo = X que en el
/// Dia 7 era consulta SQL y hoy la API REST lo ejecuta por filtro.
/// Family provider: una instancia de consulta por cada id visitado.
final reportePorIdProvider =
    FutureProvider.family<Report?, String>((ref, id) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.buscarPorId(id);
});

/// Estadisticas por categoria para el grafico de HU-13 (GROUP BY del Dia 7).
/// Se invalida (ref.invalidate) despues de cada CRUD para reflejar el cambio.
final estadisticasCategoriaProvider =
    FutureProvider<List<EstadisticaCategoria>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.estadisticasPorCategoria();
});

/// Estadisticas por estado (segunda consulta agregada de HU-13).
final estadisticasEstadoProvider =
    FutureProvider<List<EstadisticaEstado>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.estadisticasPorEstado();
});
