// CiudadAlerta - Pruebas de widgets (Clase 4 / Dia 4)
// Verifica el flujo completo del Dia: HU-01 -> HU-02 -> HU-03 -> HU-04.

import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/main.dart';

void main() {
  testWidgets('HU-01: la pantalla de bienvenida muestra el formulario y '
      'valida el toggle de contraseña', (tester) async {
    await tester.pumpWidget(const CiudadAlertaApp());

    expect(find.text('CiudadAlerta'), findsWidgets);
    expect(find.text('Entrar'), findsOneWidget);

    // Estado local del Dia 3 sigue vivo: alternar visibilidad
    expect(find.text('Mostrar contraseña'), findsOneWidget);
    await tester.tap(find.text('Mostrar contraseña'));
    await tester.pump();
    expect(find.text('Ocultar contraseña'), findsOneWidget);
  });

  testWidgets('HU-02 + HU-03: Entrar navega al shell de pestañas y la '
      'lista muestra los reportes mock', (tester) async {
    await tester.pumpWidget(const CiudadAlertaApp());

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle(); // espera la "carga" del mock (600 ms)

    // Shell con las 4 pestañas de la HU-02
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Nuevo'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // HU-03: la lista carga los datos simulados
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Bache profundo en la Av. Buenos Aires'),
        findsOneWidget);
  });

  testWidgets('HU-04: tocar un reporte navega a su detalle con parámetro',
      (tester) async {
    await tester.pumpWidget(const CiudadAlertaApp());

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bache profundo en la Av. Buenos Aires'));
    await tester.pumpAndSettle();

    // El detalle muestra TODOS los campos del reporte RPT-001
    expect(find.text('RPT-001'), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);
    expect(find.text('URGENTE'), findsOneWidget);
  });
}
