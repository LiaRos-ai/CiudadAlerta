// CiudadAlerta - Pantalla de bienvenida e inicio de sesion (Clase 3 / Dia 3)
// HU-01: Como ciudadano quiero ver una pantalla de bienvenida e inicio de
// sesion para acceder a la app.  (solo UI: la autenticacion llega en el Hito 2)
//
// Criterios de aceptacion:
//  - Pantalla con logo, campos y boton.
//  - Sin errores de layout en 2 tamanos de pantalla (rota el emulador).
//
// Concepto del dia: StatefulWidget + setState. El estado local _ocultarClave
// alterna la visibilidad de la contrasena; sin setState la pantalla no se
// redibuja (error intencional explicado en la clase).

import 'package:flutter/material.dart';
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
          onPressed: () {}, // Hito 2: aquí irá la autenticación con Supabase
        ),
        TextButton(
          onPressed: () {}, // Día 4: navegará al formulario de registro
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }
}
