// CiudadAlerta - Cliente de Supabase (Clase 8 / Dia 8)
// Sprint 2 (Hito 2): conexion de la app a la BD creada el Dia 7.
//
// Como llega la configuracion: variables de entorno en tiempo de
// COMPILACION con --dart-define:
//
//   fvm flutter run \
//     --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...TU-CLAVE-ANON
//
// Por que --dart-define y no un archivo .env (flutter_dotenv):
//   - La clave NUNCA se versiona: no hay archivo que pegarse en un commit.
//   - Con --dart-define el valor queda dentro del binario compilado, no en
//     un asset legible con cualquier editor.
//   - El cierre del dia lo verifica: "hay claves en el repositorio?"
//     (git log -p y el historial completo deben estar limpios).
//
// La clave "anon" es publica por diseno: identifica el PROYECTO y las
// politicas RLS del Dia 7 deciden que filas puede leer/escribir. La clave
// "service_role" NUNCA va en una app movil.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuracion del proyecto Supabase leida en tiempo de compilacion.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// true si el equipo compilo con las dos variables.
  static bool get configurado => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Provider del cliente de Supabase.
///
/// Sin credenciales devuelve null: la app corre en MODO DEMO con el mock
/// del Dia 4 (misma interfaz, mismas pantallas) y el laboratorio no se
/// bloquea por falta de proyecto. Con credenciales, entrega el cliente
/// que el repositorio del Dia 8 usara para CRUD y consultas.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!SupabaseConfig.configurado) return null; // modo demo (mock)
  return SupabaseClient(SupabaseConfig.url, SupabaseConfig.anonKey);
});
