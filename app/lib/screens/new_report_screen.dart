// CiudadAlerta - Formulario de nuevo reporte (Clase 4 / Dia 4)
// HU-05: "Como ciudadano quiero llenar un formulario de nuevo reporte con
// validación para evitar errores".
//
// Criterios de aceptacion:
//  - Validación con Form / TextFormField.
//  - Mensajes de error claros.
//  - NO envía si es inválido.
//
// Concepto del dia:
//  - GlobalKey<FormState> identifica el Form y permite formKey.currentState!
//  - validator() devuelve un String (error) o null (válido).
//  - textInputAction: .next / .done controla la tecla del teclado.
//  - El éxito muestra un SnackBar (la persistencia real llega en el Hito 2
//    con Supabase; hoy el envío es demo).

import 'package:flutter/material.dart';

import '../data/mock_reports.dart';
import '../widgets/custom_button.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String? _categoria;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _enviar() {
    // validate() ejecuta TODOS los validators y devuelve true si ninguno
    // marco error; sin esta linea el formulario enviaria datos incompletos.
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Reporte registrado (demo: se guarda con Supabase en el Hito 2)'),
            backgroundColor: Colors.green,
          ),
        );
      // Limpieza para el siguiente reporte (estado vuelve al inicial)
      _tituloCtrl.clear();
      _descripcionCtrl.clear();
      setState(() => _categoria = null);
    }
    // Si es invalido: cada TextFormField muestra SU mensaje de error.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo reporte')),
      // SingleChildScrollView: evita overflow cuando el teclado sube
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled, // valida al enviar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Titulo del reporte ----
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título del problema',
                  hintText: 'Ej.: Bache en la Av. Buenos Aires',
                  prefixIcon: Icon(Icons.report_outlined),
                ),
                textInputAction: TextInputAction.next, // tecla "siguiente"
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'El título es obligatorio.';
                  if (v.length < 5) {
                    return 'Ingresa un título de al menos 5 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ---- Categoria (lista del curso, no texto libre) ----
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categoriasCiudadAlerta
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _categoria = value),
                validator: (value) =>
                    value == null ? 'Selecciona una categoría.' : null,
              ),
              const SizedBox(height: 12),

              // ---- Descripcion ----
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción del problema',
                  hintText: '¿Qué pasa, dónde exactamente y desde cuándo?',
                  alignLabelWithHint: true,
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.length < 10) {
                    return 'Describe el problema con al menos 10 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Enviar reporte',
                icon: Icons.send,
                onPressed: _enviar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
