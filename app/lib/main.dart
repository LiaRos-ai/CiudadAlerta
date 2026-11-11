// CiudadAlerta - Proyecto Guia · Aplicaciones Moviles I (SIS-0180)
// Clase 6 (Dia 6): Sprint Planning 2 - arquitectura y persistencia local.
//
// Novedades de hoy en main.dart (Sprint 2 - Hito 2):
//   - ProviderScope de Riverpod: un UNICO contenedor de estado global
//     arriba de toda la app. Sin el ProviderScope los providers no existen.
//   - Las pantallas ya no consultan datos directamente: piden el estado
//     a los providers (lib/providers/) y estos a la capa repositorio
//     (lib/data/reports_repository.dart). Regla del curso:
//     UI -> providers -> repositorio -> datos.
//   - SharedPreferences alimenta los borradores HU-07 (lib/data/draft_store.dart).
//
// Mapa del repositorio al inicio del Sprint 2 (tags v0.0.0-sprint0 .. v0.5.0-dia6):
//   lib/routing/app_router.dart          -> go_router: rutas, ShellRoute y /reporte/:id
//   lib/data/report.dart                 -> modelo Report (fromJson/toJson)
//   lib/data/mock_reports.dart           -> datos simulados + cargarReportes() async
//   lib/data/reports_repository.dart     -> NUEVO Dia 6: interfaz del repositorio (capa datos)
//   lib/data/draft_store.dart            -> NUEVO Dia 6: borradores con shared_preferences (HU-07)
//   lib/providers/reports_provider.dart  -> NUEVO Dia 6: FutureProvider de reportes (Riverpod)
//   lib/screens/...                      -> HU-01..HU-05 (flujo del Sprint 1)
//   lib/theme/app_theme.dart             -> tema claro + oscuro (HU-06)
//   test/draft_provider_test.dart        -> NUEVO Dia 6: pruebas del borrador y del repositorio
//
// Practica de la clase:
//   1. Escribe algo en "Nuevo reporte", CIERRA la app desde el sistema y
//      vuelve a abrirla: el borrador se restaura solo (HU-07).
//   2. Compara reports_list_screen.dart con la version del Dia 4 (tag
//      v0.3.0-dia4): la UI ya no llama a cargarReportes(), mira el provider.
//   3. Ejecuta fvm flutter analyze y fvm flutter test: limpios y en verde.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() => runApp(
      // ProviderScope: el contenedor raiz de Riverpod. Va SIEMPRE encima
      // de MaterialApp.router; sin el, ref.watch no encuentra providers.
      const ProviderScope(
        child: CiudadAlertaApp(),
      ),
    );

class CiudadAlertaApp extends StatelessWidget {
  const CiudadAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CiudadAlerta',
      debugShowCheckedModeBanner: false,
      theme: temaCiudadAlerta(),            // tema claro (Material 3)
      darkTheme: temaCiudadAlertaOscuro(),  // HU-06: tema oscuro
      themeMode: ThemeMode.system,          // respeta la configuración del sistema
      routerConfig: appRouter,              // go_router: el mapa de rutas del Dia 4
    );
  }
}
