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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/report.dart';
import '../data/reports_repository.dart';
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
    );
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
