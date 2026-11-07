// CiudadAlerta - Proyecto Guia · Aplicaciones Moviles I (SIS-0180)
// Clase 3 (Dia 3): Dart y Flutter - widgets, estado y estilos.
//
// La app estrena su primera pantalla real (HU-01) y su tema propio:
//   lib/theme/app_theme.dart      -> ThemeData con Material 3 (semilla #329B67)
//   lib/widgets/custom_button.dart -> CustomButton (reutilizable)
//   lib/widgets/custom_input.dart  -> CustomInput (reutilizable)
//   lib/widgets/report_card.dart   -> ReportCard (primer StatelessWidget con datos)
//   lib/screens/welcome_screen.dart-> WelcomeScreen (HU-01, solo UI, con setState)
//
// Practica de la clase:
//   1. Corre la app (fvm flutter run) y mira la pantalla de bienvenida.
//   2. Toca "Mostrar/Ocultar contrasena": es el setState del dia.
//   3. Rota el emulador (Ctrl+izquierda): HU-01 no debe romper el layout.
//   4. Cambia el seedColor en app_theme.dart, guarda (Ctrl+S) y mira el hot reload.

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(const CiudadAlertaApp());

class CiudadAlertaApp extends StatelessWidget {
  const CiudadAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CiudadAlerta',
      debugShowCheckedModeBanner: false,
      theme: temaCiudadAlerta(),      // tema propio del curso (Material 3)
      home: const WelcomeScreen(),    // HU-01: bienvenida e inicio de sesion
    );
  }
}
