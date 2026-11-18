// CiudadAlerta - Tarjeta de clima (Día 11 / Sprint 3)
//
// La primera API externa llega a la UI del Proyecto Guía. Reglas de la
// tarjeta:
//   - Va ARRIBA de la lista de reportes pero NUNCA la bloquea: cada
//     estado del AsyncValue se pinta pequeño y sin impedir el scroll
//     (deterioro elegante, observación 2 del Sprint Review 2).
//   - Loading discreto (una línea), error con REINTENTO al tocar
//     (ref.invalidate) y datos con ícono/descripción del mapeo WMO.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/clima/clima_visual.dart';
import '../providers/clima_provider.dart';

class ClimaCard extends ConsumerWidget {
  const ClimaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final climaAsync = ref.watch(climaActualProvider);
    return climaAsync.when(
      data: (clima) {
        final visual = visualDeClima(clima);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: Icon(visual.icono, color: visual.color),
            title: Text(
              'La Paz · ${clima.temperatura.toStringAsFixed(1)} °C · '
              '${visual.descripcion}',
            ),
            subtitle: Text(
              'Viento ${clima.vientoKmh.toStringAsFixed(0)} km/h · '
              'fuente: Open-Meteo',
            ),
            dense: true,
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text('Consultando el clima…',
            style: TextStyle(fontSize: 12)),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.cloud_off, size: 20),
          title: const Text('Clima no disponible (toca para reintentar)',
              style: TextStyle(fontSize: 13)),
          onTap: () => ref.invalidate(climaActualProvider),
        ),
      ),
    );
  }
}
