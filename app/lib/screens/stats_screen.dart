// CiudadAlerta - Estadisticas (Clase 8 / Dia 8)
// HU-13: "Como autoridad quiero ver estadisticas por categoria y estado
// para priorizar atencion".
//
// La pantalla consume las dos consultas agregadas del Dia 7:
//   - GROUP BY categoria -> grafico de barras (fl_chart) con las 5
//     categorias del catalogo (LEFT JOIN: las vacias cuentan 0).
//   - GROUP BY estado    -> chips con el conteo Recibido / En revision /
//     En proceso / Resuelto.
//
// Los providers (estadisticasCategoriaProvider / estadisticasEstadoProvider)
// se invalidan tras cada CRUD: la autoridad ve SIEMPRE los numeros del
// momento. La lectura es la que el informe del Dia 10 explicara.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/estadistica.dart';
import '../providers/reports_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  Color _colorDe(int index, ColorScheme colors) =>
      colors.primary.withAlpha(255 - index * 28);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(estadisticasCategoriaProvider);
    final estadosAsync = ref.watch(estadisticasEstadoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudieron calcular las estadísticas.'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(estadisticasCategoriaProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (stats) {
          final total = stats.fold<int>(0, (suma, s) => suma + s.total);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- Encabezado de la consulta ----
              Text('Reportes por categoría',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                'Consulta agregada: GROUP BY categoria (HU-13) · total: $total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              // ---- Grafico de barras (fl_chart) ----
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        maxY: _maxConMargen(stats.map((s) => s.total)),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (valor, meta) =>
                                  _EtiquetaEje(valor, stats),
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < stats.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: stats[i].total.toDouble(),
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                  color: _colorDe(i,
                                      Theme.of(context).colorScheme),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ---- Leyenda con los numeros exactos ----
              for (final s in stats)
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Icon(Icons.circle, size: 12,
                      color: _colorDe(stats.indexOf(s),
                          Theme.of(context).colorScheme)),
                  title: Text(s.categoria),
                  trailing: Text('${s.total}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              const Divider(height: 32),

              // ---- GROUP BY estado (segunda agregada de HU-13) ----
              Text('Reportes por estado',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              estadosAsync.when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )),
                error: (_, __) => const Text(
                    'No se pudieron calcular los conteos por estado.'),
                data: (estados) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in estados)
                      Chip(
                        label: Text('${e.estado}: ${e.total}'),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(24),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  /// El maxY del eje Y: maximo de los conteos + 1 para que la barra mas
  /// alta no toque el borde del grafico (detalle de presentacion).
  double _maxConMargen(Iterable<int> valores) {
    final maximo = valores.fold<int>(0, (a, b) => a > b ? a : b);
    return (maximo + 1).toDouble();
  }
}

/// Etiqueta del eje X: usa el indice como posicion y devuelve el nombre
/// corto de la categoria (Via, Luminaria, ...).
class _EtiquetaEje extends StatelessWidget {
  const _EtiquetaEje(this.valor, this.stats);

  final double valor;
  final List<EstadisticaCategoria> stats;

  @override
  Widget build(BuildContext context) {
    final i = valor.toInt();
    if (i < 0 || i >= stats.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(stats[i].categoria,
          style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
