// CiudadAlerta - Widgets reutilizables (Clase 3 / Dia 3, extendido Dia 9)
// Campo de texto: label, hint, teclado y obscure opcional.
//
// NOVEDAD Dia 9 (HU-08): el widget entra al mundo de los FORMULARIOS con
// validacion. Internamente ahora es un TextFormField: acepta controller,
// validator y textCapitalization; los parametros del Dia 3 se conservan
// IGUAL, por eso las pantallas viejas no cambian ni una linea.

import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.controller,        // Dia 9: leer/escribir el valor desde codigo
    this.validator,         // Dia 9: regla del Form (null = valido)
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    // TextFormField hereda de TextField y agrega el contrato con Form:
    // validate() recorre cada uno de estos widgets del arbol.
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: obscure ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
