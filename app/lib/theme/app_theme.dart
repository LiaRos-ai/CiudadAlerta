// CiudadAlerta - Tema del curso (Clase 3 / Dia 3)
//
// El estilo vive AQUI, no en cada widget: ThemeData es el "CSS global" de
// Flutter. Cambia la semilla y cambia toda la app (hot reload para verlo).

import 'package:flutter/material.dart';

/// Tema del Proyecto Guia CiudadAlerta (Material 3).
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
