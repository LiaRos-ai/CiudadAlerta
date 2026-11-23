// CiudadAlerta - Pestaña Perfil (Dia 4 -> 9)
//
// Dia 4: placeholder para completar el shell de la HU-02.
// Dia 9 (HU-08): la pestaña muestra la SESION REAL del ciudadano:
//   - Con sesion: nombre (o usuario del correo), el correo, el id del
//     usuario (auth.uid()) y el boton Cerrar sesion.
//   - Sin sesion: invitado + accesos a iniciar sesion / crear cuenta.
//
// Criterio "cierre de sesion" de HU-08: repo.cerrarSesion() borra el JWT
// (Supabase) o el registro del SessionStore (demo), se invalida
// sesionActualProvider y la UI vuelve a "invitado" sin recargar nada.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sesion = ref.watch(sesionActualProvider);
    final usuario = sesion.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: usuario == null
                ? _invitado(context, theme)
                : _conSesion(context, theme, ref, usuario),
          ),
        ),
      ),
    );
  }

  // --- Sin sesion (estado inicial o tras cerrar sesion) -------------------
  Widget _invitado(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 64, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text('Invitado', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para que tus reportes queden a tu nombre '
          '(HU-08: Supabase Auth + RLS).',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión'),
        ),
        TextButton(
          onPressed: () => context.go('/registro'),
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }

  // --- Con sesion (HU-08 completa) ----------------------------------------
  Widget _conSesion(
      BuildContext context, ThemeData theme, WidgetRef ref, usuario) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 36,
          child: Text(
            usuario.nombreMostrable.characters.first.toUpperCase(),
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        Text(usuario.nombreMostrable, style: theme.textTheme.titleLarge),
        Text(usuario.correo, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        // El id que las politicas RLS comparan (auth.uid() = usuario_id):
        // util para que el estudiante VEA quien es en la BD.
        SelectableText(
          'auth.uid(): ${usuario.id}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: const Text('Mis reportes'),
          subtitle: const Text('Filtro por autor (RLS: solo los tuyos)'),
          onTap: () => context.go('/inicio'),
        ),
        const Divider(),
        // HU-08: cierre de sesion con confirmacion (evitar toques accidentales)
        FilledButton.tonalIcon(
          onPressed: () => _confirmarCierre(context, ref),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }

  Future<void> _confirmarCierre(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
            'Tendrás que volver a autenticarte para reportar a tu nombre.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final repo = ref.read(authRepositoryProvider);
    await repo.cerrarSesion(); // borra el JWT / la sesion demo
    ref.invalidate(sesionActualProvider); // el perfil refresca a invitado
    if (context.mounted) context.go('/'); // back a la pantalla de entrada
  }
}
