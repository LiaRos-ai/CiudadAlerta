// CiudadAlerta - Providers de autenticacion (Clase 9 / Dia 9)
// Sprint 2 (Hito 2): el estado de la sesion como dato GLOBAL de la app.
//
// Por que la sesion vive en Riverpod y no en un singleton:
//   - Welcome (HU-08), Perfil y el detalle de reportes (HU-11: la foto se
//     guarda en una carpeta del usuario) necesitan leerla: providers la
//     comparten con cache y reactividad, igual que la lista del Dia 8.
//   - Las pruebas sobreescriben authRepositoryProvider con el mock: el
//     mismo patron de override que el Dia 6 enseno con los repositorios.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/auth_session.dart';
import '../data/supabase_auth_repository.dart';
import '../data/supabase_config.dart';

/// Donde se guarda la sesion persistente.
/// App real: almacen cifrado del SO. Pruebas: memoria (sin canales).
final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore();
});

/// Implementacion de autenticacion activa (misma decision del Dia 8:
/// si hay credenciales compiladas, Supabase; si no, modo demo).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  if (cliente != null) {
    return SupabaseAuthRepository(cliente);
  }
  return MockAuthRepository(store: ref.watch(sessionStoreProvider));
});

/// Sesion actual de la app (null = invitado).
/// Se invalida tras registrar / iniciar / cerrar sesion: las pantallas
/// que la miran se refrescan solas (reactividad del Dia 6, otra vez).
final sesionActualProvider = FutureProvider<SessionUser?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.sesionActual();
});
