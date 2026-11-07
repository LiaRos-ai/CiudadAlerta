// CiudadAlerta - Modelo de dominio (Clase 4 / Dia 4)
//
// El Dia 3 las tarjetas recibian Strings sueltos; hoy los datos viajan
// agrupados en un MODELO de Dart. Un modelo es la "clase entidad" del curso:
// el mismo patron de POO que en Java/C# pero con constructores nombrados.
//
// En el Hito 2 este mismo modelo llegara desde Supabase como JSON
// (fromJson/toJson ya quedan listos para esa conexion).

class Report {
  const Report({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.descripcion,
    required this.fecha,
    required this.estado,
    required this.zona,
    this.urgente = false,
  });

  final String id;          // Identificador unico (en el Hito 2: UUID de la BD)
  final String titulo;      // Titulo corto del problema
  final String categoria;   // Via, Luminaria, Residuos, Riesgo, Agua
  final String descripcion; // Detalle que escribira el ciudadano
  final String fecha;       // Mock en texto; formateo con intl llega en el Hito 4
  final String estado;      // Recibido / En revision / En proceso / Resuelto
  final String zona;        // Zona urbana de La Paz o El Alto
  final bool urgente;       // true = prioridad para la municipalidad

  /// Construccion desde un Map (asi llega el JSON de Supabase en el Hito 2).
  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        categoria: json['categoria'] as String,
        descripcion: json['descripcion'] as String,
        fecha: json['fecha'] as String,
        estado: json['estado'] as String,
        zona: json['zona'] as String,
        urgente: json['urgente'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'categoria': categoria,
        'descripcion': descripcion,
        'fecha': fecha,
        'estado': estado,
        'zona': zona,
        'urgente': urgente,
      };
}
