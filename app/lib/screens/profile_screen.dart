// CiudadAlerta - Pestaña Perfil (placeholder del Dia 4)
//
// La autenticacion real (HU-08, Supabase Auth) llega en el Sprint 2, Día 9.
// Hoy la pestaña completa el shell de la HU-02.

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text('Tu perfil llega en el Sprint 2 (HU-08)',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Con Supabase Auth: registro, inicio de sesión '
                'y "mis reportes" del ciudadano autenticado.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
