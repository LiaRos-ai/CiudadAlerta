// CiudadAlerta - Lista de reportes (Clase 4 / Dia 4)
// HU-03: "Como ciudadano quiero ver la lista de reportes para conocer los
// problemas de mi zona".
//
// Criterios de aceptacion:
//  - ListView.builder con tarjetas (titulo, categoria, fecha).
//  - Datos mock (lib/data/mock_reports.dart).
//
// Concepto del dia: ListView.builder construye SOLO los items visibles
// (lazy). Con children: [] construiria las 8 tarjetas de golpe; con .builder
// escala a miles sin perder frames. Los 3 estados de datos (cargando /
// error / vacio) se practican hoy porque el Hito 2 los exigira con Supabase.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_reports.dart';
import '../data/report.dart';
import '../widgets/report_card.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: FutureBuilder<List<Report>>(
        future: cargarReportes(), // hoy: mock con retardo; Hito 2: Supabase
        builder: (context, snapshot) {
          // Estado 1: cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Estado 2: error
          if (snapshot.hasError) {
            return Center(
              child: Text('No se pudieron cargar los reportes: ${snapshot.error}'),
            );
          }
          final reportes = snapshot.data ?? const <Report>[];
          // Estado 3: vacio
          if (reportes.isEmpty) {
            return const Center(
              child: Text('Aún no hay reportes en tu zona.'),
            );
          }
          // Estado 4: datos -> lista eficiente
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reportes.length,
            // cacheExtent por defecto; con listas grandes medir en DevTools
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
