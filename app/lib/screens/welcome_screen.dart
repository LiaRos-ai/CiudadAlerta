// CiudadAlerta - Pantalla de bienvenida e inicio de sesion (Dia 4 -> 9)
// HU-01 (Dia 4): pantalla con logo, campos y boton. Solo UI.
// HU-08 (Dia 9): "Como usuario quiero registrarme e iniciar sesion para
// gestionar mis reportes". HOY el boton Entrar AUTENTICA de verdad.
//
// Tres formas de entrar, segun el dia y el entorno:
//   - Entrar            -> valida el Form y llama al repositorio de auth
//                          (Supabase Auth en modo real; mock en demo).
//   - Crear cuenta      -> /registro (nueva pantalla del Dia 9).
//   - Modo demo         -> sin cuenta: entra como invitado con el mock.
//                          Es la salida que el laboratorio usa cuando el
//                          estudiante aun no trae su proyecto Supabase.
//
// SESION PERSISTENTE (criterio HU-08): si al abrir la app ya hay sesion
// guardada (JWT de Supabase o SessionStore de la demo), aparece el boton
// "Continuar como {nombre}": la app recuerda al ciudadano entre sesiones.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth_session.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  bool _ocultarClave = true;
  bool _entrando = false;
  String? _errorGeneral;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  void _alternarVisibilidad() {
    setState(() {
      _ocultarClave = !_ocultarClave;
    });
  }

  /// HU-08: inicio de sesion REAL (valida -> llama al repo -> navega).
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _errorGeneral = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.iniciarSesion(
        correo: _correoCtrl.text,
        contrasena: _claveCtrl.text,
      );
      ref.invalidate(sesionActualProvider);
      if (mounted) context.go('/inicio');
    } on AuthError catch (e) {
      setState(() => _errorGeneral = e.mensaje);
    } catch (e) {
      setState(() => _errorGeneral = 'No se pudo iniciar sesión: $e');
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  /// Modo demo (sin cuenta): solo navega al shell, como el Dia 4.
  /// Sin credenciales compiladas no hay a quien preguntarle el JWT.
  void _entrarDemo() => context.go('/inicio');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // La sesion guardada decide si el boton "Continuar" aparece.
    final sesion = ref.watch(sesionActualProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('CiudadAlerta')),
      body: Center(
        // SingleChildScrollView + ConstrainedBox: la receta del curso para
        // formularios centrados que no rompen layout al rotar la pantalla.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: _formulario(theme, sesion),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulario(ThemeData theme, AsyncValue<SessionUser?> sesion) {
    final usuarioGuardado = sesion.valueOrNull;
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

        // ---- HU-08: credenciales con validacion ----
        CustomInput(
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          controller: _correoCtrl,
          validator: validarCorreo,
        ),
        const SizedBox(height: 12),
        CustomInput(
          label: 'Contraseña',
          obscure: _ocultarClave,
          prefixIcon: Icons.lock_outline,
          controller: _claveCtrl,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'La contraseña es obligatoria.' : null,
        ),
        TextButton(
          onPressed: _alternarVisibilidad,
          child: Text(_ocultarClave ? 'Mostrar contraseña' : 'Ocultar contraseña'),
        ),

        if (_errorGeneral != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _errorGeneral!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),

        // ---- Entrar: HU-08 con bloqueo async (patron del Dia 8) ----
        CustomButton(
          text: _entrando ? 'Entrando...' : 'Entrar',
          icon: Icons.login,
          onPressed: _entrando ? () {} : _iniciarSesion,
        ),
        TextButton(
          onPressed: () => context.go('/registro'), // HU-08: registro
          child: const Text('Crear cuenta'),
        ),

        const Divider(height: 32),
        // ---- Accesos sin credenciales / con sesion persistente ----
        if (usuarioGuardado != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CustomButton(
              text: 'Continuar como ${usuarioGuardado.nombreMostrable}',
              icon: Icons.account_circle_outlined,
              onPressed: _entrarDemo, // la sesion ya esta abierta
            ),
          ),
        OutlinedButton.icon(
          onPressed: _entrarDemo,
          icon: const Icon(Icons.science_outlined),
          label: const Text('Explorar en modo demo (sin cuenta)'),
        ),
      ],
    );
  }
}
