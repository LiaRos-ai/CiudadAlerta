// CiudadAlerta - Pruebas del formulario (Clase 4 / Dia 4, actualizadas Dia 8)
// HU-05: el formulario NO envía si es inválido, y sí confirma si es válido.
//
// Cambios del Dia 8 (HU-10): el envío ahora es ASINCRONO (INSERT/UPDATE
// contra la BD via repositorio), la pantalla es ConsumerStatefulWidget y
// el botón se bloquea mientras guarda. Los tests se ajustan:
//   - MaterialApp vive dentro de ProviderScope (los Consumer la requieren).
//   - Tras el tap en "Enviar reporte" se espera con pumpAndSettle el
//     INSERT/UPDATE del repositorio (el mock tarda 600 ms, como la red).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/screens/new_report_screen.dart';

void main() {
  testWidgets('HU-05: envio invalido muestra los 3 mensajes de error y no confirma',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: NewReportScreen()),
    ));

    // Enviar sin llenar nada
    await tester.tap(find.text('Enviar reporte'));
    await tester.pump();

    // Mensajes de error claros, uno por campo
    expect(find.text('El título es obligatorio.'), findsOneWidget);
    expect(find.text('Selecciona una categoría.'), findsOneWidget);
    expect(find.text('Describe el problema con al menos 10 caracteres.'),
        findsOneWidget);

    // El SnackBar de éxito NO aparece (criterio: no envía si es inválido)
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('HU-05: título demasiado corto es rechazado', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: NewReportScreen()),
    ));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Título del problema'), 'Bache');
    await tester.tap(find.text('Enviar reporte'));
    await tester.pump();

    expect(find.text('Ingresa un título de al menos 5 caracteres.'),
        findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('HU-05 + HU-10: formulario valido registra en la BD y confirma',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: NewReportScreen()),
    ));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Título del problema'),
        'Bache en la calle Illampu');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descripción del problema'),
        'Bache grande frente al colegio, desde el lunes pasado.');
    // Seleccionar la categoría en el DropdownButtonFormField (catálogo
    // del curso: Via sin tilde, igual que en la BD del Día 7)
    await tester.tap(find.text('Categoría'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Via').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enviar reporte'));
    // Dia 8: el envio es async (INSERT del repositorio) -> pumpAndSettle
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Reporte registrado'), findsOneWidget);
  });
}
