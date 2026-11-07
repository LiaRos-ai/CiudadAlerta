// CiudadAlerta - Detalle de reporte (Clase 4 / Dia 4)
// HU-04: "Como ciudadano quiero ver el detalle de un reporte para conocer
// su descripción y estado".
//
// Criterios de aceptacion:
//  - Navegación con parámetro: la ruta /reporte/:id trae el id.
//  - Muestra TODOS los campos del reporte.
//
// La pantalla no conoce la lista ni el router: recibe el id y pide el dato
// a la capa de datos (buscarReportePorId). Si el id no existe muestra un
// mensaje claro (caso borde que el Hito 2 exigira con la BD real).

import 'package:flutter/material.dart';

import '../data/mock_reports.dart';
import '../data/report.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Report? reporte = buscarReportePorId(id);

    // Caso borde: id inexistente (error de enlace o dato borrado)
    if (reporte == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reporte')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text('No existe el reporte "$id".',
                  style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    final colorEstado = switch (reporte.estado) {
      'Resuelto' => Colors.green.shade700,
      'En proceso' => Colors.orange.shade700,
      _ => theme.colorScheme.primary,
    };

    return Scaffold(
      appBar: AppBar(title: Text(reporte.id)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado y urgencia: lo primero que el ciudadano necesita ver
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  avatar: Icon(Icons.info_outline, size: 18, color: colorEstado),
                  label: Text(reporte.estado),
                  backgroundColor: colorEstado.withAlpha(30),
                ),
                if (reporte.urgente)
                  Chip(
                    avatar: Icon(Icons.warning_amber_rounded,
                        size: 18, color: theme.colorScheme.error),
                    label: Text('URGENTE',
                        style: TextStyle(color: theme.colorScheme.error)),
                    backgroundColor: theme.colorScheme.error.withAlpha(30),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Titulo y ubicación
            Semantics(
              header: true, // accesibilidad básica del Día 4: encabezado
              child: Text(reporte.titulo, style: theme.textTheme.headlineSmall),
            ),
            const SizedBox(height: 4),
            Text(
              '${reporte.categoria} · ${reporte.zona} · ${reporte.fecha}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 32),

            // Descripcion completa
            Text('Descripción', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(reporte.descripcion, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Accion de seguimiento (el cambio de estado real llega en el
            // Hito 4 con el panel de moderación; hoy es demo visual)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('Avisarme cuando cambie el estado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
