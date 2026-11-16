// CiudadAlerta - Modelo de dominio (Clase 4 / Dia 4, extendido Dia 9)
//
// El Dia 3 las tarjetas recibian Strings sueltos; hoy los datos viajan
// agrupados en un MODELO de Dart. Un modelo es la "clase entidad" del curso:
// el mismo patron de POO que en Java/C# pero con constructores nombrados.
//
// En el Hito 2 este mismo modelo llegara desde Supabase como JSON
// (fromJson/toJson ya quedan listos para esa conexion).
//
// NOVEDAD Dia 9 (HU-11): fotoUrl, el URL publico de la evidencia en el
// bucket 'fotos-reportes' de Storage. Es OPCIONAL y NULO por defecto:
// los 8 reportes del seed nacen sin foto y ningun test existente cambia.
// toJson la omite cuando es null: el contrato JSON del Dia 7 no cambia.

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
    this.fotoUrl,
  });

  final String id;          // Identificador unico (en el Hito 2: UUID de la BD)
  final String titulo;      // Titulo corto del problema
  final String categoria;   // Via, Luminaria, Residuos, Riesgo, Agua
  final String descripcion; // Detalle que escribira el ciudadano
  final String fecha;       // Mock en texto; formateo con intl llega en el Hito 4
  final String estado;      // Recibido / En revision / En proceso / Resuelto
  final String zona;        // Zona urbana de La Paz o El Alto
  final bool urgente;       // true = prioridad para la municipalidad
  final String? fotoUrl;    // Dia 9 (HU-11): URL publico en Storage (null = sin foto)

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
        fotoUrl: json['foto_url'] as String?,
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
        // HU-11: el campo solo viaja si hay foto (contrato del Dia 7 intacto).
        if (fotoUrl != null) 'foto_url': fotoUrl,
      };
}
