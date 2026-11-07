// CiudadAlerta - Configuracion de navegacion (Clase 4 / Dia 4)
//
// HU-02: "Como usuario quiero navegar por pestañas (Inicio, Mapa, Nuevo,
// Perfil) para llegar rápido a cada sección".
//
// go_router reemplaza la navegación manual con Navigator.push:
//   - Rutas declarativas: cada pantalla tiene una URL (/inicio, /nuevo...).
//   - Parámetros: /reporte/:id (HU-04) recibe el id en la ruta misma.
//   - StatefulShellRoute: el shell con barra inferior conserva el estado
//     de cada pestaña (IndexedStack): si vuelves a Inicio, la lista sigue
//     donde la dejaste.
//
// Mapa de rutas del Dia 4:
//   /                 -> WelcomeScreen (HU-01, sin barra inferior)
//   /inicio           -> ReportsListScreen   (pestaña 1, HU-03)
//   /mapa             -> MapPlaceholderScreen(pestaña 2, HU-14 en Sprint 3)
//   /nuevo            -> NewReportScreen     (pestaña 3, HU-05)
//   /perfil           -> ProfileScreen       (pestaña 4, Hito 2 con Auth)
//   /reporte/:id      -> ReportDetailScreen  (HU-04, fuera del shell)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_shell.dart';
import 'screens/map_placeholder_screen.dart';
import 'screens/new_report_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_detail_screen.dart';
import 'screens/reports_list_screen.dart';
import 'screens/welcome_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // HU-01: bienvenida e inicio de sesion (fuera del shell: pantalla completa)
    GoRoute(
      path: '/',
      name: 'bienvenida',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // HU-02: shell con barra de navegacion inferior de 4 pestañas
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeShell(shell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inicio',
              name: 'inicio',
              builder: (context, state) => const ReportsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mapa',
              name: 'mapa',
              builder: (context, state) => const MapPlaceholderScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/nuevo',
              name: 'nuevo',
              builder: (context, state) => const NewReportScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/perfil',
              name: 'perfil',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // HU-04: detalle de reporte con PARAMETRO de ruta (:id)
    GoRoute(
      path: '/reporte/:id',
      name: 'detalle',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReportDetailScreen(id: id);
      },
    ),
  ],
);
