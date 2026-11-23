// CiudadAlerta - Detalle de reporte (Clase 4 -> 9)
// HU-04: "Como ciudadano quiero ver el detalle de un reporte para conocer
// su descripción y estado".
//
// NOVEDAD Dia 8 (HU-10): acciones de EDITAR y ELIMINAR contra la BD.
//   - Carga puntual: el detalle consulta reportePorIdProvider(id), el
//     WHERE codigo = X que en el Dia 7 era SQL y hoy es filtro de la API
//     REST. No depende de que la lista esté cargada.
//   - Editar: abre /editar/:id (NewReportScreen en modo edicion).
//   - Eliminar: confirmacion + DELETE del repositorio + invalidacion de
//     los providers (lista y estadisticas se actualizan solas).
//   - Regla del curso: la pantalla llama al REPOSITORIO (via ref.read),
//     nunca a Supabase directamente. El error del DELETE (p. ej. una
//     politica RLS que lo impide) se muestra con SnackBar, no con crash.
//   - Los comentarios y fotos del reporte desaparecen solos:
//     ON DELETE CASCADE en schema.sql (Dia 7).
//
// NOVEDAD Dia 9 (HU-11): miniatura de la evidencia fotografica. El URL
// llega embebido del select anidado report_photos(url); si el reporte no
// tiene foto, la seccion no se dibuja (contrato del Dia 7 intacto).
//
// NOVEDAD Dia 13 (HU-15 + HU-20): la tarjeta UBICACIÓN y la ruta. Si el
// reporte tiene coordenadas, el detalle muestra su dirección legible
// (reverse geocoding del Día 13 con caché: abrir dos veces el mismo
// reporte no repite la llamada) y el botón "Cómo llegar" abre la app de
// Google Maps con la URL universal dir/?api=1 (costo cero). Sin
// coordenadas, la sección no se dibuja (contrato intacto, como la foto).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/report.dart';
import '../data/reports_repository.dart';
import '../data/ubicacion/geocoding_service.dart';
import '../data/ubicacion/ruta.dart';
import '../data/ubicacion/ubicacion_service.dart';
import '../data/notificaciones/aviso_estado.dart';
import '../data/notificaciones/notificaciones_service.dart';
import '../data/voz/voz_service.dart';
import '../providers/reports_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, Report reporte) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: Text(
            '¿Eliminar "${reporte.titulo}"? Sus comentarios y fotos también '
            'se eliminarán (CASCADE).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final repo = ref.read(reportsRepositoryProvider);
    try {
      await repo.eliminarReporte(reporte.id);
      // Los providers dependen de la BD: se invalidan y las pantallas
      // que los escuchan (lista, estadisticas) se refrescan solas.
      ref.invalidate(reportesProvider);
      ref.invalidate(reportePorIdProvider(reporte.id));
      ref.invalidate(estadisticasCategoriaProvider);
      ref.invalidate(estadisticasEstadoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte ${reporte.id} eliminado.')),
        );
        context.pop(); // volver a la lista ya actualizada
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Detalle puntual (Dia 8): consulta WHERE codigo = id via family
    // provider; no depende de que la lista este cargada.
    final reporteAsync = ref.watch(reportePorIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(id),
        // HU-10: editar reutiliza el formulario en modo edicion
        actions: [
          if (reporteAsync.valueOrNull != null) ...[
            IconButton(
              tooltip: 'Editar reporte',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/editar/$id'),
            ),
            IconButton(
              tooltip: 'Eliminar reporte',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref, reporteAsync.value!),
            ),
          ],
        ],
      ),
      body: reporteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo cargar el reporte.'),
              TextButton(
                onPressed: () => ref.invalidate(reportePorIdProvider(id)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (reporte) {
          // Caso borde: id inexistente (error de enlace o dato borrado)
          if (reporte == null) {
            return Center(
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
            );
          }
          return _DetalleReporte(reporte: reporte);
        },
      ),
    );
  }
}

class _DetalleReporte extends StatelessWidget {
  const _DetalleReporte({required this.reporte});

  final Report reporte;
  final _geocoding = GeocodingService(); // Día 13: caché del detalle

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorEstado = switch (reporte.estado) {
      'Resuelto' => Colors.green.shade700,
      'En proceso' => Colors.orange.shade700,
      _ => theme.colorScheme.primary,
    };

    return SingleChildScrollView(
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
          // Día 14 (HU-19): accesibilidad REAL. TalkBack ya lee la UI
          // con los Semantics del Día 4; este botón agrega el otro
          // lado: el ciudadano ESCUCHA el contenido del reporte.
          _BotonEscuchar(reporte: reporte),
          const SizedBox(height: 24),

          // ---- Dia 9 (HU-11): miniatura de la evidencia fotografica ----
          if (reporte.fotoUrl != null) ...[
            Text('Evidencia fotográfica', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                // Tocar la miniatura la abre grande (interaccion natural)
                onTap: () => _mostrarFotoCompleta(context, reporte.fotoUrl!),
                child: Image.network(
                  reporte.fotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progreso) {
                    if (progreso == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ---- Día 13 (HU-15): dirección legible del reporte ----
          if (reporte.latitud != null && reporte.longitud != null) ...[
            Text('Ubicación', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: FutureBuilder<String?>(
                  future: _geocoding.direccionDe(
                    latitud: reporte.latitud!,
                    longitud: reporte.longitud!,
                  ),
                  builder: (context, snapshot) {
                    final direccion = snapshot.data;
                    return Text(direccion ??
                        '${reporte.latitud!.toStringAsFixed(5)}, '
                            '${reporte.longitud!.toStringAsFixed(5)}');
                  },
                ),
                subtitle: const Text(
                    'Dirección legible del reporte (geocoding con caché)'),
              ),
            ),
            const SizedBox(height: 8),
            // ---- Día 13 (HU-20): la ruta hacia el reporte ----
            OutlinedButton.icon(
              onPressed: () => _abrirRuta(context, reporte),
              icon: const Icon(Icons.directions_walk),
              label: const Text('Cómo llegar'),
            ),
            const SizedBox(height: 24),
          ],

          // Día 14 (HU-17): activar los avisos de estado. El cambio
          // REAL llega del trigger de la BD -> Edge Function -> FCM
          // (docs/60); sin Firebase configurado, la app demuestra el
          // MISMO aviso en local (deterioro elegante) y guarda el
          // token si FCM responde.
          _BotonAvisos(reporte: reporte),
        ],
      ),
    );
  }

  /// Día 13 (HU-20): abre la ruta hacia el reporte en la app de Google
  /// Maps (costo cero). La posición actual es el origen; si no hay
  /// ubicación propia, la URL solo lleva destino. launchUrl devuelve
  /// false si no hay app/navegador: SnackBar, nunca un crash.
  Future<void> _abrirRuta(BuildContext context, Report reporte) async {
    Position? origen;
    try {
      origen = await const UbicacionService().posicionActual();
    } catch (_) {
      origen = null; // sin permiso o sin GPS: la ruta abre con destino
    }
    final url = Uri.parse(urlRuta(
      destinoLat: reporte.latitud!,
      destinoLng: reporte.longitud!,
      origenLat: origen?.latitude,
      origenLng: origen?.longitude,
    ));
    if (!context.mounted) return;
    final abrio = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!abrio && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se encontró una app de mapas para abrir la ruta.'),
      ));
    }
  }

  /// HU-11: vista a pantalla completa de la evidencia (Dialog simple:
  /// sin paquete adicional, el curso evita dependencias "porque si").
  void _mostrarFotoCompleta(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: InteractiveViewer(
          maxScale: 4,
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Día 14 (HU-19): botón "Escuchar" con flutter_tts (motor del sistema,
/// costo cero). StatefulWidget propio para detener la locución al salir
/// del detalle (dispose) y para alternar Escuchar / Detener como un
/// ESTADO visible, igual que el punto azul del Día 13.
class _BotonEscuchar extends StatefulWidget {
  const _BotonEscuchar({required this.reporte});

  final Report reporte;

  @override
  State<_BotonEscuchar> createState() => _BotonEscucharState();
}

class _BotonEscucharState extends State<_BotonEscuchar> {
  final _voz = VozService();
  bool _leyendo = false;

  @override
  void dispose() {
    _voz.silenciar(); // salir de la pantalla = silenciar la voz
    super.dispose();
  }

  Future<void> _alternar() async {
    if (_leyendo) {
      await _voz.silenciar();
      if (mounted) setState(() => _leyendo = false);
      return;
    }
    final error = await _voz.escuchar(textoParaLeer(
      codigo: widget.reporte.id,
      titulo: widget.reporte.titulo,
      estado: widget.reporte.estado,
      zona: widget.reporte.zona,
      descripcion: widget.reporte.descripcion,
    ));
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
      ));
      return;
    }
    setState(() => _leyendo = true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _alternar,
        icon: Icon(_leyendo ? Icons.stop_rounded : Icons.volume_up_outlined),
        label: Text(_leyendo ? 'Detener lectura' : 'Escuchar el reporte'),
      ),
    );
  }
}

/// Día 14 (HU-17): "Avisarme cuando cambie el estado" deja de ser un
/// placeholder. Un tap hace tres cosas EN CONTEXTO: (1) pide el permiso
/// de notificaciones (Android 13+), (2) guarda el token FCM del
/// dispositivo ligado al usuario en push_tokens (si Firebase responde)
/// y (3) muestra el aviso EXACTO que la Edge Function enviaría cuando
/// el moderador avance el ciclo de estados (la demo del Hito 4 antes
/// de que exista el panel).
class _BotonAvisos extends StatefulWidget {
  const _BotonAvisos({required this.reporte});

  final Report reporte;

  @override
  State<_BotonAvisos> createState() => _BotonAvisosState();
}

class _BotonAvisosState extends State<_BotonAvisos> {
  final _notificaciones = NotificacionesService();
  bool _activando = false;

  Future<void> _activar() async {
    setState(() => _activando = true);
    // (1) Permiso POST_NOTIFICATIONS (Android 13+) — en contexto.
    final concedido = await _notificaciones.inicializar();
    if (!mounted) return;
    if (!concedido) {
      setState(() => _activando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sin permiso de notificaciones: actívalo en '
            'Ajustes > Aplicaciones > CiudadAlerta.'),
      ));
      return;
    }
    // (2) Token FCM -> push_tokens (null si Firebase no está configurado:
    //     la fila no viaja y el aviso local cubre la demo).
    final token = await _notificaciones.registrarToken();
    // (3) El aviso EXACTO que la Edge Function enviaría con el trigger:
    //     el siguiente paso del ciclo del estado ACTUAL del reporte.
    final estadoNuevo =
        siguienteEstado(widget.reporte.estado) ?? 'En proceso';
    await _notificaciones.mostrarAvisoEstado(
      codigo: widget.reporte.id,
      titulo: widget.reporte.titulo,
      estadoAnterior: widget.reporte.estado,
      estadoNuevo: estadoNuevo,
    );
    if (!mounted) return;
    setState(() => _activando = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(token == null
          ? 'Aviso local de demostración enviado. Con Firebase configurado '
              '(docs/60) el mismo aviso llega como PUSH.'
          : 'Avisos activados: tu token quedó en push_tokens y la demo '
              'del aviso fue enviada.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _activando ? null : _activar,
        icon: _activando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.notifications_outlined),
        label: const Text('Activar avisos de estado'),
      ),
    );
  }
}
