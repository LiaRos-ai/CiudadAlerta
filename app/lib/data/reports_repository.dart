// CiudadAlerta - Repositorio de reportes (Clase 6 / Dia 6)
// Sprint 2 (Hito 2): arquitectura por capas.
//
// Capas del curso:
//   UI (screens/widgets)  ->  providers (Riverpod)  ->  repositorio  ->  datos
//
// Regla de dependencias: la UI NUNCA llama a los datos directamente;
// el repositorio es la UNICA puerta de entrada a los datos y expone
// funciones async. Hoy `MockReportsRepository` delega en el mock con
// retardo; en el Dia 8 `SupabaseReportsRepository` implementara la MISMA
// interfaz contra PostgreSQL y ninguna pantalla cambiara una linea.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_reports.dart';
import 'report.dart';

/// Contrato de la capa de datos para reportes.
/// El resto de la app solo conoce esta interfaz, no el origen real.
abstract class ReportsRepository {
  /// Lista completa de reportes (hoy mock con 600 ms; Dia 8: consulta
  /// con filtro por categoria y orden por fecha - HU-09).
  Future<List<Report>> obtenerReportes();

  /// Busqueda puntual por id (hoy mock; Dia 8: WHERE id = ?).
  /// Devuelve null si no existe: la UI decide como mostrar ese caso.
  Report? buscarPorId(String id);
}

/// Implementacion mock del Sprint 1: mismos datos, misma latencia de 600 ms.
/// Sirve para que el refactor de arquitectura no cambie NADA de lo visible.
class MockReportsRepository implements ReportsRepository {
  const MockReportsRepository();

  @override
  Future<List<Report>> obtenerReportes() => cargarReportes();

  @override
  Report? buscarPorId(String id) => buscarReportePorId(id);
}

/// Provider del repositorio (Riverpod).
/// Al llegar Supabase (Dia 8) solo se cambia ESTA linea por:
///   return SupabaseReportsRepository(ref.watch(supabaseClientProvider));
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return const MockReportsRepository();
});
