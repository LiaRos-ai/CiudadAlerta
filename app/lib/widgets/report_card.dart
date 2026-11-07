// CiudadAlerta - Widgets reutilizables (Clase 3 / Dia 3)
// Tarjeta de reporte: el primer StatelessWidget con datos del proyecto.
// HU-03 la usara en el Dia 4 con la lista de reportes (datos mock).

import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.titulo,
    required this.categoria,
    required this.fecha,
    this.urgente = false,
  });

  final String titulo;
  final String categoria;
  final String fecha;
  final bool urgente;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              urgente ? Icons.warning_amber_rounded : Icons.report,
              color: urgente ? colors.error : colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '$categoria · $fecha',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Chip(label: Text(urgente ? 'URGENTE' : 'NORMAL')),
          ],
        ),
      ),
    );
  }
}
