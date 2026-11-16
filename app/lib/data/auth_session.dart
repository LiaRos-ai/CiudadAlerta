// CiudadAlerta - Autenticacion: modelo de sesion y validadores (Clase 9 / Dia 9)
// Sprint 2 (Hito 2) - Tema: "Autenticacion, seguridad de datos y recursos nativos".
//
// HU-08: "Como usuario quiero registrarme e iniciar sesion para gestionar
// mis reportes". Criterios de aceptacion: Supabase Auth; sesion persistente;
// cierre de sesion.
//
// Conceptos de teoria que este archivo materializa:
//   - AUTENTICACION vs AUTORIZACION: autenticar es demostrar QUIEN eres
//     (correo + contrasena -> JWT); autorizar es decidir QUE puedes hacer
//     (eso lo aplican las politicas RLS del Dia 7, refinadas hoy).
//   - JWT (JSON Web Token): Supabase Auth responde a un login correcto con
//     un token firmado (header.payload.signature) que la app envia en cada
//     peticion. La app NUNCA lo inventa ni lo firma: solo lo guarda y lo usa.
//   - SESION SEGURA: el token NO se guarda en shared_preferences (texto
//     plano en el dispositivo) sino en flutter_secure_storage, que usa el
//     Keystore de Android / Keychain de iOS: cifrado por el SO.
//
// El archivo mezcla DART PURO (validadores, modelo: probables en
// test/auth_test.dart) con una clase que usa secure storage; las pruebas
// inyectan InMemorySessionStore y NUNCA tocan el canal de plataforma.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// El usuario que abrio sesion (lo entrega Supabase Auth o el mock demo).
///
/// Supabase Auth llama "user" a su objeto con id/emails/app_metadata; aqui
/// nos quedamos con lo que la UI necesita (principio YAGNI del curso).
class SessionUser {
  const SessionUser({
    required this.id,
    required this.correo,
    this.nombre,
  });

  /// UUID que Supabase Auth genera al registrar (profiles.id lo hereda).
  final String id;
  final String correo;
  final String? nombre;

  /// Lo que la pantalla Perfil muestra como titulo: nombre si existe,
  /// si no la parte del correo antes de la @.
  String get nombreMostrable {
    if (nombre != null && nombre!.trim().isNotEmpty) return nombre!.trim();
    final usuario = correo.split('@').first;
    return usuario.isEmpty ? 'Ciudadano' : usuario;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'correo': correo,
        if (nombre != null) 'nombre': nombre,
      };

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
        id: json['id'] as String,
        correo: json['correo'] as String,
        nombre: json['nombre'] as String?,
      );
}

/// Error de autenticacion con mensaje AMIGABLE para la UI.
///
/// Por que una clase propia y no lanzar Exception('...'):
///   - La UI necesita distinguir credenciales malas (mostrar "revisa tu
///     contrasena") de errores de red (mostrar "revisa tu conexion").
///   - Supabase lanza AuthException; el repositorio la TRADUCE a esta clase
///     para que ninguna pantalla conozca detalles del SDK (capas, Dia 6).
class AuthError implements Exception {
  const AuthError(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

// ---------------------------------------------------------------------------
// VALIDADORES (Dart puro, probados en test/auth_test.dart)
// La politica del curso para la contrasena: minimo 8 caracteres, al menos
// una mayuscula y un numero. Es la misma regla del formulario de registro.
// ---------------------------------------------------------------------------

/// Devuelve null si el correo es razonable; si no, el mensaje de error.
String? validarCorreo(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El correo es obligatorio.';
  // Expresion regular simple: texto@texto.punto (no pretende validar TODO
  // el RFC 5322; para eso esta el correo de confirmacion de Supabase).
  final patron = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!patron.hasMatch(v)) return 'Ingresa un correo válido (ej.: tu@correo.bo).';
  return null;
}

/// Devuelve null si la contrasena cumple la politica; si no, el mensaje.
String? validarContrasena(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'La contraseña es obligatoria.';
  if (v.length < 8) return 'Mínimo 8 caracteres.';
  if (!v.contains(RegExp(r'[A-Z]'))) {
    return 'Incluye al menos una mayúscula.';
  }
  if (!v.contains(RegExp(r'[0-9]'))) {
    return 'Incluye al menos un número.';
  }
  return null;
}

/// El formulario pide la contrasena dos veces: esta regla compara ambas.
String? validarConfirmacion(String? value, String original) {
  if ((value ?? '').isEmpty) return 'Confirma tu contraseña.';
  if (value != original) return 'Las contraseñas no coinciden.';
  return null;
}

// ---------------------------------------------------------------------------
// SESION PERSISTENTE: SessionStore
//
// HU-08 pide "sesion persistente": si cierro la app y vuelvo, sigo dentro.
// Supabase Auth lo hace solo en modo real; en MODO DEMO lo simulamos con
// la MISMA abstraccion:
//   - SecureSessionStore   -> flutter_secure_storage (Keystore/Keychain):
//                             lo que la teoria recomienda para el JWT.
//   - InMemorySessionStore -> solo para pruebas (no toca el SO).
// ---------------------------------------------------------------------------

/// Contrato minimo de guardado de la sesion (clave -> valor cifrado).
abstract class SessionStore {
  Future<void> guardar(Map<String, String> datos);
  Future<Map<String, String>?> leer();
  Future<void> borrar();
}

/// Implementacion REAL con flutter_secure_storage.
///
/// Por que cifrado y no shared_preferences (lo que usa el borrador HU-07):
/// un borrador de titulo es dato inocuo; el JWT es la LLAVE de la cuenta
/// del ciudadano. OWASP MASVS-STORAGE-1: "la app guarda credenciales solo
/// en el almacen cifrado del SO".
///
/// Las pruebas NUNCA construyen esta clase (usarian el canal de plataforma
/// del SO): inyectan InMemorySessionStore.
class SecureSessionStore implements SessionStore {
  SecureSessionStore();

  static const _ns = 'ciudadalerta.sesion';

  @override
  Future<void> guardar(Map<String, String> datos) async {
    final storage = const FlutterSecureStorage();
    for (final e in datos.entries) {
      await storage.write(key: '$_ns.${e.key}', value: e.value);
    }
  }

  @override
  Future<Map<String, String>?> leer() async {
    final storage = const FlutterSecureStorage();
    final id = await storage.read(key: '$_ns.id');
    final correo = await storage.read(key: '$_ns.correo');
    final nombre = await storage.read(key: '$_ns.nombre');
    if (id == null || correo == null) return null;
    return {'id': id, 'correo': correo, if (nombre != null) 'nombre': nombre};
  }

  @override
  Future<void> borrar() async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: '$_ns.id');
    await storage.delete(key: '$_ns.correo');
    await storage.delete(key: '$_ns.nombre');
  }
}

/// Implementacion de PRUEBAS y demo en memoria (sin canal de plataforma).
/// Muere con el proceso: por eso la app real usa SecureSessionStore.
class InMemorySessionStore implements SessionStore {
  Map<String, String>? _datos;

  @override
  Future<void> guardar(Map<String, String> datos) async {
    _datos = Map.of(datos);
  }

  @override
  Future<Map<String, String>?> leer() async => _datos == null
      ? null
      : Map<String, String>.unmodifiable(_datos!);

  @override
  Future<void> borrar() async => _datos = null;
}
