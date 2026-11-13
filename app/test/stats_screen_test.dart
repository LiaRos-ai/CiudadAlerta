// CiudadAlerta - Pruebas de la pantalla de estadisticas (Clase 8 / Dia 8)
// HU-13: la pantalla muestra el grafico de barras por categoria y los
// chips por estado, calculados contra el repositorio (mock en tests).
//
// Clave de la prueba: el widget consume providers (estadisticas...Provider),
// asi que el arbol vive dentro de ProviderScope y pumpAndSettle espera las
// consultas del mock (300 ms), igual que haria con la red de Supabase.
//
// Comandos: fvm flutter test test/stats_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ciudadalerta/screens/stats_screen.dart';

void main() {
  testWidgets('HU-13: la pantalla muestra el grafico GROUP BY por categoria',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: StatsScreen()),
    ));
    await tester.pumpAndSettle(); // espera los agregados del mock

    // Titulo de la consulta agregada con el total del seed (8 reportes)
    expect(find.text('Reportes por categoría'), findsOneWidget);
    expect(find.textContaining('total: 8'), findsOneWidget);

    // El grafico de barras de fl_chart esta montado
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('HU-13: la leyenda lista las 5 categorias con sus conteos '
      'y los estados aparecen como chips', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: StatsScreen()),
    ));
    await tester.pumpAndSettle();

    // Las 5 categorias del catalogo (LEFT JOIN: ninguna desaparece).
    // Cada nombre aparece al menos 1 vez: el eje X del grafico y la
    // leyenda lo muestran (por eso findsWidgets, no findsOneWidget).
    expect(find.text('Via'), findsWidgets);
    expect(find.text('Luminaria'), findsWidgets);
    expect(find.text('Residuos'), findsWidgets);
    expect(find.text('Riesgo'), findsWidgets);
    expect(find.text('Agua'), findsWidgets);

    // Conteos del GROUP BY (C06 del Dia 7: 2/2/2/1/1)
    expect(find.textContaining('Recibido: 3'), findsOneWidget);
    expect(find.textContaining('En revision: 2'), findsOneWidget);
    expect(find.textContaining('En proceso: 2'), findsOneWidget);
    expect(find.textContaining('Resuelto: 1'), findsOneWidget);
  });
}
