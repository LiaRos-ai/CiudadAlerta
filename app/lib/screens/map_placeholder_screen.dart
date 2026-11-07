// CiudadAlerta - Pestaña Mapa (placeholder del Dia 4)
//
// HU-14 (mapa con marcadores de Google Maps) llega en el Sprint 3, Día 12.
// Hoy la pestaña existe para completar el shell de la HU-02 y para que el
// equipo vea cómo crece la app: primero el esqueleto navegable, luego cada
// pantalla real.

import 'package:flutter/material.dart';

class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text('El mapa llega en el Sprint 3 (HU-14)',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Con Google Maps Platform: marcadores de reportes, '
                'ubicación GPS y rutas (días 12 y 13).',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
