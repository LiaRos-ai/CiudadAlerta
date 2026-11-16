// CiudadAlerta - Repositorio de autenticacion (Clase 9 / Dia 9)
// Sprint 2 (Hito 2): HU-08 - registro, inicio y cierre de sesion.
//
// Misma leccion de arquitectura del Dia 8, ahora con la AUTENTICACION:
// la UI no sabe QUIEN autentica. Dos implementaciones, UNA interfaz:
//
//   MockAuthRepository          -> modo demo sin credenciales: usuarios en
//                                  memoria + sesion simulada con SessionStore
//                                  (en app real SecureSessionStore; en pruebas
//                                  InMemorySessionStore).
//   SupabaseAuthRepository      -> Supabase Auth (supabase_auth_repository.dart):
//                                  signUp / signInWithPassword / signOut y el
//                                  JWT que el cliente guarda automaticamente.
//
// El provider authRepositoryProvider (providers/auth_provider.dart) decide
// cual inyectar segun existan las variables --dart-define del Dia 8.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_session.dart';

/// Contrato de autenticacion para TODA la app.
///
/// Regla de las capas (Dia 6): las pantallas llaman a estos metodos y
/// NUNCA al SDK de Supabase directamente.
abstract class AuthRepository {
  /// Registra una cuenta y abre sesion con ella (HU-08).
  /// Falla con AuthError si el correo ya existe o la clave es debil.
  Future<SessionUser> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  });

  /// Inicia sesion con correo y contrasena (HU-08).
  /// Falla con AuthError si las credenciales no son validas.
  Future<SessionUser> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  /// Cierra la sesion y borra el token guardado (HU-08).
  Future<void> cerrarSesion();

  /// Sesion actual (null si no hay). En modo real la lee Supabase del
  /// token persistido; en demo, del SessionStore.
  Future<SessionUser?> sesionActual();
}

/// Cuentas de la DEMO (por si el estudiante no trae su proyecto Supabase).
/// La politica de contrasenas del curso aplica igual en demo: es el mismo
/// validador el que corre.
const usuariosDemo = <String, ({String nombre, String contrasena})>{
  'ciudadano@demo.bo': (nombre: 'Rosa Mamani', contrasena: 'Ciudad2025'),
  'moderador@demo.bo': (nombre: 'Moderador GAMLP', contrasena: 'Moderador2025'),
};

/// Implementacion DEMO: usuarios en memoria + sesion en SessionStore.
///
/// Simula en un mapa lo que Supabase Auth hace con su tabla auth.users:
/// registrar = insert (con unicidad de correo), iniciarSesion = verificacion
/// de credenciales, sesionActual = leer el token guardado.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({SessionStore? store, Duration? latencia})
      : _store = store ?? SecureSessionStore(),
        _latencia = latencia ?? const Duration(milliseconds: 400);

  final SessionStore _store;
  final Duration _latencia;

  // "Tabla" de cuentas de esta ejecucion + las dos semillas de arriba.
  final Map<String, String> _claves = {
    for (final e in usuariosDemo.entries) e.key: e.value.contrasena,
  };
  final Map<String, String> _nombres = {
    for (final e in usuariosDemo.entries) e.key: e.value.nombre,
  };
  String? _sesion;

  @override
  Future<SessionUser> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    await Future.delayed(_latencia);
    final c = correo.trim().toLowerCase();
    // La politica de contrasenas corre TAMBIEN en el repositorio: la UI
    // la muestra como validacion, pero la "BD" es la ultima barrera.
    final error = validarContrasena(contrasena);
    if (error != null) throw AuthError(error);
    if (_claves.containsKey(c)) {
      throw const AuthError('Ese correo ya tiene una cuenta. Inicia sesión.');
    }
    _claves[c] = contrasena;
    _nombres[c] = nombre.trim();
    return _abrirSesion(c);
  }

  @override
  Future<SessionUser> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await Future.delayed(_latencia);
    final c = correo.trim().toLowerCase();
    final clave = _claves[c];
    // Mensaje generico a proposito (MASVS-AUTH): no revelar si el correo
    // existe; decir "credenciales invalidas" evita enumerar cuentas.
    if (clave == null || clave != contrasena) {
      throw const AuthError('Credenciales inválidas. Revisa tu correo y contraseña.');
    }
    return _abrirSesion(c);
  }

  @override
  Future<void> cerrarSesion() async {
    await Future.delayed(_latencia);
    _sesion = null;
    await _store.borrar();
  }

  @override
  Future<SessionUser?> sesionActual() async {
    // La sesion "vivo" de la demo manda; si el proceso reinicio, se
    // restaura desde el SessionStore (lo que hace Supabase con el JWT).
    if (_sesion != null) return _usuario(_sesion!);
    final guardada = await _store.leer();
    final correo = guardada?['correo'];
    return correo != null && _claves.containsKey(correo)
        ? _usuario(correo)
        : null;
  }

  // --- helpers ------------------------------------------------------------

  SessionUser _usuario(String correo) => SessionUser(
        id: 'demo-${correo.hashCode.abs()}',
        correo: correo,
        nombre: _nombres[correo],
      );

  Future<SessionUser> _abrirSesion(String correo) async {
    _sesion = correo;
    final u = _usuario(correo);
    // "Token" de demo: en modo real aqui vive el JWT de Supabase.
    await _store.guardar({'id': u.id, 'correo': u.correo, if (u.nombre != null) 'nombre': u.nombre!});
    return u;
  }
}
