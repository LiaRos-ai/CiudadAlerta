// CiudadAlerta - Servicio de voz (Día 14 / Sprint 3, HU-16 y HU-19)
//
// HU-16: "Como ciudadano quiero dictar la descripción por voz para
//         reportar sin escribir".
// HU-19: "Como usuario quiero escuchar el detalle del reporte (texto a
//         voz) para accesibilidad".
//
// Las dos mitades del día en un solo servicio:
//   - speech_to_text -> RECONOCIMIENTO: la voz se vuelve texto con el
//     motor del sistema (Android SpeechRecognizer / iOS SFSpeechRecognizer),
//     que corre EN el dispositivo: sin costo por minuto y sin enviar el
//     audio a un tercero. La API de Google Speech-to-Text queda como
//     plan B de pago por minuto (comparativa en docs/60).
//   - flutter_tts -> SÍNTESIS: el texto se vuelve voz con el motor del
//     sistema (costo cero, funciona sin red, HU-19).
//
// Reglas del curso que NO cambian (Días 9 y 13):
//   1. El permiso (RECORD_AUDIO) se pide EN CONTEXTO: al tocar el botón
//      de dictar, nunca al abrir la app. Negado: el formulario sigue con
//      el teclado - el dictado MEJORA el reporte, jamás lo bloquea.
//   2. La lógica pura (limpiarTranscripcion, transcripcionSuficiente,
//      localeTts, textoParaLeer) vive aquí abajo y se prueba sin
//      micrófono ni motor de voz.
//   3. La pantalla solo llama al servicio y muestra resultados.
//
// Accesibilidad: TalkBack ya lee la UI con los Semantics del Día 4;
// el botón "Escuchar" (HU-19) agrega el otro lado: el ciudadano que
// ve mal o no quiere leer, ESCUCHA el contenido del reporte.

import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Locale de dictado (español; el motor del sistema resuelve la variante).
const String kLocaleDictado = 'es_BO';

class VozService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  // ------------------------------------------------------------------
  // HU-16: reconocimiento de voz (voz -> texto)
  // ------------------------------------------------------------------

  /// El permiso se pide EN CONTEXTO (al tocar el botón de dictar).
  Future<bool> permisoMicrofono() =>
      Permission.microphone.request().isGranted;

  /// ¿El reconocimiento está disponible en ESTE dispositivo?
  /// (initialize levanta el servicio del sistema; falla en el emulador
  /// sin SpeechRecognizer: deterioro elegante, no excepción).
  Future<bool> disponible() async {
    try {
      return await _stt.initialize();
    } catch (_) {
      return false;
    }
  }

  /// HU-16: dicta y reporta EN VIVO. [alTexto] recibe cada actualización
  /// (resultados parciales) para que el TextField muestre la transcripción
  /// mientras el ciudadano habla. Devuelve el mensaje para el SnackBar
  /// (null = el dictado arrancó bien).
  Future<String?> dictar({
    required void Function(String texto) alTexto,
  }) async {
    if (!await permisoMicrofono()) {
      return 'Sin permiso de micrófono: escribe la descripción o '
          'actívalo en Ajustes > Aplicaciones > CiudadAlerta.';
    }
    if (!await disponible()) {
      return 'Este dispositivo no ofrece reconocimiento de voz.';
    }
    await _stt.listen(
      localeId: kLocaleDictado,
      listenOptions: SpeechListenOptions(
        partialResults: true, // transcripción en vivo, no al terminar
        cancelOnError: true,
      ),
      onResult: (resultado) {
        final texto = limpiarTranscripcion(resultado.recognizedWords);
        if (texto.isNotEmpty) alTexto(texto);
      },
    );
    return null;
  }

  Future<void> detener() => _stt.stop();

  // ------------------------------------------------------------------
  // HU-19: texto a voz (texto -> voz)
  // ------------------------------------------------------------------

  /// Configura el mejor español disponible y lee. Devuelve el mensaje
  /// de error (null = la locución arrancó).
  Future<String?> escuchar(String texto) async {
    final locale = await elegirLocaleTts();
    if (locale == null) {
      return 'El motor de voz del dispositivo no tiene español instalado.';
    }
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.5); // ritmo medio: claro, no apurado
    await _tts.stop(); // reinicia si había una lectura anterior
    await _tts.speak(texto);
    return null;
  }

  Future<void> silenciar() => _tts.stop();

  /// Pregunta al motor qué voces hay instaladas y elige español.
  Future<String?> elegirLocaleTts() async {
    try {
      final dinamicos = await _tts.getLanguages;
      final instalados = [
        for (final l in dinamicos ?? const <String>[]) l.toString(),
      ];
      return localeTts(instalados);
    } catch (_) {
      return localeTts(const []); // motor sin enumerar: usa el candidato base
    }
  }

  void dispose() {
    _tts.stop();
  }
}

// ------------------------------------------------------------ lógica pura
// Probable sin micrófono ni motor de voz (la suite del Día 14 la cubre).

/// Deja la transcripción lista para el campo: recorta bordes, colapsa
/// los espacios repetidos del dictado y capitaliza la primera letra.
String limpiarTranscripcion(String bruta) {
  final limpio = bruta.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (limpio.isEmpty) return '';
  return limpio[0].toUpperCase() + limpio.substring(1);
}

/// La MISMA regla del validador HU-05: 10 caracteres como mínimo.
bool transcripcionSuficiente(String texto) => texto.trim().length >= 10;

/// Elige el mejor locale de voz disponible (TTS). Con la lista vacía
/// se asume que el motor del sistema resuelve 'es' genérico; si el
/// motor enumeró voces y ninguna es española, null (mensaje honesto).
String? localeTts(List<String> instalados) {
  const candidatos = ['es_BO', 'es_MX', 'es_ES', 'es_US', 'es'];
  for (final c in candidatos) {
    if (instalados.contains(c)) return c;
  }
  return instalados.isEmpty ? 'es' : null;
}

/// HU-19: el texto EXACTO que lee el botón "Escuchar" del detalle.
/// Un locutor no lee etiquetas de UI: lee el reporte como una noticia.
String textoParaLeer({
  required String codigo,
  required String titulo,
  required String estado,
  required String zona,
  required String descripcion,
}) {
  return 'Reporte $codigo. $titulo. '
      'Estado: $estado. Zona: $zona. '
      'Descripción: $descripcion';
}
