// CiudadAlerta - Formulario de reporte: crear (HU-05) y editar (HU-10)
// HU-05: "Como ciudadano quiero llenar un formulario de nuevo reporte con
// validación para evitar errores".
// HU-07 (Día 6): "Como usuario quiero guardar borradores locales para no
// perder lo escrito sin conexión" (solo en modo CREAR).
//
// NOVEDAD Dia 8: el formulario GUARDA en la base de datos.
//   - Modo crear (ruta /nuevo): valida y llama repo.crearReporte() -> INSERT.
//     El borrador HU-07 se conserva y se limpia tras el envio exitoso.
//   - Modo editar (ruta /editar/:id): precarga el reporte con el provider
//     family (WHERE codigo = X) y llama repo.actualizarReporte() -> UPDATE.
//     El borrador NO interviene: se esta editando un dato que ya vive en la BD.
//   - La categoria en modo editar queda fija (la del reporte): cambiarla
//     implicaria una FK nueva y el curso lo resuelve en el Hito 4 con el
//     panel de moderacion.
//   - Envio async con bloqueo del boton y manejo de errores: si la BD
//     rechaza (constraint o RLS), el SnackBar lo muestra y el borrador
//     sobrevive (HU-07).
//
// Criterios HU-05 intactos: Form/TextFormField, mensajes claros y NO
// envia si es invalido.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/draft_store.dart';
import '../data/mock_reports.dart';
import '../data/reports_repository.dart';
import '../providers/reports_provider.dart';
import '../widgets/custom_button.dart';

class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key, this.codigo});

  /// Codigo del reporte a editar (modo edicion) o null (modo crear).
  final String? codigo;

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _borrador = DraftStore(); // HU-07: almacen local del borrador
  String? _categoria;
  bool _guardando = false; // bloquea el boton durante el INSERT/UPDATE
  Report? _original; // reporte precargado en modo edicion

  bool get _modoEdicion => widget.codigo != null;

  /// Evita que la restauracion del borrador dispare los listeners y
  /// re-escriba en shared_preferences justo lo que acabamos de leer.
  bool _restaurando = true;

  @override
  void initState() {
    super.initState();
    // HU-07 (solo modo crear): cada cambio del usuario persiste el borrador.
    if (!_modoEdicion) {
      _tituloCtrl.addListener(_guardarBorrador);
      _descripcionCtrl.addListener(_guardarBorrador);
      _restaurarBorrador();
    } else {
      _precargarOriginal();
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  /// Modo edicion: trae el reporte con el WHERE codigo = X (family provider)
  /// y llena los controllers ANTES del primer frame util.
  Future<void> _precargarOriginal() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(reportsRepositoryProvider);
      Report? reporte;
      try {
        reporte = await repo.buscarPorId(widget.codigo!);
      } catch (_) {
        reporte = null;
      }
      if (!mounted) return;
      if (reporte == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content:
                  Text('No existe el reporte "${widget.codigo}" para editar.')));
        return;
      }
      setState(() {
        _original = reporte;
        _tituloCtrl.text = reporte.titulo;
        _descripcionCtrl.text = reporte.descripcion;
        _categoria = reporte.categoria;
        _restaurando = false;
      });
    });
  }

  /// HU-07: persistencia local en cada cambio (sin conexion, sin servidor).
  Future<void> _guardarBorrador() async {
    if (_restaurando || _modoEdicion) return;
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
      setState(() => _restaurando = false);
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

  /// Dia 8: envio ASINCRONO a la base de datos (INSERT o UPDATE).
  Future<void> _enviar() async {
    // validate() ejecuta TODOS los validators y devuelve true si ninguno
    // marco error; sin esta linea el formulario enviaria datos incompletos.
    if (!_formKey.currentState!.validate()) {
      // Si es invalido: cada TextFormField muestra SU mensaje de error y el
      // borrador SE CONSERVA (eso es exactamente lo que pide la HU-07).
      return;
    }
    setState(() => _guardando = true);
    final repo = ref.read(reportsRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_modoEdicion) {
        // HU-10: UPDATE ... WHERE codigo = X
        await repo.actualizarReporte(
          _original!.id,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim(),
        );
        ref.invalidate(reportePorIdProvider(_original!.id));
      } else {
        // HU-10: INSERT + RETURNING (la BD genera id, codigo y fecha)
        await repo.crearReporte(
          titulo: _tituloCtrl.text.trim(),
          categoria: _categoria!,
          descripcion: _descripcionCtrl.text.trim(),
          zona: 'Zona del ciudadano (demo)',
        );
        _borrador.limpiar(); // HU-07: enviado = dejar de ser borrador
        _tituloCtrl.clear();
        _descripcionCtrl.clear();
        setState(() {
          _categoria = null;
        });
      }
      // La lista y las estadisticas dependen de la BD: se invalidan y las
      // pantallas que las escuchan se refrescan solas (reactividad Dia 6).
      ref.invalidate(reportesProvider);
      ref.invalidate(estadisticasCategoriaProvider);
      ref.invalidate(estadisticasEstadoProvider);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(_modoEdicion
              ? 'Cambios guardados en la base de datos.'
              : 'Reporte registrado en la base de datos (modo demo).'),
          backgroundColor: Colors.green,
        ));
      if (mounted && _modoEdicion) Navigator.of(context).pop();
    } catch (e) {
      // Error de constraint, RLS o red: mensaje claro, borrador intacto
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('No se pudo guardar el reporte: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_modoEdicion ? 'Editar reporte' : 'Nuevo reporte')),
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
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.category_outlined),
                  // Modo edicion: la categoria es FK del reporte original
                  helperText: _modoEdicion
                      ? 'La categoría no cambia en la edición (FK del reporte).'
                      : null,
                ),
                items: categoriasCiudadAlerta
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _modoEdicion
                    ? null // fija en modo edicion
                    : (value) {
                        setState(() => _categoria = value);
                        _guardarBorrador(); // HU-07: el dropdown persiste
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

              // Dia 8: el boton se bloquea mientras corre el INSERT/UPDATE
              // (doble tap = dos INSERT: es el clasico bug de formularios async)
              CustomButton(
                text: _modoEdicion
                    ? 'Guardar cambios'
                    : 'Enviar reporte',
                icon: _modoEdicion ? Icons.save_outlined : Icons.send,
                onPressed: _guardando ? () {} : _enviar,
              ),
              if (_guardando)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
