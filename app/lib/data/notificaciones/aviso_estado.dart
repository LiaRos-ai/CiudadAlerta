// CiudadAlerta - Aviso de cambio de estado (Día 14 / Sprint 3, HU-17)
//
// "Como ciudadano quiero recibir una notificación cuando cambie el
//  estado de mi reporte".
//
// El aviso es una decisión de CONTENIDO, no de plataforma: el mismo
// texto sirve para la notificación LOCAL del laboratorio y para el
// PUSH que la Edge Function envía por FCM (docs/60). Por eso vive en
// lógica pura: la prueba la valida sin dispositivo, sin Firebase y
// sin base de datos.
//
// Anti-spam: una notificación que no se entiende se ignora y una app
// que avisa de todo se silencia para siempre. CiudadAlerta avisa SOLO
// del cambio de estado de reportes PROPIOS (el ciclo Recibido ->
// En proceso -> Resuelto que la app ya muestra en los chips).

/// Ciclo de estados del curso (el mismo de los chips del detalle y de
/// la característica "ciclo de estados" del Sprint 2).
const List<String> cicloEstados = ['Recibido', 'En proceso', 'Resuelto'];

/// ¿Cambió el estado? (el trigger de la BD usa la MISMA comparación:
/// old.estado IS DISTINCT FROM new.estado, docs/60).
bool estadoCambio(String antes, String despues) => antes != despues;

/// Siguiente paso del ciclo para la demo (null si el estado no está
/// en el ciclo: la pantalla usa 'En proceso' por defecto).
String? siguienteEstado(String estado) {
  final i = cicloEstados.indexOf(estado);
  if (i == -1) return null;
  return cicloEstados[(i + 1) % cicloEstados.length];
}

/// ¿Merece aviso? SOLO cambios de estado de reportes propios: la
/// creación, la edición del título y la foto no disparan notificación.
bool mereceAviso({
  required bool propio,
  required String antes,
  required String despues,
}) =>
    propio && estadoCambio(antes, despues);

/// Título del aviso: el ciudadano reconoce la app antes de abrir.
String tituloAviso(String codigo) => 'CiudadAlerta: tu reporte $codigo';

/// Cuerpo del aviso: qué cambió, con el título del reporte para dar
/// contexto sin abrir la app (claridad primero).
String cuerpoAvisoEstado({
  required String titulo,
  required String estadoAnterior,
  required String estadoNuevo,
}) {
  return '"$titulo" pasó de $estadoAnterior a $estadoNuevo.';
}
