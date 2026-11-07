// CiudadAlerta - Proyecto Guia · Aplicaciones Moviles I (SIS-0180)
// Clase 4 (Dia 4): Navegacion, listas y formularios.
//
// La app deja de ser una pantalla suelta y se convierte en un FLUJO:
//   lib/routing/app_router.dart        -> go_router: rutas, ShellRoute y /reporte/:id
//   lib/data/report.dart               -> modelo Report (fromJson/toJson)
//   lib/data/mock_reports.dart         -> datos simulados + cargarReportes() async
//   lib/screens/home_shell.dart        -> HU-02: 4 pestañas con NavigationBar
//   lib/screens/reports_list_screen.dart -> HU-03: ListView.builder + estados
//   lib/screens/report_detail_screen.dart-> HU-04: detalle con parámetro de ruta
//   lib/screens/new_report_screen.dart   -> HU-05: Form + TextFormField + validators
//
// Practica de la clase:
//   1. Corre la app (fvm flutter run), entra y prueba las 4 pestañas (HU-02).
//   2. Toca un reporte de la lista: la ruta cambia a /reporte/RPT-00x (HU-04).
//   3. Ve a Nuevo y envia el formulario vacio: valida sin enviar (HU-05).
//   4. En el codigo: busca StatefulShellRoute y fíjate cómo el shell conserva
//      el estado de cada pestaña.

import 'package:flutter/material.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() => runApp(const CiudadAlertaApp());

class CiudadAlertaApp extends StatelessWidget {
  const CiudadAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CiudadAlerta',
      debugShowCheckedModeBanner: false,
      theme: temaCiudadAlerta(),      // tema propio del curso (Material 3)
      routerConfig: appRouter,        // go_router: el mapa de rutas del Dia 4
    );
  }
}
