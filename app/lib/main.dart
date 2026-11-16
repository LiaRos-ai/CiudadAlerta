// CiudadAlerta - Proyecto Guia · Aplicaciones Moviles I (SIS-0180)
// Clase 9 (Dia 9): autenticacion, seguridad de datos y recursos nativos.
//
// Novedades de hoy en la app (Sprint 2 - Hito 2):
//   - HU-08: registro e inicio de sesion con Supabase Auth
//     (lib/data/supabase_auth_repository.dart) con sesion persistente y
//     cierre de sesion; en modo demo, MockAuthRepository + SessionStore.
//   - El INSERT de reportes ahora firma con auth.uid() (usuario logueado)
//     y las politicas RLS refinadas (db/rls_dia9.sql) aplican por usuario.
//   - HU-11: foto de evidencia con image_picker + permission_handler,
//     subida a Supabase Storage (bucket fotos-reportes) y miniatura en
//     el detalle (report_photos via select anidado).
//   - docs/36-casos-prueba-seguridad.md: la evidencia oficial del dia
//     (casos SP-01..SP-12 con lista de cotejo).
//
// Como correr hoy:
//   fvm flutter run   # modo DEMO (mock + registro local sin red)
//   fvm flutter run \
//     --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=TU-CLAVE-ANON
//
// Mapa del repositorio al cierre del Dia 9 (tags v0.0.0-sprint0 .. v0.8.0-dia9):
//   lib/routing/app_router.dart          -> go_router: + /registro (Dia 9)
//   lib/data/report.dart                 -> modelo Report (+ fotoUrl HU-11)
//   lib/data/mock_reports.dart           -> datos simulados (modo demo)
//   lib/data/reports_repository.dart     -> interfaz (+ adjuntarFoto Dia 9)
//   lib/data/supabase_reports_repository.dart -> CRUD/consultas + auth.uid()
//   lib/data/auth_session.dart           -> NUEVO Dia 9: SessionUser + validadores
//   lib/data/auth_repository.dart        -> NUEVO Dia 9: interfaz + mock HU-08
//   lib/data/supabase_auth_repository.dart -> NUEVO Dia 9: Supabase Auth
//   lib/data/photo_storage.dart          -> NUEVO Dia 9: rutas + Storage HU-11
//   lib/providers/auth_provider.dart     -> NUEVO Dia 9: sesion como estado global
//   lib/screens/register_screen.dart     -> NUEVO Dia 9: crear cuenta (HU-08)
//   lib/screens/welcome_screen.dart      -> Dia 9: login real + modo demo
//   lib/screens/profile_screen.dart      -> Dia 9: sesion, auth.uid() y logout
//   lib/screens/new_report_screen.dart   -> Dia 9: elegir/validar/subir foto
//   lib/screens/report_detail_screen.dart-> Dia 9: miniatura de la evidencia
//   db/rls_dia9.sql                      -> NUEVO Dia 9: RLS por usuario + Storage
//   docs/36-casos-prueba-seguridad.md    -> evidencia oficial (SP-01..SP-12)
//
// Practica de la clase:
//   1. Modo DEMO: crea una cuenta desde "Crear cuenta" e inicia sesion;
//      cierra la app y vuelve: el boton "Continuar como..." restaura la
//      sesion (SessionStore con secure storage).
//   2. Con credenciales: el mismo registro crea la cuenta en Supabase Auth
//      y el JWT vive en el almacen cifrado del SO.
//   3. Crea un reporte con foto: la miniatura aparece en el detalle; en la
//      BD, report_photos guarda el URL y Storage el archivo.
//   4. Ejecuta los casos de seguridad de docs/36: el cierre del dia es la
//      prueba cruzada entre equipos (SP-07).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() => runApp(
      // ProviderScope: el contenedor raiz de Riverpod. Va SIEMPRE encima
      // de MaterialApp.router; sin el, ref.watch no encuentra providers.
      const ProviderScope(
        child: CiudadAlertaApp(),
      ),
    );

class CiudadAlertaApp extends StatelessWidget {
  const CiudadAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CiudadAlerta',
      debugShowCheckedModeBanner: false,
      theme: temaCiudadAlerta(),            // tema claro (Material 3)
      darkTheme: temaCiudadAlertaOscuro(),  // HU-06: tema oscuro
      themeMode: ThemeMode.system,          // respeta la configuración del sistema
      routerConfig: appRouter,              // go_router: el mapa de rutas del Dia 4
    );
  }
}
