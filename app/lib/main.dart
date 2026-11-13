// CiudadAlerta - Proyecto Guia · Aplicaciones Moviles I (SIS-0180)
// Clase 8 (Dia 8): conexion de la app a la BD - CRUD y consultas.
//
// Novedades de hoy en la app (Sprint 2 - Hito 2):
//   - Cliente de Supabase con --dart-define (lib/data/supabase_config.dart):
//     sin credenciales la app corre en MODO DEMO con el mock (mismo codigo).
//   - SupabaseReportsRepository (lib/data/supabase_reports_repository.dart):
//     CRUD completo y consultas contra PostgreSQL (HU-09, HU-10, HU-13).
//   - Filtro por categoria (chips) con StateProvider y estadisticas con
//     grafico fl_chart (lib/screens/stats_screen.dart).
//   - Ninguna pantalla conoce el origen de los datos: la promesa del Dia 6
//     "solo se cambia la implementacion del repositorio" se cumple.
//
// Como correr hoy:
//   fvm flutter run \
//     --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=TU-CLAVE-ANON
//   (sin las variables: modo demo con mock; reglas de seguridad: la clave
//    NUNCA se versiona - el cierre del dia lo verifica)
//
// Mapa del repositorio al cierre del Dia 8 (tags v0.0.0-sprint0 .. v0.7.0-dia8):
//   lib/routing/app_router.dart          -> go_router: rutas + /editar/:id + /estadisticas
//   lib/data/report.dart                 -> modelo Report (fromJson/toJson)
//   lib/data/mock_reports.dart           -> datos simulados (modo demo)
//   lib/data/reports_repository.dart     -> interfaz + mock + provider de implementacion
//   lib/data/supabase_config.dart        -> NUEVO Dia 8: cliente y --dart-define
//   lib/data/supabase_reports_repository.dart -> NUEVO Dia 8: CRUD/consultas Supabase
//   lib/data/estadistica.dart            -> NUEVO Dia 8: agregados HU-13 (GROUP BY en Dart)
//   lib/data/draft_store.dart            -> borradores con shared_preferences (HU-07)
//   lib/providers/reports_provider.dart  -> filtro, lista, detalle y estadisticas
//   lib/screens/stats_screen.dart        -> NUEVO Dia 8: grafico de barras (HU-13)
//   lib/screens/...                      -> HU-01..HU-05 (flujo del Sprint 1)
//   lib/theme/app_theme.dart             -> tema claro + oscuro (HU-06)
//   test/...                             -> suite de pruebas (ver docs/32)
//
// Practica de la clase:
//   1. Corre en MODO DEMO (sin credenciales) y crea un reporte: aparece en
//      la lista con un RPT-009 generado en memoria (el CRUD demo funciona).
//   2. Corre con --dart-define apuntando a tu proyecto del Dia 7: el mismo
//      reporte queda en PostgreSQL y el RLS decide quien puede escribir.
//   3. Abre Estadisticas: las barras cambian tras cada CRUD (GROUP BY vivo).
//   4. Ejecuta fvm flutter analyze y fvm flutter test: limpios y en verde.

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
