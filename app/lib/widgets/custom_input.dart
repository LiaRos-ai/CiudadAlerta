// CiudadAlerta - Widgets reutilizables (Clase 3 / Dia 3)
// Campo de texto: label, hint, teclado y obscure opcional.

import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
  });

  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
