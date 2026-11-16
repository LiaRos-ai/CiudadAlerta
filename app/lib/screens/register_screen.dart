// CiudadAlerta - Registro de cuenta (Clase 9 / Dia 9)
// HU-08: "Como usuario quiero registrarme e iniciar sesion para gestionar
// mis reportes". Esta pantalla cubre la mitad de REGISTRO del criterio
// "Supabase Auth; sesion persistente; cierre de sesion".
//
// Lecciones de teoria que se aplican aqui:
//   - La contrasena se pide DOS veces (porque al escribirla no se ve) y
//     la politica minima (8+, mayuscula, numero) corre en el validador
//     del formulario Y en el repositorio (defensa en profundidad: MASVS).
//   - Los errores de auth se muestran EN PANTALLA (SnackBar/Texto de error)
//     y el boton se bloquea mientras corre la peticion: mismo patron async
//     del formulario del Dia 8 (evitar el doble tap = doble signUp).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../data/auth_session.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _ocultar = true;
  bool _registrando = false;
  String? _errorGeneral; // error del repositorio (ej. correo duplicado)

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _registrando = true;
      _errorGeneral = null;
    });
    final repo = ref.read(authRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.registrar(
        nombre: _nombreCtrl.text,
        correo: _correoCtrl.text,
        contrasena: _claveCtrl.text,
      );
      ref.invalidate(sesionActualProvider); // el perfil refresca solo
      if (mounted) context.go('/inicio');
    } on AuthError catch (e) {
      setState(() => _errorGeneral = e.mensaje);
    } catch (e) {
      setState(() => _errorGeneral = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _registrando = false);
      messenger.hideCurrentSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomInput(
                  label: 'Nombre y apellido',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Tu nombre aparece en tus reportes.'
                      : null,
                  controller: _nombreCtrl,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  controller: _correoCtrl,
                  validator: validarCorreo,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Contraseña (8+, mayúscula y número)',
                  obscure: _ocultar,
                  prefixIcon: Icons.lock_outline,
                  controller: _claveCtrl,
                  validator: validarContrasena,
                ),
                TextButton(
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                  child: Text(_ocultar ? 'Mostrar contraseña' : 'Ocultar contraseña'),
                ),
                const SizedBox(height: 4),
                CustomInput(
                  label: 'Confirmar contraseña',
                  obscure: true,
                  prefixIcon: Icons.lock_reset_outlined,
                  controller: _confirmarCtrl,
                  validator: (v) => validarConfirmacion(v, _claveCtrl.text),
                ),
                const SizedBox(height: 16),
                if (_errorGeneral != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorGeneral!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                CustomButton(
                  text: _registrando ? 'Creando cuenta...' : 'Crear cuenta',
                  icon: Icons.person_add_alt,
                  onPressed: _registrando ? () {} : _registrar,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Ya tengo cuenta: iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
