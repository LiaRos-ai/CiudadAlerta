// CiudadAlerta - Lista de reportes (refactor Sprint 2 / Dia 8)
// HU-03 + HU-09: "Como ciudadano quiero ver reportes desde la BD con
// filtro por categoria y orden por fecha".
//
// NOVEDAD Dia 8 - la lista sale de la BASE DE DATOS (Supabase):
//   - La pantalla NO sabe de donde vienen los datos (regla del Dia 6):
//     pide el estado a reportesProvider; el repositorio elegido habla
//     con Supabase (credenciales --dart-define) o con el mock (demo).
//   - Chips de filtro (Todas + 5 categorias): al tocar uno se cambia
//     filtroCategoriaProvider y el provider re-ejecuta la consulta
//     (el WHERE ... ORDER BY creado_en DESC de HU-09).
//   - Pull-to-refresh: ref.refresh vuelve a consultar la BD.
//   - Los 4 estados de datos siguen intactos con AsyncValue.when().

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_reports.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_card.dart';

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportesAsync = ref.watch(reportesProvider);
    final filtroActivo = ref.watch(filtroCategoriaProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        // HU-13: acceso directo a las estadisticas (GROUP BY + grafico)
        actions: [
          IconButton(
            tooltip: 'Estadisticas por categoria',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/estadisticas'),
          ),
        ],
      ),
      body: Column(
        children: [
          // HU-09: chips de filtro por categoria
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final categoria in ['Todas', ...categoriasCiudadAlerta])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(categoria),
                      selected: filtroActivo == categoria,
                      onSelected: (_) {
                        ref.read(filtroCategoriaProvider.notifier).state =
                            categoria;
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: reportesAsync.when(
              // Estado 1: cargando (AsyncLoading del provider)
              loading: () => const Center(child: CircularProgressIndicator()),
              // Estado 2: error (AsyncError; tap reintenta la consulta)
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudieron cargar los reportes.'),
                    TextButton(
                      onPressed: () => ref.invalidate(reportesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              // Estados 3 y 4: vacio o datos
              data: (reportes) {
                if (reportes.isEmpty) {
                  return Center(
                    child: Text(
                      filtroActivo == 'Todas'
                          ? 'Aún no hay reportes en tu zona.'
                          : 'Sin reportes de "$filtroActivo" todavía.',
                    ),
                  );
                }
                return RefreshIndicator(
                  // HU-09: reconsulta la BD (el orden ya viene del SQL)
                  onRefresh: () =>
                      ref.refresh(reportesProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: reportes.length,
                    itemBuilder: (context, index) {
                      final r = reportes[index];
                      return InkWell(
                        // HU-04: navega al detalle con el id en la ruta
                        onTap: () => context.push('/reporte/${r.id}'),
                        child: ReportCard(
                          titulo: r.titulo,
                          categoria: r.categoria,
                          fecha: r.fecha,
                          urgente: r.urgente,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
