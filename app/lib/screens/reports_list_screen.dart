// CiudadAlerta - Lista de reportes (refactor Sprint 2 / Dia 6)
// HU-03: "Como ciudadano quiero ver la lista de reportes para conocer los
// problemas de mi zona".
//
// NOVEDAD Dia 6 - arquitectura por capas con Riverpod:
//   - ANTES (Dia 4, tag v0.3.0-dia4): FutureBuilder llamaba a
//     cargarReportes() directamente desde la UI: la pantalla conocia
//     el origen de datos y cada rebuild re-ejecutaba la consulta.
//   - AHORA: la pantalla es un ConsumerWidget y pide el estado global
//     con ref.watch(reportesProvider). El Future vive en el provider
//     (una sola vez, compartido con HU-13) y AsyncValue empaqueta los
//     4 estados con .when(). La UI no sabe que el dato viene de un mock:
//     en el Dia 8 sera Supabase y esta pantalla NO cambia.
//
// Criterios de aceptacion intactos: ListView.builder con tarjetas
// (titulo, categoria, fecha) y manejo de los estados de datos.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/reports_provider.dart';
import '../widgets/report_card.dart';

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportesAsync = ref.watch(reportesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: reportesAsync.when(
        // Estado 1: cargando (AsyncLoading del provider)
        loading: () => const Center(child: CircularProgressIndicator()),
        // Estado 2: error (AsyncError; refresco con pull no aplica: tap reintenta)
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
            return const Center(
              child: Text('Aún no hay reportes en tu zona.'),
            );
          }
          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
