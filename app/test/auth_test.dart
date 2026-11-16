// CiudadAlerta - Pruebas de autenticacion y perfil (Clase 9 / Dia 9)
//
// Cubre HU-08 SIN red (regla del curso: las pruebas corren contra el mock;
// Supabase Auth real se prueba en el laboratorio con los casos SP-01..SP-06
// de docs/36-casos-prueba-seguridad.md):
//   1. Validadores de credenciales (correo, contrasena, confirmacion).
//   2. Registro en modo demo: crea cuenta, abre sesion y persiste.
//   3. Registro duplicado y contrasena debil: rechazados con AuthError.
//   4. Login correcto/incorrecto (mensaje generico, sin enumerar cuentas).
//   5. Sesion persistente: reinicio del proceso = sesion restaurada.
//   6. Cierre de sesion: borra la sesion y el almacen.
//   7. Perfil: widget con invitado y con sesion (ProviderScope override).
//
// Comandos: fvm flutter test test/auth_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ciudadalerta/data/auth_repository.dart';
import 'package:ciudadalerta/data/auth_session.dart';
import 'package:ciudadalerta/providers/auth_provider.dart';
import 'package:ciudadalerta/screens/profile_screen.dart';

void main() {
  // Repositorio DEMO con almacen en memoria: nunca toca el canal de
  // plataforma (SecureSessionStore es para dispositivo real).
  MockAuthRepository repoDemo() =>
      MockAuthRepository(store: InMemorySessionStore());

  group('Validadores de credenciales (Dart puro)', () {
    test('validarCorreo acepta formatos razonables y rechaza los demas', () {
      expect(validarCorreo('rosa@correo.bo'), isNull);
      expect(validarCorreo('user123@gmail.com'), isNull);
      expect(validarCorreo(''), isNotNull);
      expect(validarCorreo('sin-arroba'), isNotNull);
      expect(validarCorreo('a@b'), isNotNull);
      expect(validarCorreo('dos@@puntos.com'), isNotNull);
    });

    test('validarContrasena aplica la politica 8+, mayuscula y numero', () {
      expect(validarContrasena('Ciudad2025'), isNull);
      expect(validarContrasena('corta1A'), isNotNull, reason: 'menos de 8');
      expect(validarContrasena('todoausculas1'), isNotNull, reason: 'sin mayuscula');
      expect(validarContrasena('SINNUMEROS'), isNotNull, reason: 'sin numero');
      expect(validarContrasena(''), isNotNull);
    });

    test('validarConfirmacion exige que ambas contrasenas coincidan', () {
      expect(validarConfirmacion('Ciudad2025', 'Ciudad2025'), isNull);
      expect(validarConfirmacion('Ciudad2025', 'Ciudad2026'), isNotNull);
      expect(validarConfirmacion('', 'Ciudad2025'), isNotNull);
    });
  });

  group('HU-08 en modo demo: MockAuthRepository', () {
    test('registrar crea la cuenta, abre sesion y la devuelve', () async {
      final repo = repoDemo();
      final usuario = await repo.registrar(
        nombre: 'Juan Apaza',
        correo: 'juan@correo.bo',
        contrasena: 'Clave2026',
      );
      expect(usuario.correo, 'juan@correo.bo');
      expect(usuario.nombre, 'Juan Apaza');
      expect(await repo.sesionActual(), isNotNull);
      expect((await repo.sesionActual())!.correo, 'juan@correo.bo');
    });

    test('registrar rechaza correo duplicado y contrasena debil', () async {
      final repo = repoDemo();
      await repo.registrar(
          nombre: 'Uno', correo: 'dup@correo.bo', contrasena: 'Clave2026');

      expect(
        () => repo.registrar(
            nombre: 'Dos', correo: 'DUP@correo.bo', contrasena: 'Clave2026'),
        throwsA(isA<AuthError>()),
        reason: 'el correo es unico (case-insensitive)',
      );
      expect(
        () => repo.registrar(
            nombre: 'Tres', correo: 'tres@correo.bo', contrasena: 'debil'),
        throwsA(isA<AuthError>()),
        reason: 'la politica de contrasenas tambien vive en el repositorio',
      );
    });

    test('iniciarSesion valida credenciales con mensaje generico', () async {
      final repo = repoDemo();
      await repo.registrar(
          nombre: 'Rosa', correo: 'rosa@demo.bo', contrasena: 'Clave2026');

      final u = await repo.iniciarSesion(
          correo: 'ROSA@demo.bo', contrasena: 'Clave2026');
      expect(u.correo, 'rosa@demo.bo');

      // Credenciales malas: AuthError con mensaje que NO revela si el
      // correo existe (MASVS-AUTH: no enumerar cuentas).
      try {
        await repo.iniciarSesion(
            correo: 'rosa@demo.bo', contrasena: 'Incorrecta1');
        fail('debia rechazar la contrasena incorrecta');
      } on AuthError catch (e) {
        expect(e.mensaje.toLowerCase(), contains('inválid'));
      }
      try {
        await repo.iniciarSesion(
            correo: 'nadie@demo.bo', contrasena: 'Clave2026');
        fail('debia rechazar un correo inexistente');
      } on AuthError catch (e) {
        expect(e.mensaje.toLowerCase(), contains('inválid'));
      }
    });

    test('sesion persistente: el proceso reinicia y la sesion sobrevive',
        () async {
      final store = InMemorySessionStore();
      final repo1 = MockAuthRepository(store: store);
      await repo1.iniciarSesion(
          correo: 'ciudadano@demo.bo', contrasena: 'Ciudad2025');

      // "Reinicio": NUEVO repositorio con el MISMO almacen (como Supabase
      // restaura el JWT del secure storage al arrancar la app).
      final repo2 = MockAuthRepository(store: store);
      final restaurada = await repo2.sesionActual();
      expect(restaurada, isNotNull);
      expect(restaurada!.correo, 'ciudadano@demo.bo');
      expect(restaurada.nombre, 'Rosa Mamani');
    });

    test('cerrarSesion borra la sesion viva y la persistida', () async {
      final store = InMemorySessionStore();
      final repo1 = MockAuthRepository(store: store);
      await repo1.registrar(
          nombre: 'Test', correo: 'logout@correo.bo', contrasena: 'Clave2026');
      expect(await repo1.sesionActual(), isNotNull);

      await repo1.cerrarSesion();
      expect(await repo1.sesionActual(), isNull);

      // Y no hay "sesion fantasma": un nuevo proceso tampoco la encuentra.
      final repo2 = MockAuthRepository(store: store);
      expect(await repo2.sesionActual(), isNull);
    });

    test('las cuentas demo del laboratorio existen con su contrasena', () {
      expect(usuariosDemo.containsKey('ciudadano@demo.bo'), isTrue);
      expect(usuariosDemo.containsKey('moderador@demo.bo'), isTrue);
      // La semilla respeta la politica del curso (8+, mayuscula y numero).
      for (final u in usuariosDemo.values) {
        expect(validarContrasena(u.contrasena), isNull,
            reason: 'la contrasena de ${u.nombre} debe cumplir la politica');
      }
    });
  });

  group('HU-08 en la UI: pantalla Perfil', () {
    // La pantalla navega con go_router (logout -> '/'): el test monta un
    // router minimo, mismo patron del widget_test del Dia 4.
    Widget appConPerfil(AuthRepository repo) => ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/perfil',
              routes: [
                GoRoute(
                  path: '/perfil',
                  builder: (_, __) => const ProfileScreen(),
                ),
                GoRoute(
                  path: '/',
                  builder: (_, __) =>
                      const Scaffold(body: Center(child: Text('Bienvenida'))),
                ),
                GoRoute(
                  path: '/registro',
                  builder: (_, __) =>
                      const Scaffold(body: Center(child: Text('Registro'))),
                ),
              ],
            ),
          ),
        );

    testWidgets('sin sesion muestra "Invitado" y accesos de autenticacion',
        (tester) async {
      await tester.pumpWidget(appConPerfil(repoDemo()));
      await tester.pumpAndSettle();

      expect(find.text('Invitado'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNothing);
    });

    testWidgets('con sesion muestra nombre, correo, auth.uid() y logout',
        (tester) async {
      final repo = repoDemo();
      await repo.registrar(
          nombre: 'Rosa Mamani', correo: 'rosa@correo.bo', contrasena: 'Clave2026');

      await tester.pumpWidget(appConPerfil(repo));
      await tester.pumpAndSettle();

      expect(find.text('Rosa Mamani'), findsOneWidget);
      expect(find.text('rosa@correo.bo'), findsOneWidget);
      expect(find.textContaining('auth.uid(): demo-'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('cerrar sesión (confirmado) borra la sesion y vuelve a /',
        (tester) async {
      final repo = repoDemo();
      await repo.registrar(
          nombre: 'Rosa Mamani', correo: 'rosa@correo.bo', contrasena: 'Clave2026');

      await tester.pumpWidget(appConPerfil(repo));
      await tester.pumpAndSettle();
      expect(find.text('Cerrar sesión'), findsOneWidget);

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      // Dialogo de confirmacion: evita cierres por toque accidental
      await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
      await tester.pumpAndSettle();

      // Navega a '/' (pantalla de bienvenida) y la sesion queda borrada.
      expect(find.text('Bienvenida'), findsOneWidget);
      expect(await repo.sesionActual(), isNull);
    });
  });
}
