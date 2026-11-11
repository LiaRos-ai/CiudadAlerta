// CiudadAlerta - Estado global con Riverpod (Clase 6 / Dia 6)
// Sprint 2 (Hito 2): migracion de FutureBuilder a FutureProvider.
//
// Por qué Riverpod y no setState:
//   - setState es estado LOCAL de un StatefulWidget: vive y muere con el
//     widget, y no se puede compartir entre pantallas.
//   - La lista (HU-03) y la pantalla de estadisticas (HU-13, Dia 8)
//     consumiran los MISMOS datos: con un provider la consulta se hace
//     una vez y ambas pantallas comparten el resultado y su cache.
//   - AsyncValue trae los estados cargando/error/datos empaquetados:
//     los 4 estados que escribimos a mano con FutureBuilder (Dia 4)
//     ahora se declaran con .when().
//
// Conexion con el Dia 4: la UI conserva exactamente los mismos 4 estados;
// solo cambia QUIEN controla el ciclo de vida del Future.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/report.dart';
import '../data/reports_repository.dart';

/// Estado global de la lista de reportes.
/// `ref.watch(reportesProvider)` devuelve un AsyncValue<List<Report>>
/// que la UI interpreta con .when(loading:, error:, data:).
final reportesProvider = FutureProvider<List<Report>>((ref) async {
  // ref.watch: si el repositorio cambia (mock -> Supabase), este provider
  // se re-ejecuta y la UI se actualiza sola. Esa es la reactividad del Dia 6.
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.obtenerReportes();
});
