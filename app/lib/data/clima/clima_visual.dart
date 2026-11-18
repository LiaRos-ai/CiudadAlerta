// CiudadAlerta - Capa visual del clima (Día 11 / Sprint 3)
//
// Open-Meteo no devuelve texto ni íconos: devuelve un CÓDIGO NUMÉRICO
// (estándar WMO, World Meteorological Organization). Traducirlo a algo
// que el usuario entiende (descripción + ícono + color) es responsabilidad
// de la app, y vive en SU capa de datos, no en la pantalla.
//
// ¿Por qué un mapeo y no un if en el widget?
//   - El widget (ClimaCard) debe ser simple: pinta lo que recibe.
//   - El mapeo es PURA y determinista: se prueba sin red y sin widget
//     (la misma regla de las estadísticas del Día 8).

import 'package:flutter/material.dart';

import 'clima.dart';

/// Cómo se pinta un código WMO en CiudadAlerta.
class ClimaVisual {
  final String descripcion;
  final IconData icono;
  final Color color;

  const ClimaVisual(this.descripcion, this.icono, this.color);
}

/// Tabla WMO -> visual, resumida en los rangos que La Paz / El Alto
/// realmente experimenta (altiplano: sol, nubes, viento, lluvia, nieve
/// ocasional y tormentas de temporada).
ClimaVisual visualDeClima(Clima clima) {
  final c = clima.codigo;
  return switch (c) {
    0 => const ClimaVisual('Despejado', Icons.wb_sunny, Color(0xFFF5A623)),
    1 || 2 => const ClimaVisual(
        'Parcialmente nublado', Icons.partly_cloudy_day, Color(0xFF56CACA)),
    3 => const ClimaVisual('Nublado', Icons.wb_cloudy, Color(0xFF7D8782)),
    45 || 48 =>
      const ClimaVisual('Niebla', Icons.foggy, Color(0xFF9FB4A7)),
    >= 51 && <= 57 => const ClimaVisual(
        'Llovizna', Icons.grain, Color(0xFF4A90D9)),
    >= 61 && <= 67 =>
      const ClimaVisual('Lluvia', Icons.umbrella, Color(0xFF3B7DD8)),
    >= 71 && <= 77 =>
      const ClimaVisual('Nieve', Icons.ac_unit, Color(0xFF86C5DA)),
    >= 80 && <= 82 => const ClimaVisual(
        'Chubascos', Icons.thunderstorm, Color(0xFF2E6FB5)),
    >= 95 && <= 99 => const ClimaVisual(
        'Tormenta eléctrica', Icons.flash_on, Color(0xFF9C7F45)),
    _ => const ClimaVisual(
        'Clima desconocido', Icons.help_outline, Color(0xFF7D8782)),
  };
}
