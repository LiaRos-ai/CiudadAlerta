// CiudadAlerta - Pruebas alfa de widgets (Clase 5 / Dia 5)
//
// Introducción práctica a las pruebas de widgets, evidencia del Día 5:
//   1. HU-06: la app declara tema claro y oscuro (misma semilla).
//   2. HU-03: la lista renderiza los 8 reportes mock (conteo exacto).
//   3. HU-04: id inexistente muestra mensaje claro, sin crash (caso de borde).
//
// Dia 6: los tests de lista se montan dentro de ProviderScope (Riverpod).
// Comandos: fvm flutter test test/alfa_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ciudadalerta/main.dart';
import 'package:ciudadalerta/screens/report_detail_screen.dart';
import 'package:ciudadalerta/theme/app_theme.dart';
import 'package:ciudadalerta/widgets/report_card.dart';

void main() {
  testWidgets('HU-06: la app declara tema claro y oscuro con ThemeMode.system',
      (tester) async {
    // La misma semilla genera dos paletas con brillos distintos
    final claro = temaCiudadAlerta();
    final oscuro = temaCiudadAlertaOscuro();
    expect(claro.colorScheme.brightness, Brightness.light);
    expect(oscuro.colorScheme.brightness, Brightness.dark);

    // La app (MaterialApp.router) declara AMBOS temas y respeta el sistema
    await tester.pumpWidget(const ProviderScope(child: CiudadAlertaApp()));
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.darkTheme, isNotNull);
    expect(app.themeMode, ThemeMode.system);
  });

  testWidgets('HU-03: la lista renderiza los 8 reportes mock completos',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CiudadAlertaApp()));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle(); // espera la "carga" del mock (600 ms)

    // 8 tarjetas = los 8 reportes del mock (prueba de completitud)
    expect(find.byType(ReportCard), findsNWidgets(8));

    // Contexto real de La Paz y El Alto: uno por ciudad metropolitana
    expect(find.text('Bache profundo en la Av. Buenos Aires'), findsOneWidget);
    expect(find.text('Sardinera desbordada en la ceja de El Alto'),
        findsOneWidget);
  });

  testWidgets('HU-04: id inexistente muestra mensaje claro y no crashea',
      (tester) async {
    // Caso de borde del Dia 4, ahora automatizado como prueba alfa.
    // Dia 8: el detalle es ConsumerWidget y consulta por id (family
    // provider), asi que necesita ProviderScope y esperar la consulta.
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: ReportDetailScreen(id: 'RPT-999')),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('No existe el reporte'), findsOneWidget);
    expect(tester.takeException(), isNull); // sin excepciones = sin crash
  });
}
