// CiudadAlerta - Modelos de estadisticas (Clase 8 / Dia 8)
// HU-13: "Como autoridad quiero ver estadisticas por categoria y estado
// para priorizar atencion".
//
// Cada fila de estas clases es el resultado de una consulta agregada
// (GROUP BY) como la C06 del Dia 7:
//
//   select c.nombre as categoria, count(r.id) as total_reportes
//   from categories c
//   left join reports r on r.categoria_id = c.id
//   group by c.nombre
//   order by total_reportes desc;
//
// En Supabase el agregado llega por REST (count) o se agrupa en Dart;
// la forma de la fila es la misma: un rotulo + un numero. El grafico
// fl_chart de la pantalla de estadisticas consume exactamente esto.

/// Total de reportes por categoria (eje X del grafico de barras).
class EstadisticaCategoria {
  const EstadisticaCategoria({required this.categoria, required this.total});

  final String categoria; // Via, Luminaria, Residuos, Riesgo, Agua
  final int total;

  factory EstadisticaCategoria.fromJson(Map<String, dynamic> json) =>
      EstadisticaCategoria(
        categoria: json['categoria'] as String,
        total: (json['total'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {'categoria': categoria, 'total': total};
}

/// Total de reportes por estado (segunda vista de la pantalla: chips o
/// barras horizontales con Recibido / En revision / En proceso / Resuelto).
class EstadisticaEstado {
  const EstadisticaEstado({required this.estado, required this.total});

  final String estado;
  final int total;

  factory EstadisticaEstado.fromJson(Map<String, dynamic> json) =>
      EstadisticaEstado(
        estado: json['estado'] as String,
        total: (json['total'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {'estado': estado, 'total': total};
}

/// Agrupa una lista de reportes por categoria (el GROUP BY de HU-13 hecho
/// en Dart cuando la API no expone el agregado directo).
///
/// Se conserva el orden del catalogo [categorias] y las categorias sin
/// reportes aparecen con 0: es el LEFT JOIN del Dia 7 garantizando que
/// el eje del grafico muestre las 5 categorias completas.
List<EstadisticaCategoria> agruparPorCategoria(
  List<({String categoria})> filas, {
  List<String> categorias = const [],
}) {
  final conteo = <String, int>{
    for (final c in categorias) c: 0,
  };
  for (final f in filas) {
    conteo[f.categoria] = (conteo[f.categoria] ?? 0) + 1;
  }
  final orden = [
    ...categorias.where(conteo.containsKey),
    ...conteo.keys.where((c) => !categorias.contains(c)),
  ];
  // Orden por total descendente; en empate gana el orden del catalogo
  // (List.sort no es estable: el desempate explicito garantiza graficos
  // identicos entre corridas y entre app y pruebas).
  int indiceCatalogo(String c) {
    final i = categorias.indexOf(c);
    return i == -1 ? categorias.length + orden.indexOf(c) : i;
  }

  orden.sort((a, b) {
    final diferencia = conteo[b]!.compareTo(conteo[a]!);
    if (diferencia != 0) return diferencia;
    return indiceCatalogo(a).compareTo(indiceCatalogo(b));
  });
  return [
    for (final c in orden)
      EstadisticaCategoria(categoria: c, total: conteo[c] ?? 0),
  ];
}

/// Agrupa una lista de reportes por estado (GROUP BY estado de HU-13).
List<EstadisticaEstado> agruparPorEstado(
  List<({String estado})> filas, {
  List<String> estados = const [],
}) {
  final conteo = <String, int>{for (final e in estados) e: 0};
  for (final f in filas) {
    conteo[f.estado] = (conteo[f.estado] ?? 0) + 1;
  }
  return [
    for (final e in estados.where(conteo.containsKey))
      EstadisticaEstado(estado: e, total: conteo[e] ?? 0),
    ...conteo.entries
        .where((e) => !estados.contains(e.key))
        .map((e) => EstadisticaEstado(estado: e.key, total: e.value)),
  ];
}
