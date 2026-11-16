// CiudadAlerta - Pruebas de widgets (Clase 4 / Dia 4, actualizadas Dia 9)
// Verifica el flujo completo del dia: HU-01 -> HU-02 -> HU-03 -> HU-04.
// Dia 6: la app vive dentro de un ProviderScope (Riverpod).
// Dia 9 (HU-08): la bienvenida AUTENTICA. Sin credenciales de Supabase la
// app esta en modo demo, y el acceso rapido del laboratorio es el boton
// "Explorar en modo demo (sin cuenta)". Los tests usan ese boton y
// inyectan InMemorySessionStore para no tocar el secure storage del SO.
// El login REAL (credenciales + Supabase) se prueba en el laboratorio
// (casos SP-01..SP-06 de docs/36-casos-prueba-seguridad.md).

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ciudadalerta/data/auth_session.dart';
import 'package:ciudadalerta/main.dart';
import 'package:ciudadalerta/providers/auth_provider.dart';

void main() {
  testWidgets('HU-01: la pantalla de bienvenida muestra el formulario y '
      'valida el toggle de contraseña', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        // Dia 9: la sesion se prueba con almacen en memoria (sin SO)
        sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
      ],
      child: const CiudadAlertaApp(),
    ));

    expect(find.text('CiudadAlerta'), findsWidgets);
    expect(find.text('Entrar'), findsOneWidget);
    // Dia 9: los accesos nuevos de la HU-08
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Explorar en modo demo (sin cuenta)'), findsOneWidget);

    // Estado local del Dia 3 sigue vivo: alternar visibilidad
    expect(find.text('Mostrar contraseña'), findsOneWidget);
    await tester.tap(find.text('Mostrar contraseña'));
    await tester.pump();
    expect(find.text('Ocultar contraseña'), findsOneWidget);
  });

  testWidgets('HU-08: Entrar con campos vacios NO navega (valida primero)',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionStoreProvider.overrideWithValue(InMemorySessionStore())],
      child: const CiudadAlertaApp(),
    ));

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    // El formulario bloquea el envio y muestra SUS errores
    expect(find.text('El correo es obligatorio.'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria.'), findsOneWidget);
    // Y seguimos en la bienvenida (no hay pestañas del shell en pantalla)
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('HU-02 + HU-03: el modo demo navega al shell y la lista '
      'muestra los reportes mock', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionStoreProvider.overrideWithValue(InMemorySessionStore())],
      child: const CiudadAlertaApp(),
    ));

    await tester.tap(find.text('Explorar en modo demo (sin cuenta)'));
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
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionStoreProvider.overrideWithValue(InMemorySessionStore())],
      child: const CiudadAlertaApp(),
    ));

    await tester.tap(find.text('Explorar en modo demo (sin cuenta)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bache profundo en la Av. Buenos Aires'));
    await tester.pumpAndSettle();

    // El detalle muestra TODOS los campos del reporte RPT-001
    expect(find.text('RPT-001'), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);
    expect(find.text('URGENTE'), findsOneWidget);
  });
}
