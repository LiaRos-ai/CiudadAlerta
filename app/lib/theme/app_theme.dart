// CiudadAlerta - Tema del curso (actualizado en la Clase 5 / Dia 5)
//
// El estilo vive AQUI, no en cada widget: ThemeData es el "CSS global" de
// Flutter. Cambia la semilla y cambia toda la app (hot reload para verlo).
//
// Novedad HU-06 (Día 5, cierre del Sprint 1): la app declara UN tema claro y
// UN tema oscuro con la MISMA semilla, y respeta la configuración del sistema
// con themeMode: ThemeMode.system en main.dart.

import 'package:flutter/material.dart';

/// Tema claro del Proyecto Guia CiudadAlerta (Material 3).
/// Semilla verde institucional #329B67, la misma del paquete del curso.
ThemeData temaCiudadAlerta() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF329B67));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
  );
}

/// Tema oscuro de la HU-06 (Día 5): misma semilla, modo oscuro.
/// Regla del curso: NUNCA dupliques colores a mano; deja que Material 3
/// genere la paleta oscura desde la misma semilla para mantener el contraste.
ThemeData temaCiudadAlertaOscuro() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF329B67),
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
  );
}
