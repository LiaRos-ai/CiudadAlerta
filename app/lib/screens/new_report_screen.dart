// CiudadAlerta - Formulario de reporte: crear (HU-05), editar (HU-10)
// y adjuntar la evidencia fotografica (HU-11, Dia 9)
// HU-05: "Como ciudadano quiero llenar un formulario de nuevo reporte con
// validación para evitar errores".
// HU-07 (Día 6): "Como usuario quiero guardar borradores locales para no
// perder lo escrito sin conexión" (solo en modo CREAR).
// HU-11 (Día 9): "Como ciudadano quiero adjuntar una foto al reporte para
// dar evidencia" - camara/galeria, sube a Storage, muestra miniatura.
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
// NOVEDAD Dia 9 (HU-11): el flujo de la foto es TRES pasos en cadena:
//   1. ELEGIR: ImagePicker con permission_handler (camara pide su permiso;
//      galeria usa el selector del sistema). Si el ciudadano niega, la app
//      sigue funcionando SIN foto (el reporte nunca depende del permiso).
//   2. VALIDAR: formato (jpg/png/webp) y peso (<= 5 MB) ANTES de subir.
//   3. SUBIR tras el INSERT del reporte: Storage guarda el archivo en la
//      carpeta del usuario (ruta determinista de photo_storage.dart) y
//      adjuntarFoto() registra el URL en report_photos. Si la subida
//      falla, el reporte YA ESTA guardado: se avisa, no se borra nada.
//
// Criterios HU-05 intactos: Form/TextFormField, mensajes claros y NO
// envia si es invalido.
//
// NOVEDAD Dia 13 (HU-15): "usar mi ubicación". El botón pide el permiso
// EN CONTEXTO, toma UNA lectura puntual (high, timeLimit 8 s) y la
// vuelve legible con el geocoder del sistema. La dirección real pasa a
// ser la zona del reporte y las coordenadas viajan al INSERT. Si algo
// falla (GPS apagado, timeout, permiso negado), el formulario SIGUE:
// el reporte nunca depende del permiso (misma regla que la foto HU-11).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/draft_store.dart';
import '../data/mock_reports.dart';
import '../data/photo_storage.dart';
import '../data/report.dart';
import '../data/reports_repository.dart';
import '../data/ubicacion/geocoding_service.dart';
import '../data/ubicacion/ubicacion_service.dart';
import '../data/voz/voz_service.dart';
import '../providers/auth_provider.dart';
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
  XFile? _foto; // HU-11: evidencia elegida (null = sin foto)

  // Dia 13 (HU-15): la ubicación del reporte (null = se envía sin ella)
  final _ubicacion = const UbicacionService();
  final _geocoding = GeocodingService();
  double? _latitud;
  double? _longitud;
  String? _direccion;
  bool _ubicando = false;

  // Dia 14 (HU-16): dictado por voz de la descripción
  final _voz = VozService();
  bool _dictando = false; // el chip de escucha es un ESTADO, como el punto azul

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
      final cargado = reporte;
      if (cargado != null) {
        setState(() {
          _original = cargado;
          _tituloCtrl.text = cargado.titulo;
          _descripcionCtrl.text = cargado.descripcion;
          _categoria = cargado.categoria;
          _restaurando = false;
        });
      }
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

  // ------------------------------------------------------------------
  // Dia 9 (HU-11): la foto
  // ------------------------------------------------------------------

  /// Paso 1: ELEGIR con ImagePicker + permisos (solo la camara pide
  /// permiso runtime; la galeria en Android 13+ usa el selector del SO).
  Future<void> _elegirFoto(ImageSource origen) async {
    if (origen == ImageSource.camera) {
      final estado = await Permission.camera.request();
      if (!estado.isGranted) {
        _mostrar(estado.isPermanentlyDenied
            ? 'Permiso de cámara denegado. Actívalo en Ajustes > Aplicaciones.'
            : 'Sin permiso de cámara: elige una foto de tu galería.');
        return;
      }
    }
    final foto = await ImagePicker().pickImage(
      source: origen,
      imageQuality: 70, // compresion: menos MB en el plan de datos
      maxWidth: 1600,
    );
    if (foto == null) return; // el ciudadano cancelo: sin cambios
    _validarYFijar(foto);
  }

  /// Paso 2: VALIDAR formato y peso ANTES de subir (fallar rapido).
  Future<void> _validarYFijar(XFile foto) async {
    final tamano = await foto.length();
    final error = validarImagen(foto.name, tamanoBytes: tamano);
    if (!mounted) return;
    if (error != null) {
      _mostrar(error);
      return;
    }
    setState(() => _foto = foto);
  }

  void _quitarFoto() => setState(() => _foto = null);

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ------------------------------------------------------------------
  // Dia 13 (HU-15): la ubicación del reporte
  // ------------------------------------------------------------------

  /// Pide permiso EN CONTEXTO (al tocar "Usar mi ubicación"), toma UNA
  /// lectura puntual y la vuelve legible con el geocoder del sistema.
  /// Si algo falla, el formulario SIGUE: el reporte nunca depende del
  /// permiso (misma regla que la foto del Día 9).
  Future<void> _capturarUbicacion() async {
    setState(() => _ubicando = true);
    final posicion = await _ubicacion.posicionActual();
    if (!mounted) return;
    if (posicion == null) {
      final bloqueado = await _ubicacion.denegadoParaSiempre();
      if (!mounted) return;
      _mostrar(mensajePermiso(true, bloqueado));
      setState(() => _ubicando = false);
      return;
    }
    // Reverse geocoding: coordenadas -> "Calle, Barrio, Ciudad".
    // La dirección legible reemplaza al placeholder del Día 4.
    final direccion = await _geocoding.direccionDe(
      latitud: posicion.latitude,
      longitud: posicion.longitude,
    );
    if (!mounted) return;
    setState(() {
      _latitud = posicion.latitude;
      _longitud = posicion.longitude;
      _direccion = direccion;
      _ubicando = false;
    });
    _mostrar(direccion == null
        ? 'Ubicación capturada (${posicion.latitude.toStringAsFixed(5)}, '
            '${posicion.longitude.toStringAsFixed(5)})'
        : 'Ubicación capturada: $direccion');
  }

  void _quitarUbicacion() =>
      setState(() {
        _latitud = null;
        _longitud = null;
        _direccion = null;
      });

  // ------------------------------------------------------------------
  // Dia 14 (HU-16): dictado por voz de la descripción
  // ------------------------------------------------------------------

  /// Primer tap arranca el dictado EN CONTEXTO (el permiso de micrófono
  /// se pide JUSTO aquí, no al abrir la app); segundo tap detiene. Los
  /// resultados PARCIALES del motor van actualizando el campo mientras
  /// el ciudadano habla; la transcripción limpia reemplaza el contenido
  /// y el borrador HU-07 sigue persistiendo cada cambio.
  Future<void> _dictarDescripcion() async {
    if (_dictando) {
      await _voz.detener();
      if (mounted) setState(() => _dictando = false);
      return;
    }
    final mensaje = await _voz.dictar(
      alTexto: (texto) {
        if (mounted) setState(() => _descripcionCtrl.text = texto);
      },
    );
    if (!mounted) return;
    if (mensaje != null) {
      _mostrar(mensaje); // sin permiso o sin motor: el teclado sigue
      return;
    }
    setState(() => _dictando = true);
    _mostrar('Dictando... toca el micrófono de nuevo para detener.');
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
      Report? creado;
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
        creado = await repo.crearReporte(
          titulo: _tituloCtrl.text.trim(),
          categoria: _categoria!,
          descripcion: _descripcionCtrl.text.trim(),
          // Dia 13 (HU-15): la dirección legible del geocoder es la zona
          // real del reporte; sin ubicación queda el texto del Día 4.
          zona: _direccion ?? 'Zona del ciudadano (demo)',
          latitud: _latitud,
          longitud: _longitud,
        );
        _borrador.limpiar(); // HU-07: enviado = dejar de ser borrador
        _tituloCtrl.clear();
        _descripcionCtrl.clear();
        setState(() {
          _categoria = null;
        });
      }

      // Dia 9 (HU-11): PASO 3 de la foto, DESPUES del INSERT. Si falla la
      // subida, el reporte ya vive: se avisa y no se borra nada.
      if (!_modoEdicion && _foto != null && creado != null) {
        try {
          final sesion = await ref.read(authRepositoryProvider).sesionActual();
          final uid = sesion?.id ?? 'invitado'; // la carpeta acota por usuario
          final photoRepo = ref.read(photoRepositoryProvider);
          final url = await photoRepo.subirFoto(
            usuarioId: uid,
            codigoReporte: creado.id,
            rutaLocal: _foto!.path,
          );
          await repo.adjuntarFoto(creado.id, url);
          ref.invalidate(reportePorIdProvider(creado.id));
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Foto subida a Storage y vinculada al reporte.'),
              backgroundColor: Colors.green,
            ));
          _quitarFoto();
        } catch (e) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('El reporte quedó guardado, pero la foto falló: $e'),
            ));
        }
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

              // ---- Descripcion (Día 14 / HU-16: con dictado por voz) ----
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción del problema',
                  hintText: '¿Qué pasa, dónde exactamente y desde cuándo?',
                  alignLabelWithHint: true,
                  // HU-16: el dictado se activa DESDE el campo (contexto).
                  // El permiso RECORD_AUDIO se pide en el primer tap.
                  suffixIcon: IconButton(
                    tooltip: _dictando
                        ? 'Detener dictado'
                        : 'Dictar descripción por voz',
                    icon: Icon(
                      _dictando ? Icons.mic : Icons.mic_none,
                      color: _dictando
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: _dictarDescripcion,
                  ),
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
              // Día 14 (HU-16): la escucha es un ESTADO visible; el texto
              // suficiente se valida con la misma regla de 10 caracteres.
              if (_dictando)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.graphic_eq, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Escuchando... habla con claridad; el texto '
                          'aparece en vivo en el campo.',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // ---- Dia 13 (HU-15): la ubicación del reporte ----
              if (!_modoEdicion) ...[
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _latitud != null
                                  ? Icons.location_on
                                  : Icons.location_off_outlined,
                              color: _latitud != null
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _latitud != null
                                    ? 'Ubicación capturada '
                                        '(${_latitud!.toStringAsFixed(5)}, '
                                        '${_longitud!.toStringAsFixed(5)})'
                                    : _direccion ?? 'Sin ubicación: el '
                                        'reporte se envía igual '
                                        '(deterioro elegante)',
                              ),
                            ),
                            if (_latitud != null)
                              IconButton(
                                tooltip: 'Quitar ubicación',
                                icon: const Icon(Icons.close),
                                onPressed: _quitarUbicacion,
                              ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: _ubicando ? null : _capturarUbicacion,
                          icon: _ubicando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                          label: const Text('Usar mi ubicación'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ---- Dia 9 (HU-11): evidencia fotografica ----
              if (!_modoEdicion) ...[
                if (_foto != null)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.file(
                            File(_foto!.path),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              height: 160,
                              child: Center(child: Icon(Icons.broken_image_outlined)),
                            ),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.photo_outlined),
                          title: Text('Miniatura lista: ${_foto!.name}',
                              overflow: TextOverflow.ellipsis),
                          subtitle: const Text(
                              'Se sube a Storage junto con el reporte.'),
                          trailing: IconButton(
                            tooltip: 'Quitar foto',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _quitarFoto,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _elegirFoto(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Cámara'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _elegirFoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galería'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

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
