// CiudadAlerta - Pestaña Mapa real (Día 12 / Sprint 3, HU-14)
//
// HU-14: "Como ciudadano quiero ver los reportes en el mapa de mi ciudad
// con marcadores y una ventana emergente que lleve al detalle".
//
// Tres decisiones de la clase:
//   1. La clave (MAPS_API_KEY) llega por --dart-define y se inyecta al
//      AndroidManifest con placeholders (android/app/build.gradle). SIN
//      clave el mapa NO crashea: muestra su panel de espera con el camino
//      exacto para configurarla (docs/51). El deterioro elegante del Día
//      11 aplicado a la configuración.
//   2. Los reportes vienen del MISMO provider que la lista de Inicio
//      (reportesProvider): una sola fuente de verdad, ninguna consulta
//      nueva. AsyncValue trae loading/error/datos empaquetados.
//   3. Tocar la InfoWindow del marcador navega a /reporte/:id con
//      go_router: el mapa reutiliza la navegación de la HU-04 sin
//      duplicar pantallas.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../api/api_config.dart';
import '../data/mapa/marcadores.dart';
import '../providers/reports_provider.dart';

class MapaScreen extends ConsumerWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // PRIMERO la clave (no se toca reportesProvider: en modo demo el
    // panel no debe disparar ninguna consulta a Supabase).
    final clave = const ApiConfig.fromEnvironment().mapsApiKey;
    if (clave == null) {
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
                Text('El mapa necesita su clave de Google Maps',
                    style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Configura MAPS_API_KEY antes de correr la app:\n'
                  '  fvm flutter run \\\n'
                  '    --dart-define=MAPS_API_KEY=TU_CLAVE\n\n'
                  'La clave se crea en la consola de Google Cloud con '
                  'restricciones de app Android + SHA-1 (paso a paso en '
                  'docs/51). Nada de claves en el repositorio.',
                  style: theme.textTheme.bodyMedium, textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final reportesAsync = ref.watch(reportesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de reportes')),
      body: reportesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudieron cargar los reportes para el mapa.\n'
              'Vuelve a Inicio y actualiza la lista (pull-to-refresh).',
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (reportes) => GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: sedeLaPaz,
            zoom: zoomInicial,
          ),
          markers: marcadoresDe(
            reportes,
            // Criterio HU-14: la ventana emergente lleva al detalle.
            alTocarInfoWindow: (reporte) => context.push('/reporte/${reporte.id}'),
          ),
          // La ubicación real del ciudadano llega con geolocator (Día 13,
          // HU-15): hoy el mapa muestra los reportes, no tu posición.
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}
