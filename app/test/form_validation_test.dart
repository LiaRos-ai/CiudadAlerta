// CiudadAlerta - Pruebas del formulario (Clase 4 / Dia 4)
// HU-05: el formulario NO envía si es inválido, y sí confirma si es válido.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/screens/new_report_screen.dart';

void main() {
  testWidgets('HU-05: envio invalido muestra los 3 mensajes de error y no confirma',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewReportScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: NewReportScreen()));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Título del problema'), 'Bache');
    await tester.tap(find.text('Enviar reporte'));
    await tester.pump();

    expect(find.text('Ingresa un título de al menos 5 caracteres.'),
        findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('HU-05: formulario valido muestra la confirmación',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewReportScreen()));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Título del problema'),
        'Bache en la calle Illampu');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descripción del problema'),
        'Bache grande frente al colegio, desde el lunes pasado.');
    // Seleccionar la categoría en el DropdownButtonFormField
    await tester.tap(find.text('Categoría'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vía').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enviar reporte'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Reporte registrado'), findsOneWidget);
  });
}
