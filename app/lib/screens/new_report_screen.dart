// CiudadAlerta - Formulario de nuevo reporte (Clase 4 / Dia 4 + HU-07 Dia 6)
// HU-05: "Como ciudadano quiero llenar un formulario de nuevo reporte con
// validación para evitar errores".
// HU-07 (Día 6): "Como usuario quiero guardar borradores locales para no
// perder lo escrito sin conexión".
//
// Criterios de aceptacion HU-05:
//  - Validación con Form / TextFormField.
//  - Mensajes de error claros.
//  - NO envía si es inválido.
//
// Criterio de aceptacion HU-07:
//  - El borrador PERSISTE al cerrar la app y se restaura al volver.
//  - Al enviar con éxito, el borrador se limpia.
//
// Concepto del dia (Día 6):
//  - DraftStore (lib/data/draft_store.dart) guarda los 3 campos en
//    shared_preferences en CADA cambio del usuario (listener de los
//    controllers + onChanged del dropdown).
//  - initState restaura el borrador ANTES del primer frame util
//    (_restaurandoBloqueaSave evita re-guardar lo que acabamos de leer).
//  - El teclado/validacion del Día 4 no cambia: capas separadas.

import 'package:flutter/material.dart';

import '../data/draft_store.dart';
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
  final _borrador = DraftStore(); // HU-07: almacen local del borrador
  String? _categoria;

  /// Evita que la restauracion del borrador dispare los listeners y
  /// re-escriba en shared_preferences justo lo que acabamos de leer.
  bool _restaurando = true;

  @override
  void initState() {
    super.initState();
    // HU-07: cada cambio del usuario persiste el borrador. El listener
    // corre despues de cada caracter; con 3 campos el costo es minimo.
    _tituloCtrl.addListener(_guardarBorrador);
    _descripcionCtrl.addListener(_guardarBorrador);
    _restaurarBorrador();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  /// HU-07: persistencia local en cada cambio (sin conexion, sin servidor).
  Future<void> _guardarBorrador() async {
    if (_restaurando) return;
    await _borrador.guardar(BorradorReporte(
      titulo: _tituloCtrl.text,
      categoria: _categoria,
      descripcion: _descripcionCtrl.text,
    ));
  }

  /// HU-07: al abrir la pantalla, si hay un borrador guardado se restaura.
  Future<void> _restaurarBorrador() async {
    final borrador = await _borrador.cargar();
    if (!mounted) return;
    if (borrador.vacio) {
      _restaurando = false; // no hay nada que restaurar: activar el guardado
      return;
    }
    _tituloCtrl.text = borrador.titulo;
    _descripcionCtrl.text = borrador.descripcion;
    setState(() {
      _categoria = borrador.categoria;
      _restaurando = false;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Borrador restaurado de tu última sesión'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _enviar() {
    // validate() ejecuta TODOS los validators y devuelve true si ninguno
    // marco error; sin esta linea el formulario enviaria datos incompletos.
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Reporte registrado (demo: se guarda con Supabase en el Día 8)'),
            backgroundColor: Colors.green,
          ),
        );
      // Limpieza para el siguiente reporte (estado vuelve al inicial)
      _tituloCtrl.clear();
      _descripcionCtrl.clear();
      setState(() => _categoria = null);
      // HU-07: el reporte ya no es borrador -> el almacen local se limpia
      _borrador.limpiar();
    }
    // Si es invalido: cada TextFormField muestra SU mensaje de error y el
    // borrador SE CONSERVA (eso es exactamente lo que pide la HU-07).
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
                onChanged: (value) {
                  setState(() => _categoria = value);
                  _guardarBorrador(); // HU-07: el dropdown tambien persiste
                },
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
