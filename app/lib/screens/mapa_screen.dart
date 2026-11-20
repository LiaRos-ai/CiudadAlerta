// CiudadAlerta - Pestaña Mapa real (Día 12 / Sprint 3, HU-14)
//                        + mapa vivo (Día 13 / Sprint 3, HU-15)
//
// HU-14: "Como ciudadano quiero ver los reportes en el mapa de mi ciudad
// con marcadores y una ventana emergente que lleve al detalle".
// HU-15: "Como ciudadano quiero ver mi ubicación actual en el mapa y que
// el reporte se cree en el lugar donde estoy".
//
// NOVEDAD Día 13 (HU-15): el mapa se vuelve VIVO.
//   - myLocationEnabled se enciende SOLO tras conceder el permiso: el
//     punto azul del GPS es un estado resultado del permiso, no una
//     propiedad decorativa del widget.
//   - El botón "Mi ubicación" pide el permiso EN CONTEXTO, obtiene UNA
//     lectura puntual (high, timeLimit 8 s) y centra la cámara en el
//     ciudadano. Si el permiso quedó denegado para siempre, ofrece
//     abrir Ajustes. Nunca un crash: sin permiso el mapa sigue
//     mostrando los reportes.
// Decisiones del Día 12 que se conservan:
//   1. La clave llega por --dart-define; sin clave, panel de espera
//      (docs/51). El deterioro elegante aplicado a la configuración.
//   2. Los reportes vienen del MISMO provider que la lista de Inicio
//      (reportesProvider): una sola fuente de verdad.
//   3. Tocar la InfoWindow del marcador navega a /reporte/:id con
//      go_router: el mapa reutiliza la navegación de la HU-04 sin
//      duplicar pantallas.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../api/api_config.dart';
import '../data/mapa/marcadores.dart';
import '../data/ubicacion/ubicacion_service.dart';
import '../providers/reports_provider.dart';

class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({super.key});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  final _ubicacion = const UbicacionService();
  GoogleMapController? _mapa;
  bool _ubicacionActiva = false; // punto azul SOLO con permiso concedido

  @override
  void dispose() {
    _mapa?.dispose();
    super.dispose();
  }

  /// HU-15: pedir permiso EN CONTEXTO (al tocar el botón, no al abrir
  /// la app), obtener UNA lectura y centrar la cámara en el ciudadano.
  Future<void> _irAMiUbicacion() async {
    final conPermiso = await _ubicacion.permisoConcedido();
    if (!mounted) return;
    if (!conPermiso) {
      final bloqueado = await _ubicacion.denegadoParaSiempre();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajePermiso(true, bloqueado)),
          action: bloqueado
              ? SnackBarAction(
                  label: 'Abrir Ajustes',
                  onPressed: Geolocator.openAppSettings,
                )
              : null,
        ),
      );
      return; // sin permiso NO hay crash: el mapa sigue con los reportes
    }
    final posicion = await _ubicacion.posicionActual();
    if (!mounted) return;
    if (posicion == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('El GPS no respondió a tiempo. Intenta de nuevo.'),
      ));
      return;
    }
    setState(() => _ubicacionActiva = true); // el punto azul es un ESTADO
    await _mapa?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(posicion.latitude, posicion.longitude),
        zoom: 16, // nivel de cuadra: tu posición, no la ciudad entera
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'mi-ubicacion',
        onPressed: _irAMiUbicacion,
        icon: const Icon(Icons.my_location),
        label: const Text('Mi ubicación'),
      ),
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
          onMapCreated: (controlador) => _mapa = controlador,
          markers: marcadoresDe(
            reportes,
            // Criterio HU-14: la ventana emergente lleva al detalle.
            alTocarInfoWindow: (reporte) => context.push('/reporte/${reporte.id}'),
          ),
          // Día 13 / HU-15: el punto azul aparece SOLO tras conceder el
          // permiso (estado _ubicacionActiva). El botón nativo se apaga:
          // la secuencia pedir -> leer -> centrar vive en el FAB del curso.
          myLocationEnabled: _ubicacionActiva,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}
