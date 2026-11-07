// CiudadAlerta - Pantalla de bienvenida e inicio de sesion (Clase 4 / Dia 4)
// HU-01: Como ciudadano quiero ver una pantalla de bienvenida e inicio de
// sesion para acceder a la app.  (solo UI: la autenticacion llega en el Hito 2)
//
// NOVEDAD DEL DIA 4: el boton Entrar ya no es un boton muerto; navega al
// shell de pestañas con context.go('/inicio') (HU-02). Es la primera
// conexión entre dos historias de usuario: HU-01 -> HU-02.
//
// Concepto heredado del Dia 3: StatefulWidget + setState para el estado
// local _ocultarClave (visibilidad de la contrasena).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _ocultarClave = true;

  void _alternarVisibilidad() {
    setState(() {
      _ocultarClave = !_ocultarClave;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('CiudadAlerta')),
      body: Center(
        // SingleChildScrollView + ConstrainedBox: la receta del curso para
        // formularios centrados que no rompen layout al rotar la pantalla.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _formulario(theme),
          ),
        ),
      ),
    );
  }

  Widget _formulario(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.location_city, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'CiudadAlerta',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          'Reporta los problemas de tu barrio',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        CustomInput(
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),
        CustomInput(
          label: 'Contraseña',
          obscure: _ocultarClave,
          prefixIcon: Icons.lock_outline,
        ),
        TextButton(
          onPressed: _alternarVisibilidad,
          child: Text(_ocultarClave ? 'Mostrar contraseña' : 'Ocultar contraseña'),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Entrar',
          icon: Icons.login,
          // Dia 4: navega al shell de pestañas (HU-02). go() reemplaza la
          // pantalla actual; push() apilaría una nueva encima.
          onPressed: () => context.go('/inicio'),
        ),
        TextButton(
          onPressed: () {}, // Hito 2: formulario de registro (Supabase Auth)
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }
}
