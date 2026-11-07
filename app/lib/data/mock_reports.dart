// CiudadAlerta - Datos simulados (mock) del Dia 4 (Clase 4)
//
// Hasta llegar a Supabase (Hito 2) la app usa DATOS SIMULADOS: una lista
// local en memoria que simula la respuesta de la base de datos.
//
// Regla del curso: la UI nunca inventa datos. La pantalla pide datos a una
// funcion async (cargarReportes) exactamente como pedira a Supabase en el
// Hito 2; cambiar la fuente de datos NO obligara a reescribir la pantalla.

import 'report.dart';

/// Categorias del backlog (HU-03 / HU-09): las mismas del formulario HU-05.
const List<String> categoriasCiudadAlerta = [
  'Via',
  'Luminaria',
  'Residuos',
  'Riesgo',
  'Agua',
];

/// Estados posibles de un reporte (HU-04 y panel de moderacion del Hito 4).
const List<String> estadosCiudadAlerta = [
  'Recibido',
  'En revision',
  'En proceso',
  'Resuelto',
];

/// Lista simulada: 8 reportes del contexto boliviano (La Paz y El Alto).
final List<Report> reportesMock = [
  const Report(
    id: 'RPT-001',
    titulo: 'Bache profundo en la Av. Buenos Aires',
    categoria: 'Via',
    descripcion:
        'Bache de aproximadamente 1 metro en el carril derecho, a la altura '
        'del paradero de minibus. Ya provoco dos llantas ponchadas esta semana.',
    fecha: '03/11/2026',
    estado: 'Recibido',
    zona: 'Miraflores, La Paz',
    urgente: true,
  ),
  const Report(
    id: 'RPT-002',
    titulo: 'Luminaria apagada en la calle Illampu',
    categoria: 'Luminaria',
    descripcion:
        'Tres postes seguidos sin luz frente al colegio. La cuadra queda '
        'completamente oscura despues de las 19:00 y es la ruta de vuelta '
        'de los estudiantes.',
    fecha: '02/11/2026',
    estado: 'En revision',
    zona: 'San Pedro, La Paz',
  ),
  const Report(
    id: 'RPT-003',
    titulo: 'Microbasural junto al rio de El Alto',
    categoria: 'Residuos',
    descripcion:
        'Escombros y bolsas de basura acumulados desde hace dos semanas en '
        'el borde de la quebrada. Con la lluvia el material baja hacia el rio.',
    fecha: '01/11/2026',
    estado: 'En proceso',
    zona: 'Senkata, El Alto',
    urgente: true,
  ),
  const Report(
    id: 'RPT-004',
    titulo: 'Cable de luz caido en la zona Sur',
    categoria: 'Riesgo',
    descripcion:
        'Cable de media tension colgando a un metro del suelo despues del '
        'viento fuerte. Los vecinos pasan por al lado con los ninos.',
    fecha: '31/10/2026',
    estado: 'En proceso',
    zona: 'Calacoto, La Paz',
    urgente: true,
  ),
  const Report(
    id: 'RPT-005',
    titulo: 'Fuga de agua en la esquina de la plaza',
    categoria: 'Agua',
    descripcion:
        'Perdida de agua potable que corre por la acera desde el sabado. '
        'Se desperdicia el agua y el piso resbala para los peatones.',
    fecha: '30/10/2026',
    estado: 'Recibido',
    zona: 'Villa Fatima, La Paz',
  ),
  const Report(
    id: 'RPT-006',
    titulo: 'Sardinera desbordada en la ceja de El Alto',
    categoria: 'Residuos',
    descripcion:
        'El contenedor esta lleno y los desechos quedan en la vereda. Aparecen '
        'perros y moscas toda la manana.',
    fecha: '29/10/2026',
    estado: 'Resuelto',
    zona: 'Ceja, El Alto',
  ),
  const Report(
    id: 'RPT-007',
    titulo: 'Tapa de alcantarilla rota en la Av. 16 de Julio',
    categoria: 'Via',
    descripcion:
        'La tapa se hundio y queda un hueco abierto en el carril del bici. '
        'Peligroso para ciclistas al anochecer.',
    fecha: '28/10/2026',
    estado: 'En revision',
    zona: 'El Prado, La Paz',
  ),
  const Report(
    id: 'RPT-008',
    titulo: 'Semafono apagado en la interseccion de la Ballivian',
    categoria: 'Luminaria',
    descripcion:
        'El semaforo principal esta sin senal desde el lunes; los vehiculos '
        'pasan sin ceder el paso a los peatones.',
    fecha: '27/10/2026',
    estado: 'Recibido',
    zona: 'Sopocachi, La Paz',
  ),
];

/// Busca un reporte por id (HU-04: la ruta /reporte/:id llama a esta funcion;
/// en el Hito 2 sera una consulta WHERE id = ? a Supabase).
Report? buscarReportePorId(String id) {
  for (final r in reportesMock) {
    if (r.id == id) return r;
  }
  return null;
}

/// Carga la lista de reportes.
///
/// Future.delayed simula la latencia de red: la UI practica HOY los tres
/// estados que exigira el Hito 2 (cargando / datos / vacio o error).
Future<List<Report>> cargarReportes() async {
  await Future.delayed(const Duration(milliseconds: 600));
  return reportesMock;
}
