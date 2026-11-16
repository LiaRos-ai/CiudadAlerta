// CiudadAlerta - Autenticacion contra Supabase Auth (Clase 9 / Dia 9)
// Sprint 2 (Hito 2): HU-08 con la implementacion REAL.
//
// Que hace Supabase Auth por nosotros (y por eso el curso lo elige):
//   - signUp(email, password): crea la cuenta en auth.users y (si el
//     proyecto lo configura) envia el correo de confirmacion.
//   - signInWithPassword(email, password): valida credenciales y devuelve
//     la sesion con su JWT (access_token ~1 h + refresh_token).
//   - El cliente supabase_flutter PERSISTE la sesion sola: al reiniciar la
//     app, client.auth.currentSession ya esta restaurada (refresh token).
//   - currentSession => auth.uid(): el mismo uid que las politicas RLS del
//     Dia 9 (db/rls_dia9.sql) usan para autorizar cada fila.
//
// La app NUNCA ve ni firma el secreto del JWT: solo recibe el token listo.

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'auth_session.dart';

/// Implementacion real de AuthRepository sobre Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<SessionUser> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    try {
      // data.user llega SIEMPRE (con o sin correo de confirmacion activo);
      // la sesion solo llega si el proyecto permite login inmediato.
      final res = await _cliente.auth.signUp(email: correo, password: contrasena);
      final u = res.user;
      if (u == null) {
        throw const AuthError('No se pudo crear la cuenta. Intenta de nuevo.');
      }
      // El nombre viaja en user_metadata: es la columna que la UI puede
      // leer sin tocar auth.users (tabla protegida del esquema auth).
      await _cliente.auth.updateUser(
        UserAttributes(data: {'nombre': nombre.trim()}),
      );
      final sesion = res.session;
      if (sesion != null) {
        return SessionUser(id: u.id, correo: u.email ?? correo, nombre: nombre.trim());
      }
      // Con confirmacion de correo pendiente: cuenta creada, sin sesion.
      throw const AuthError(
          'Cuenta creada. Confirma tu correo y luego inicia sesión.');
    } on AuthException catch (e) {
      // Traduccion de errores del SDK a mensajes de la UI (capas).
      throw AuthError(_mensajeAmigable(e.message));
    }
  }

  @override
  Future<SessionUser> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final res = await _cliente.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );
      final u = res.user;
      if (u == null) {
        throw const AuthError('Credenciales inválidas. Revisa tu correo y contraseña.');
      }
      return SessionUser(
        id: u.id,
        correo: u.email ?? correo,
        nombre: u.userMetadata?['nombre'] as String?,
      );
    } on AuthException catch (e) {
      throw AuthError(_mensajeAmigable(e.message));
    }
  }

  @override
  Future<void> cerrarSesion() async {
    // Borra el JWT del storage seguro que administra el cliente.
    await _cliente.auth.signOut();
  }

  @override
  Future<SessionUser?> sesionActual() async {
    final u = _cliente.auth.currentUser;
    if (u == null) return null; // sin sesion o token expirado sin refresh
    return SessionUser(
      id: u.id,
      correo: u.email ?? '',
      nombre: u.userMetadata?['nombre'] as String?,
    );
  }

  /// Mapeo de mensajes de AuthException a texto util en la clase.
  /// Supabase devuelve mensajes tecnicos en ingles: la UI merece mejor.
  static String _mensajeAmigable(String mensaje) {
    final m = mensaje.toLowerCase();
    if (m.contains('invalid login')) {
      return 'Credenciales inválidas. Revisa tu correo y contraseña.';
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'Ese correo ya tiene una cuenta. Inicia sesión.';
    }
    if (m.contains('password')) {
      return 'La contraseña no cumple la política (8+, mayúscula y número).';
    }
    if (m.contains('email not confirmed')) {
      return 'Confirma tu correo (revisa tu bandeja) e intenta de nuevo.';
    }
    return 'No se pudo completar la autenticación: $mensaje';
  }
}
