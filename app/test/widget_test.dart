// CiudadAlerta - Prueba de widgets (Clase 3 / Dia 3)
// Verifica la HU-01: la pantalla de bienvenida muestra el formulario.

import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/main.dart';

void main() {
  testWidgets('HU-01: la pantalla de bienvenida muestra el formulario',
      (tester) async {
    await tester.pumpWidget(const CiudadAlertaApp());

    // La app muestra su marca y el formulario de acceso
    expect(find.text('CiudadAlerta'), findsWidgets);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);

    // El estado local funciona: alternar la visibilidad de la contrasena
    expect(find.text('Mostrar contraseña'), findsOneWidget);
    await tester.tap(find.text('Mostrar contraseña'));
    await tester.pump();
    expect(find.text('Ocultar contraseña'), findsOneWidget);
  });
}
